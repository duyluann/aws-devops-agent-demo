# Incident Trigger Workflow

This workflow enables automated testing of AWS infrastructure incidents for validating DevOps agent incident response capabilities.

## Overview

The `trigger-incidents.yml` workflow simulates various failure scenarios in your AWS environment:
- Unhealthy host targets
- Application crashes
- Slow response times
- HTTP 5xx error floods
- Instance shutdowns

The workflow integrates with CloudWatch alarms and can automatically restore healthy state after testing.

## Prerequisites

### Required AWS Permissions

Ensure your AWS credentials have the following IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ssm:SendCommand",
        "ssm:DescribeInstanceInformation",
        "ssm:GetCommandInvocation",
        "lambda:InvokeFunction",
        "cloudwatch:DescribeAlarms",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
```

### Required GitHub Secrets

Configure these secrets in your repository settings:
- `AWS_ACCESS_KEY_ID` - IAM user/role access key
- `AWS_SECRET_ACCESS_KEY` - IAM secret key
- `AWS_REGION` - AWS region (e.g., ap-southeast-1)

### Infrastructure Requirements

Your environment must have:
- ✅ EC2 instances with SSM Session Manager enabled
- ✅ Application Load Balancer configured
- ✅ CloudWatch alarms enabled (`enable_monitoring = true`)
- ✅ Python web server running with simulation endpoints

## Usage

### Triggering an Incident

1. Navigate to **Actions** → **Trigger Incidents for DevOps Agent Testing**
2. Click **Run workflow**
3. Configure parameters:
   - **Environment**: dev, qa, or prod
   - **Incident Type**: Select from available incident types
   - **Target Instance Index**: Which instance to affect (0 = first, 1 = second)
   - **Restore After Incident**: Enable automatic restoration
   - **Restore Delay**: Seconds to wait before restoring (default: 300)
   - **Wait for Alarm**: Monitor CloudWatch alarm state transition
4. Click **Run workflow**

### Incident Types

#### 1. Unhealthy Host (`unhealthy_host`)
Makes a single EC2 instance fail health checks.

**Triggers**: Unhealthy host count alarm
**Expected Time to Alarm**: 2-3 minutes
**Use Case**: Test single host failure detection

#### 2. Unhealthy All (`unhealthy_all`)
Makes all EC2 instances fail health checks simultaneously.

**Triggers**: Unhealthy host count alarm
**Expected Time to Alarm**: 2-3 minutes
**Use Case**: Test total service outage detection

#### 3. Crash Instance (`crash_instance`)
Crashes the application on a target instance (exits after 5 minutes).

**Triggers**: Unhealthy host count alarm
**Expected Time to Alarm**: 2-4 minutes
**Use Case**: Test application crash detection and recovery

#### 4. Slow Health (`slow_health`)
Triggers slow response times on health check endpoint.

**Triggers**: High response time alarm
**Expected Time to Alarm**: 2-3 minutes
**Use Case**: Test performance degradation detection

#### 5. Shutdown Instances (`shutdown_instances`)
Invokes auto-shutdown Lambda to stop all EC2 instances.

**Triggers**: All alarms (eventually)
**Expected Time to Alarm**: 3-5 minutes
**Use Case**: Test complete infrastructure shutdown detection
**Note**: Requires `enable_auto_shutdown = true`

#### 6. HTTP 5xx Flood (`http_5xx_flood`)
Generates 15 concurrent 5xx errors through the ALB.

**Triggers**: HTTP 5xx errors alarm
**Expected Time to Alarm**: 2-3 minutes
**Use Case**: Test error rate spike detection

## Workflow Steps

### 1. Infrastructure Discovery
Automatically discovers:
- ALB DNS name and URL
- EC2 instance IDs
- Auto-shutdown Lambda ARN (if enabled)
- CloudWatch alarm names

Uses Terraform outputs for reliable infrastructure state.

### 2. Pre-flight Health Check
Validates infrastructure before triggering incident:
- Checks EC2 instance states
- Verifies ALB target health
- Ensures instances are running

### 3. Incident Trigger
Executes the selected incident type:
- Uses AWS SSM Session Manager for instance commands
- Sends commands to application simulation endpoints
- Records incident timestamp

### 4. CloudWatch Alarm Monitoring
If enabled, monitors alarm state transition:
- Polls every 30 seconds
- Timeout after 5 minutes
- Reports alarm trigger time

### 5. Auto-Restore (Optional)
If enabled, restores healthy state:
- Waits specified delay period
- Executes restoration commands
- Starts stopped instances (for shutdown incident)

### 6. Summary Generation
Creates detailed GitHub Actions summary:
- Configuration details
- Infrastructure information
- Timeline of events
- Next steps for verification

## Example Scenarios

### Scenario 1: Test Single Host Failure
```yaml
environment: dev
incident_type: unhealthy_host
target_instance_index: 0
restore_after_incident: true
restore_delay_seconds: 300
wait_for_alarm: true
```

**Expected Result**: One instance fails, alarm triggers, auto-restores after 5 minutes.

### Scenario 2: Test Application Crash
```yaml
environment: qa
incident_type: crash_instance
target_instance_index: 1
restore_after_incident: false
wait_for_alarm: true
```

**Expected Result**: Application crashes on second instance, alarm triggers, manual restoration required.

### Scenario 3: Test Performance Degradation
```yaml
environment: dev
incident_type: slow_health
target_instance_index: 0
restore_after_incident: true
restore_delay_seconds: 180
wait_for_alarm: true
```

**Expected Result**: Slow responses trigger high response time alarm, auto-restores after 3 minutes.

## Verification

### Check Incident Impact

**CloudWatch Alarms**:
```bash
aws cloudwatch describe-alarms \
  --alarm-names "<alarm-name-from-output>" \
  --query 'MetricAlarms[0].[AlarmName,StateValue,StateUpdatedTimestamp]' \
  --output table
```

**ALB Target Health**:
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
  --output table
```

**Manual Status Check**:
```bash
# Get ALB URL from Terraform output
ALB_URL=$(terraform output -raw alb_url)

# Check application status
curl ${ALB_URL}/status

# Trigger unhealthy (for testing)
curl ${ALB_URL}/simulate/unhealthy

# Restore healthy
curl ${ALB_URL}/simulate/healthy
```

### Monitor DevOps Agent Response

1. Check agent logs for incident detection
2. Verify automatic remediation actions
3. Validate alert notifications
4. Review agent response timeline

## Safety Considerations

### Production Protection
- Workflow requires environment approval for `prod`
- Configure approval rules in Settings → Environments
- Require manual approval before running production incidents

### Automatic Safeguards
- **Timeout**: Workflow stops after 15 minutes
- **Pre-flight Checks**: Validates infrastructure health first
- **Cleanup on Failure**: Attempts restoration if workflow fails
- **Audit Trail**: All actions logged in GitHub Actions

### Best Practices
1. **Test in dev first**: Always test new incident types in dev environment
2. **Schedule testing**: Run during low-traffic periods
3. **Monitor actively**: Watch alarms and agent logs during testing
4. **Document results**: Record agent response times and behaviors
5. **Enable auto-restore**: Use for automated testing scenarios
6. **Disable auto-restore**: Use when manually validating agent actions

## Troubleshooting

### Issue: "Could not discover infrastructure"
**Solution**: Ensure Terraform state is initialized and infrastructure is deployed:
```bash
terraform apply -var-file=environments/dev/dev.tfvars
```

### Issue: "Instance not running"
**Solution**: Check EC2 instance state and start if stopped:
```bash
aws ec2 describe-instances --instance-ids <instance-id>
aws ec2 start-instances --instance-ids <instance-id>
```

### Issue: "SSM command failed"
**Solution**: Verify SSM agent is running and instance has proper IAM role:
```bash
aws ssm describe-instance-information --instance-ids <instance-id>
```

### Issue: "Auto-shutdown Lambda not enabled"
**Solution**: Enable auto-shutdown in environment tfvars:
```hcl
enable_auto_shutdown = true
```

### Issue: "Alarm did not trigger"
**Solution**: Check alarm configuration and wait longer (up to 5 minutes):
```bash
aws cloudwatch describe-alarms --alarm-names <alarm-name>
```

## Integration with DevOps Agents

### Testing Agent Capabilities

Use this workflow to validate:
1. **Incident Detection**: How quickly does the agent detect the issue?
2. **Alert Generation**: Are notifications sent appropriately?
3. **Automatic Remediation**: Does the agent take corrective action?
4. **Escalation**: Are escalations triggered when needed?
5. **Recovery Validation**: Does the agent verify recovery?

### Expected Agent Behavior

For each incident type, your DevOps agent should:
- Detect CloudWatch alarm state change
- Correlate alarm with affected resources
- Execute appropriate remediation actions
- Validate service recovery
- Generate incident report

## Timelines Reference

| Event | Expected Duration |
|-------|------------------|
| Workflow start → Incident trigger | 30-60 seconds |
| Incident trigger → ALB detection | 30-90 seconds |
| ALB detection → CloudWatch alarm | 60-120 seconds |
| **Total: Trigger → Alarm** | **2-4 minutes** |
| Auto-restore delay (default) | 5 minutes |
| Workflow timeout (max) | 15 minutes |

## Related Files

- **Workflow**: `.github/workflows/trigger-incidents.yml`
- **Outputs**: `outputs.tf` (cloudwatch_alarm_names, auto_shutdown_lambda_arn)
- **Monitoring**: `monitoring.tf` (alarm definitions)
- **Auto-shutdown**: `auto_shutdown.tf` (Lambda function)
- **User Data**: `templates/userdata.sh.tpl` (simulation endpoints)

## Support

For issues or questions:
1. Check workflow run logs in GitHub Actions
2. Review CloudWatch alarm history
3. Verify infrastructure state with `terraform output`
4. Check AWS CloudWatch Logs for Lambda/application logs
5. Open an issue in the repository

---

**Version**: 1.0.0
**Last Updated**: 2026-01-23
