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
sudo yum update -y || echo "yum update had some issues, continuing..."

# Install Python packages including pip and setuptools
sudo yum install -y python3-pip python3 python3-setuptools jq

# Install boto3 using pip with --user flag
pip3 install boto3 --user

# Verify boto3 is available
python3 -c "import boto3; print('boto3 version:', boto3.__version__)" || {
  echo "ERROR: boto3 installation failed"
  exit 1
}

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
import boto3
from botocore.exceptions import ClientError

# CloudWatch metrics client
try:
    cloudwatch = boto3.client('cloudwatch')
    metrics_enabled = True
    print("CloudWatch metrics publishing enabled")
except Exception as e:
    print(f"Warning: CloudWatch client initialization failed: {e}")
    metrics_enabled = False

# Metric configuration
METRIC_NAMESPACE = "CustomApp/HealthDemo"

# Health status control (shared state)
health_status = {"healthy": True, "reason": "OK", "last_updated": datetime.now().isoformat()}

def publish_health_metric():
    """Publish current health status to CloudWatch"""
    if not metrics_enabled:
        return

    try:
        instance_id = os.environ.get('INSTANCE_ID', 'unknown')
        environment = os.environ.get('ENVIRONMENT', 'unknown')

        metric_data = [
            {
                'MetricName': 'HealthStatus',
                'Value': 1.0 if health_status["healthy"] else 0.0,
                'Unit': 'None',
                'Timestamp': datetime.now(),
                'Dimensions': [
                    {'Name': 'InstanceId', 'Value': instance_id},
                    {'Name': 'Environment', 'Value': environment}
                ]
            }
        ]

        cloudwatch.put_metric_data(
            Namespace=METRIC_NAMESPACE,
            MetricData=metric_data
        )
    except ClientError as e:
        print(f"Error publishing metrics: {e}")

def publish_incident_metric(incident_type):
    """Publish incident simulation count to CloudWatch"""
    if not metrics_enabled:
        return

    try:
        instance_id = os.environ.get('INSTANCE_ID', 'unknown')
        environment = os.environ.get('ENVIRONMENT', 'unknown')

        cloudwatch.put_metric_data(
            Namespace=METRIC_NAMESPACE,
            MetricData=[
                {
                    'MetricName': 'IncidentSimulations',
                    'Value': 1.0,
                    'Unit': 'Count',
                    'Timestamp': datetime.now(),
                    'Dimensions': [
                        {'Name': 'InstanceId', 'Value': instance_id},
                        {'Name': 'Environment', 'Value': environment},
                        {'Name': 'IncidentType', 'Value': incident_type}
                    ]
                }
            ]
        )
    except ClientError as e:
        print(f"Error publishing incident metric: {e}")

# Auto-recovery configuration
auto_recovery_enabled = False
recovery_timer = None

def schedule_auto_recovery(delay_seconds=60):
    """Schedule automatic health recovery after specified delay"""
    global auto_recovery_enabled, recovery_timer

    if recovery_timer:
        recovery_timer.cancel()

    def auto_recover():
        global health_status, auto_recovery_enabled
        health_status["healthy"] = True
        health_status["reason"] = "Auto-recovered"
        health_status["last_updated"] = datetime.now().isoformat()
        auto_recovery_enabled = False
        publish_health_metric()
        print(f"[{datetime.now()}] Auto-recovery executed")

    auto_recovery_enabled = True
    recovery_timer = threading.Timer(delay_seconds, auto_recover)
    recovery_timer.daemon = True
    recovery_timer.start()
    print(f"[{datetime.now()}] Auto-recovery scheduled in {delay_seconds}s")

def cancel_auto_recovery():
    """Cancel any pending auto-recovery"""
    global auto_recovery_enabled, recovery_timer
    if recovery_timer:
        recovery_timer.cancel()
    auto_recovery_enabled = False

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
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def send_html_response(self, html_content):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html_content.encode())

    def get_dashboard_html(self):
        instance_id = os.environ.get('INSTANCE_ID', 'unknown')
        environment = os.environ.get('ENVIRONMENT', 'unknown')
        status_class = 'healthy' if health_status["healthy"] else 'unhealthy'
        status_icon = '✓' if health_status["healthy"] else '✗'

        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS ALB Health Check Demo</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: #333;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}
        .header {{
            text-align: center;
            color: white;
            margin-bottom: 40px;
        }}
        .header h1 {{
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
        }}
        .header p {{
            font-size: 1.1rem;
            opacity: 0.9;
        }}
        .card {{
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }}
        .status-card {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }}
        .status-item {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px;
            border-radius: 12px;
            color: white;
        }}
        .status-item h3 {{
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.9;
            margin-bottom: 10px;
        }}
        .status-item .value {{
            font-size: 1.5rem;
            font-weight: 700;
        }}
        .health-status {{
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            font-size: 1.2rem;
            font-weight: 600;
        }}
        .health-status.healthy {{
            background: #10b981;
            color: white;
        }}
        .health-status.unhealthy {{
            background: #ef4444;
            color: white;
        }}
        .health-status .icon {{
            font-size: 2rem;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
        }}
        .section-title {{
            font-size: 1.5rem;
            margin-bottom: 20px;
            color: #1f2937;
            font-weight: 700;
        }}
        .incident-controls {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }}
        .btn {{
            padding: 15px 25px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }}
        .btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }}
        .btn:active {{
            transform: translateY(0);
        }}
        .btn-danger {{
            background: #ef4444;
            color: white;
        }}
        .btn-danger:hover {{
            background: #dc2626;
        }}
        .btn-warning {{
            background: #f59e0b;
            color: white;
        }}
        .btn-warning:hover {{
            background: #d97706;
        }}
        .btn-success {{
            background: #10b981;
            color: white;
        }}
        .btn-success:hover {{
            background: #059669;
        }}
        .api-section {{
            margin-top: 30px;
        }}
        .endpoint {{
            background: #f9fafb;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 10px;
            font-family: 'Courier New', monospace;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .endpoint code {{
            color: #667eea;
            font-weight: 600;
        }}
        .method {{
            background: #667eea;
            color: white;
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: 600;
        }}
        .footer {{
            text-align: center;
            color: white;
            margin-top: 40px;
            opacity: 0.8;
            font-size: 0.9rem;
        }}
        #message {{
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
            font-weight: 500;
        }}
        #message.success {{
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #10b981;
            display: block;
        }}
        #message.error {{
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #ef4444;
            display: block;
        }}
        @keyframes pulse {{
            0%, 100% {{ opacity: 1; }}
            50% {{ opacity: 0.5; }}
        }}
        .loading {{
            animation: pulse 1.5s ease-in-out infinite;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>AWS ALB Health Check Demo</h1>
            <p>Infrastructure Monitoring & Incident Simulation Dashboard</p>
        </div>

        <div class="card">
            <div id="message"></div>

            <div class="health-status {status_class}">
                <div>
                    <div>Health Status</div>
                    <div style="font-size: 1rem; opacity: 0.9; margin-top: 5px;">{health_status["reason"]}</div>
                </div>
                <div class="icon">{status_icon}</div>
            </div>

            <div class="status-card">
                <div class="status-item">
                    <h3>Instance ID</h3>
                    <div class="value">{instance_id[:10]}...</div>
                </div>
                <div class="status-item">
                    <h3>Environment</h3>
                    <div class="value">{environment.upper()}</div>
                </div>
                <div class="status-item">
                    <h3>Service</h3>
                    <div class="value">Demo WebApp</div>
                </div>
                <div class="status-item">
                    <h3>Last Updated</h3>
                    <div class="value" id="lastUpdated">Just now</div>
                </div>
            </div>
        </div>

        <div class="card">
            <h2 class="section-title">Incident Simulation Controls</h2>
            <p style="color: #6b7280; margin-bottom: 20px;">
                Trigger various failure scenarios to test infrastructure monitoring and auto-remediation.
            </p>

            <div class="incident-controls">
                <button class="btn btn-danger" onclick="triggerIncident('unhealthy')">
                    <span>💔</span> Trigger Unhealthy
                </button>
                <button class="btn btn-danger" onclick="triggerIncident('crash')">
                    <span>💥</span> Crash Application
                </button>
                <button class="btn btn-warning" onclick="triggerIncident('slow-health')">
                    <span>🐌</span> Slow Health Check
                </button>
                <button class="btn btn-success" onclick="triggerIncident('healthy')">
                    <span>✨</span> Restore Healthy
                </button>
            </div>
        </div>

        <div class="card">
            <h2 class="section-title">API Endpoints</h2>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/</code></div>
                <div>Service information</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/health</code></div>
                <div>ALB health check endpoint</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/status</code></div>
                <div>Current health status (JSON)</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/simulate/unhealthy</code></div>
                <div>Trigger health check failure</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/simulate/healthy</code></div>
                <div>Restore healthy status</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/simulate/crash</code></div>
                <div>Crash application (exits in 10s)</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/simulate/slow-health</code></div>
                <div>Simulate slow response times</div>
            </div>
            <div class="endpoint">
                <div><span class="method">GET</span> <code>/recovery-status</code></div>
                <div>Auto-recovery and metrics status</div>
            </div>
        </div>

        <div class="footer">
            <p>AWS ALB Health Check Demo • Built with Python • Auto-refresh every 5 seconds</p>
        </div>
    </div>

    <script>
        function showMessage(text, type) {{
            const messageEl = document.getElementById('message');
            messageEl.textContent = text;
            messageEl.className = type;
            setTimeout(() => {{
                messageEl.style.display = 'none';
            }}, 5000);
        }}

        async function triggerIncident(type) {{
            const endpoints = {{
                'unhealthy': '/simulate/unhealthy',
                'healthy': '/simulate/healthy',
                'crash': '/simulate/crash',
                'slow-health': '/simulate/slow-health'
            }};

            try {{
                const response = await fetch(endpoints[type]);
                const data = await response.json();
                showMessage(data.message, 'success');

                if (type === 'crash') {{
                    showMessage('Application will crash in 10 seconds!', 'error');
                }} else {{
                    setTimeout(refreshStatus, 1000);
                }}
            }} catch (error) {{
                showMessage('Failed to trigger incident: ' + error.message, 'error');
            }}
        }}

        async function refreshStatus() {{
            try {{
                const response = await fetch('/status');
                const data = await response.json();
                // Reload page to show updated status
                location.reload();
            }} catch (error) {{
                console.error('Failed to refresh status:', error);
            }}
        }}

        // Auto-refresh every 5 seconds
        setInterval(refreshStatus, 5000);

        // Update last updated time
        function updateTime() {{
            const now = new Date();
            document.getElementById('lastUpdated').textContent =
                now.toLocaleTimeString();
        }}
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>'''

    def do_GET(self):
        if self.path == '/':
            self.send_html_response(self.get_dashboard_html())

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

        elif self.path == '/recovery-status':
            self.send_json_response(200, {
                "auto_recovery_enabled": auto_recovery_enabled,
                "health_status": health_status,
                "metrics_enabled": metrics_enabled
            })

        elif self.path == '/simulate/unhealthy':
            health_status["healthy"] = False
            health_status["reason"] = "Simulated database connection failure"
            health_status["last_updated"] = datetime.now().isoformat()
            schedule_auto_recovery(300)  # Auto-recover in 300 seconds (5 minutes)
            publish_health_metric()
            publish_incident_metric('unhealthy')
            print(f"[{datetime.now()}] Simulated unhealthy state triggered")
            self.send_json_response(200, {
                "message": "Health check will now fail (auto-recovery in 5 minutes)",
                "reason": health_status["reason"],
                "auto_recovery": "enabled"
            })

        elif self.path == '/simulate/healthy':
            cancel_auto_recovery()  # Cancel any pending recovery
            health_status["healthy"] = True
            health_status["reason"] = "OK"
            health_status["last_updated"] = datetime.now().isoformat()
            publish_health_metric()
            print(f"[{datetime.now()}] Restored to healthy state")
            self.send_json_response(200, {
                "message": "Health check restored to healthy"
            })

        elif self.path == '/simulate/crash':
            def delayed_crash():
                time.sleep(10)  # 10 seconds - fast crash for testing
                print(f"[{datetime.now()}] Simulated crash - exiting")
                os._exit(1)
            threading.Thread(target=delayed_crash, daemon=True).start()
            self.send_json_response(200, {
                "message": "Application will crash in 10 seconds"
            })
            publish_incident_metric('crash')

        elif self.path == '/simulate/slow-health':
            health_status["healthy"] = False
            health_status["reason"] = "Health check timeout simulation"
            health_status["last_updated"] = datetime.now().isoformat()
            schedule_auto_recovery(300)  # Auto-recover in 300 seconds (5 minutes)
            publish_health_metric()
            publish_incident_metric('slow-health')
            print(f"[{datetime.now()}] Simulated slow health check")
            self.send_json_response(200, {
                "message": "Health checks will now be slow/timeout (auto-recovery in 5 minutes)",
                "auto_recovery": "enabled"
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

    # Start background metrics publisher
    def periodic_metrics_publisher():
        """Publish metrics every 60 seconds"""
        while True:
            time.sleep(60)
            publish_health_metric()

    metrics_thread = threading.Thread(target=periodic_metrics_publisher, daemon=True)
    metrics_thread.start()
    print(f"[{datetime.now()}] Periodic metrics publishing started")

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
echo "Application will crash in 10 seconds."
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
