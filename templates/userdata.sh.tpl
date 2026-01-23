#!/bin/bash
# UserData script for ALB Health Check Demo
# Installs and configures a Python web application with health check simulation

# Enable logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting UserData script at $(date)"
echo "Instance: ${instance_name}"
echo "Environment: ${environment}"

# Update system (don't fail if this has issues)
yum update -y || echo "yum update had some issues, continuing..."
yum install -y python3 python3-pip jq curl

# Create application directory
mkdir -p /opt/webapp
cd /opt/webapp

# Create a simple HTTP server using Python's built-in modules
cat > app.py << 'APPEOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import sys
import threading
import time
from datetime import datetime

# Health status control (shared state)
health_status = {"healthy": True, "reason": "OK"}

class WebHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        sys.stdout.write("%s - - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format%args))
        sys.stdout.flush()

    def send_json_response(self, status_code, data):
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        if self.path == '/':
            self.send_json_response(200, {
                "service": "demo-webapp",
                "instance": os.environ.get('INSTANCE_ID', 'unknown'),
                "environment": os.environ.get('ENVIRONMENT', 'unknown'),
                "status": "running"
            })

        elif self.path == '/health':
            if health_status["healthy"]:
                self.send_json_response(200, {"status": "healthy"})
            else:
                self.send_json_response(503, {
                    "status": "unhealthy",
                    "reason": health_status["reason"]
                })

        elif self.path == '/status':
            self.send_json_response(200, health_status)

        elif self.path == '/simulate/unhealthy':
            health_status["healthy"] = False
            health_status["reason"] = "Simulated database connection failure"
            print(f"[{datetime.now()}] Simulated unhealthy state triggered")
            self.send_json_response(200, {
                "message": "Health check will now fail",
                "reason": health_status["reason"]
            })

        elif self.path == '/simulate/healthy':
            health_status["healthy"] = True
            health_status["reason"] = "OK"
            print(f"[{datetime.now()}] Restored to healthy state")
            self.send_json_response(200, {
                "message": "Health check restored to healthy"
            })

        elif self.path == '/simulate/crash':
            def delayed_crash():
                time.sleep(5)
                print(f"[{datetime.now()}] Simulated crash - exiting")
                os._exit(1)
            threading.Thread(target=delayed_crash, daemon=True).start()
            self.send_json_response(200, {
                "message": "Application will crash in 5 seconds"
            })

        elif self.path == '/simulate/slow-health':
            health_status["healthy"] = False
            health_status["reason"] = "Health check timeout simulation"
            print(f"[{datetime.now()}] Simulated slow health check")
            self.send_json_response(200, {
                "message": "Health checks will now be slow/timeout"
            })

        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

if __name__ == '__main__':
    port = 80
    server_address = ('0.0.0.0', port)
    httpd = HTTPServer(server_address, WebHandler)
    print(f"[{datetime.now()}] Starting HTTP server on 0.0.0.0:{port}")
    print(f"[{datetime.now()}] Instance ID: {os.environ.get('INSTANCE_ID', 'unknown')}")
    print(f"[{datetime.now()}] Environment: {os.environ.get('ENVIRONMENT', 'unknown')}")
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print(f"\n[{datetime.now()}] Server stopped")
        sys.exit(0)
    except Exception as e:
        print(f"[{datetime.now()}] ERROR: {e}")
        sys.exit(1)
APPEOF

# Make app executable
chmod +x /opt/webapp/app.py

# Test the script syntax
echo "Validating Python script..."
python3 -m py_compile /opt/webapp/app.py
if [ $? -eq 0 ]; then
  echo "Python script is valid"
else
  echo "ERROR: Python script has syntax errors"
  cat /opt/webapp/app.py
  exit 1
fi

# Get instance ID using IMDSv2 (required)
echo "Getting instance ID..."
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
export INSTANCE_ID
echo "Instance ID: $INSTANCE_ID"

# Create systemd service
cat > /etc/systemd/system/webapp.service << EOF
[Unit]
Description=Demo Web Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Environment=INSTANCE_ID=$INSTANCE_ID
Environment=ENVIRONMENT=${environment}
Environment=PYTHONUNBUFFERED=1
WorkingDirectory=/opt/webapp
ExecStart=/usr/bin/python3 /opt/webapp/app.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=webapp

[Install]
WantedBy=multi-user.target
EOF

echo "Systemd service file created"

# Create helper scripts
cat > /opt/webapp/trigger-unhealthy.sh << 'EOF'
#!/bin/bash
curl -s http://localhost/simulate/unhealthy
echo ""
echo "Health check will now fail. ALB will mark instance as unhealthy."
EOF
chmod +x /opt/webapp/trigger-unhealthy.sh

cat > /opt/webapp/trigger-crash.sh << 'EOF'
#!/bin/bash
curl -s http://localhost/simulate/crash
echo ""
echo "Application will crash in 5 seconds."
EOF
chmod +x /opt/webapp/trigger-crash.sh

cat > /opt/webapp/restore-healthy.sh << 'EOF'
#!/bin/bash
curl -s http://localhost/simulate/healthy
echo ""
echo "Health check restored to healthy."
EOF
chmod +x /opt/webapp/restore-healthy.sh

# Start service
echo "Starting webapp service..."
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp

# Wait for service to start
sleep 3

# Verify service is running
if systemctl is-active --quiet webapp; then
  echo "Webapp service is running"
else
  echo "ERROR: Webapp service failed to start"
  journalctl -u webapp -n 50
fi

# Verify the app responds
for i in {1..10}; do
  if curl -s http://localhost/health > /dev/null 2>&1; then
    echo "Health check endpoint is responding"
    break
  else
    echo "Waiting for app to respond (attempt $i/10)..."
    sleep 2
  fi
done

# Signal completion
echo "Setup complete at $(date)" > /opt/webapp/setup-complete
echo "UserData script completed successfully"
