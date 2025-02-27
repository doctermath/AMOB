# %%
import smtplib
import sys
import os
from dotenv import load_dotenv
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


# %%
load_dotenv()

# Email Credentials
SMTP_SERVER = os.getenv('SMTP_SERVER')
SMTP_PORT = os.getenv('SMTP_PORT')
EMAIL_ADDRESS = os.getenv('EMAIL_ADDRESS')
EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')


# %%
otp = sys.argv[1]
recipient = sys.argv[2] 

# Send OTP Email
def send_otp(recipient_email, otp):
    subject = "Your OTP Code"
    body = f"""
    <html>
    <body>
        <h2>Your OTP Code</h2>
        <p>Your OTP code is: <strong>{otp}</strong></p>
        <p>Please use this code to complete your verification process.</p>
        <br>
        <p>Thank you,</p>
        <p>Altrak1978</p>
    </body>
    </html>
    """

    msg = MIMEMultipart()
    msg["From"] = EMAIL_ADDRESS
    msg["To"] = recipient_email
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "html"))

    with smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT) as server:
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.sendmail(EMAIL_ADDRESS, recipient_email, msg.as_string())

    print(f"OTP sent to {recipient_email}: {otp}")

# Example Usage
send_otp(recipient, otp)



