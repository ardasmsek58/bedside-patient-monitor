import secrets
import smtplib
import ssl
from email.message import EmailMessage
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv


load_dotenv()


EMAIL_ADDRESS = os.getenv("EMAIL_ADDRESS")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")


if not EMAIL_ADDRESS or not EMAIL_PASSWORD:
    raise ValueError("❌ EMAIL_ADDRESS veya EMAIL_PASSWORD .env dosyasından okunamadı.")

# Geçici OTP veritabanı (test amaçlı)
otp_store = {}

# 6 haneli OTP üret
def generate_otp():
    return secrets.randbelow(900000) + 100000


def send_otp_email(to_email, otp, username):
    smtp_server = "smtp.gmail.com"
    smtp_port = 587

    message = EmailMessage()
    message["Subject"] = "VitaScope Hesap Aktivasyon Kodu"
    message["From"] = EMAIL_ADDRESS
    message["To"] = to_email
    message.set_content(
        f"""
Merhaba {username},

VitaScope hesabınızı aktifleştirmek için doğrulama kodunuz: {otp}

Bu kod 5 dakika boyunca geçerlidir.

VitaScope Ekibi
        """
    )

    try:
        context = ssl.create_default_context()
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls(context=context)
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.send_message(message)
        print("✅ OTP e-postası başarıyla gönderildi.")
        return True
    except Exception as e:
        print(f"❌ OTP gönderilemedi: {e}")
        return False

# OTP saklama
def store_otp(email, otp):
    otp_store[email] = {
        "otp": str(otp),
        "expires_at": datetime.now() + timedelta(minutes=5)
    }

# OTP doğrulama
def verify_otp(email, user_input):
    if email not in otp_store:
        return False
    record = otp_store[email]
    if datetime.now() > record["expires_at"]:
        del otp_store[email]
        return False
    if record["otp"] == str(user_input):
        del otp_store[email]
        return True
    return False
