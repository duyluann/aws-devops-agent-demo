"""
Auto-shutdown Lambda function for ALB Health Check Demo.
Stops EC2 instances after a specified time to save costs.
"""

import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Lambda handler to stop EC2 instances.

    Environment variables:
        INSTANCE_IDS: Comma-separated list of instance IDs to stop
    """
    ec2 = boto3.client("ec2")

    instance_ids_str = os.environ.get("INSTANCE_IDS", "")
    if not instance_ids_str:
        logger.warning("No INSTANCE_IDS environment variable set")
        return {"statusCode": 400, "body": "No instance IDs configured"}

    instance_ids = [id.strip() for id in instance_ids_str.split(",") if id.strip()]

    if not instance_ids:
        logger.warning("No valid instance IDs found")
        return {"statusCode": 400, "body": "No valid instance IDs"}

    logger.info(f"Stopping instances: {instance_ids}")

    try:
        response = ec2.stop_instances(InstanceIds=instance_ids)
        stopping_instances = [
            i["InstanceId"] for i in response.get("StoppingInstances", [])
        ]
        logger.info(f"Successfully initiated stop for: {stopping_instances}")
        return {
            "statusCode": 200,
            "body": f"Stopped instances: {stopping_instances}",
        }
    except Exception as e:
        logger.error(f"Failed to stop instances: {e}")
        return {"statusCode": 500, "body": f"Error: {str(e)}"}
