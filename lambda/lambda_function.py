import json
import urllib3
import os

http = urllib3.PoolManager()

BOT_TOKEN = os.environ['BOT_TOKEN']
CHAT_ID = os.environ['CHAT_ID']

def lambda_handler(event, context):

sns_message = json.loads(event['Records'][0]['Sns']['Message'])

alarm_name = sns_message['AlarmName']
reason = sns_message['NewStateReason']
state = sns_message['NewStateValue']
time = sns_message['StateChangeTime']

text = f"""
🚨 AWS CLOUDWATCH ALERT 🚨

Alarm: {alarm_name}

State: {state}

Reason:
{reason}

Time:
{time}
"""

    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

    payload = {
        "chat_id": CHAT_ID,
        "text": text
    }

    response = http.request(
        "POST",
        url,
        body=json.dumps(payload),
        headers={"Content-Type": "application/json"}
    )

    return {
        "statusCode": response.status,
        "body": "Message sent"
    }