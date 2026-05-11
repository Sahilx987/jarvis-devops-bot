from google import genai
from config import GEMINI_API_KEY

client = genai.Client(api_key=GEMINI_API_KEY)


def ask_ai(prompt):

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=f"""
You are Jarvis AI.

You are a DevOps and Cloud assistant.

Your personality:
- Speak naturally
- Human-like
- Helpful
- Technical but easy to understand

You help with:
- AWS
- Linux
- Docker
- Kubernetes
- DevOps
- Python
- Automation

User message:
{prompt}
"""
    )

    return response.text