# Server (Flask Backend)

Bu klasör, hasta başı monitör sisteminin web arayüzü ve API'sini sağlayan Flask tabanlı backend uygulamasını içerir.

## İçerik
- **app.py** — Flask uygulamasının giriş noktası.
- **forms.py** — Flask-WTF formları.
- **otp.py** — Tek kullanımlık şifre (OTP) üretimi ve doğrulama.
- **otp_form.py** — OTP form işlemleri.
- **veriler.db** — Örnek SQLite veritabanı.
- **templates/** — HTML şablon dosyaları.
- **static/** — CSS ve JS dosyaları.

## Ortam Değişkenleri (.env)
Gizli bilgiler `.env` dosyasında saklanır ve `python-dotenv` kütüphanesi ile yüklenir.

Örnek `.env` dosyası:
```env
SECRET_KEY=flask_secret_key
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
EMAIL_ADDRESS=example@gmail.com
EMAIL_PASSWORD=uygulama_sifresi
