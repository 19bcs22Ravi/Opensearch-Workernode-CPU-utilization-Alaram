import json
import http.client
import os

def lambda_handler(event, context):
    try:
        # Extract information from the CloudWatch event
        alarm_name = "OpenSearchWorkerNodesCPUAlarm"
        description = "Worker node CPU utilization reached 80%"
        
        # Define the message to send to Slack
        message = f"CloudWatch Alarm '{alarm_name}': {description}"
        
        # Define the Slack webhook URL
        slack_webhook_url = "https://hooks.slack.com/services/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"
        
        # Construct the payload to send to Slack
        payload = json.dumps({'text': message})
        
        # Establish a connection to the Slack webhook
        conn = http.client.HTTPSConnection("hooks.slack.com")
        
        # Send the message to Slack
        conn.request("POST", slack_webhook_url, body=payload, headers={'Content-type': 'application/json'})
        response = conn.getresponse()
        
        if response.status != 200:
            raise Exception(f"Failed to send message to Slack: {response.read().decode()}")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Message sent to Slack successfully')
        }
    except Exception as e:
        # Handle exceptions
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
