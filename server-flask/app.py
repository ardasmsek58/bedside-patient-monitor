from flask import Flask, request, jsonify, render_template, redirect, url_for, flash, session
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from flask_bcrypt import Bcrypt
from forms import LoginForm, RegisterForm, OTPForm
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from dotenv import load_dotenv
from itsdangerous import URLSafeTimedSerializer
import sqlite3
import random
import smtplib
import os
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from otp import send_otp_email
from flask_cors import CORS

load_dotenv()


app = Flask(__name__, static_folder='templates/static', template_folder='templates', static_url_path='/static')
app.secret_key = os.getenv("SECRET_KEY")
bcrypt = Bcrypt(app)
DB_FILE = "veriler.db"

limiter = Limiter(get_remote_address, app=app, default_limits=[])

login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.init_app(app)

SMTP_SERVER = os.getenv("MAIL_SERVER")
SMTP_PORT = int(os.getenv("MAIL_PORT"))
SENDER_EMAIL = os.getenv("EMAIL_ADDRESS")
SENDER_PASSWORD = os.getenv("EMAIL_PASSWORD")

serializer = URLSafeTimedSerializer(app.secret_key)

class User(UserMixin):
    def __init__(self, id_, username, email, password_hash=None):
        self.id = id_
        self.username = username
        self.email = email
        self.password = password_hash


@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    user = conn.execute("SELECT * FROM users WHERE id = ?", (user_id,)).fetchone()
    conn.close()
    
    # Eğer kullanıcı verisi yoksa ya da doğrulanmamışsa
    if not user or not user['is_verified']:
        return None
    
    return User(id_=user["id"], username=user["username"], email=user["email"])


def get_db_connection():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL,
                is_verified INTEGER DEFAULT 0
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS measurements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                deviceId TEXT,
                heartRate INTEGER,
                spo2 INTEGER,
                resp INTEGER
            )
        ''')
        conn.commit()


def generate_confirmation_token(email):
    return serializer.dumps(email, salt='email-confirm-salt')


def confirm_token(token, expiration=3600):
    try:
        return serializer.loads(token, salt='email-confirm-salt', max_age=expiration)
    except Exception:
        return None


def send_verification_email(recipient_email, token):
    link = url_for('activate_account', token=token, _external=True)
    body = f"""Merhaba,

Hesabınızı aktifleştirmek için aşağıdaki bağlantıya tıklayın:

{link}

Bu bağlantı 1 saat boyunca geçerlidir.

Sağlıklı günler,
VitaScope Ekibi"""
    msg = MIMEText(body, 'plain', 'utf-8')
    msg['Subject'] = "VitaScope Hesap Aktivasyonu"
    msg['From'] = SENDER_EMAIL
    msg['To'] = recipient_email

    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.send_message(msg)
        return True
    except Exception as e:
        print(f"E-posta gönderilemedi: {e}")
        return False


@app.route('/activate/<token>')
def activate_account(token):
    email = confirm_token(token)
    if not email:
        flash("Aktivasyon bağlantısı geçersiz veya süresi dolmuş.", "danger")
        return redirect(url_for('login'))

    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
        user = cursor.fetchone()

        if user and not user[4]:
            cursor.execute("UPDATE users SET is_verified = 1 WHERE email = ?", (email,))
            conn.commit()
            flash("Hesabınız aktifleştirildi. Giriş yapabilirsiniz.", "success")
        else:
            flash("Zaten aktif veya kullanıcı bulunamadı.", "warning")
    return redirect(url_for('login'))


# Ana sayfa - Dashboard
@app.route("/")
@login_required
def index():
    return render_template("index.html")


# Dashboard route (alternatif erişim)
@app.route('/dashboard')
@login_required
def dashboard():
    return render_template("index.html")


# Kayıt sayfası
@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegisterForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        hash_pw = bcrypt.generate_password_hash(password).decode('utf-8')

        try:
            with sqlite3.connect(DB_FILE) as conn:
                cursor = conn.cursor()
                cursor.execute("INSERT INTO users (username, email, password) VALUES (?, ?, ?)", (username, email, hash_pw))
                conn.commit()

            token = generate_confirmation_token(email)
            send_verification_email(email, token)
            flash(f"{email} adresine aktivasyon bağlantısı gönderildi. Lütfen e-postanızı kontrol edin.", "info")
            return redirect(url_for('login'))
        except sqlite3.IntegrityError as e:
            if "username" in str(e):
                flash("Bu kullanıcı adı zaten mevcut.", "danger")
            elif "email" in str(e):
                flash("Bu e-posta adresi zaten kayıtlı.", "danger")
            else:
                flash("Kayıt sırasında hata oluştu.", "danger")
    return render_template('register.html', form=form)


# Giriş sayfası
@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("10 per hour")
def login():
    # Zaten giriş yapmış kullanıcıları dashboard'a yönlendir
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    
    form = LoginForm()
    if form.validate_on_submit():
        username = form.username.data
        password = form.password.data

        with sqlite3.connect(DB_FILE) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
            user = cursor.fetchone()

        if user:
            if not user[4]:  # is_verified kontrolü
                flash("Hesabınız henüz aktifleştirilmemiş. Lütfen e-postanızı kontrol edin.", "warning")
                return redirect(url_for('login'))
            
            if bcrypt.check_password_hash(user[3], password):
                user_id, user_username, user_email = user[0], user[1], user[2]
                otp_code = '{:06d}'.format(random.randint(0, 999999))

                # Session verilerini ayarla
                session['otp_code'] = otp_code
                session['user_id'] = user_id
                session['username'] = user_username
                session['user_email'] = user_email

                if send_otp_email(user_email, otp_code, user_username):
                    flash(f"Doğrulama kodu {user_email} adresine gönderildi.", "info")
                    return redirect(url_for('verify_otp'))
                else:
                    flash("OTP e-postası gönderilemedi. Lütfen tekrar deneyin.", "danger")
                    return redirect(url_for('login'))
            else:
                flash("Geçersiz kullanıcı adı veya şifre.", "danger")
        else:
            flash("Geçersiz kullanıcı adı veya şifre.", "danger")
    
    return render_template('login.html', form=form)


# OTP doğrulama
@app.route('/verify-otp', methods=['GET', 'POST'])
@limiter.limit("5 per 5 minutes")
def verify_otp():
    form = OTPForm()

    if 'otp_code' not in session or 'user_id' not in session:
        flash("Oturum süresi doldu. Tekrar giriş yapın.", "warning")
        return redirect(url_for('login'))

    if form.validate_on_submit():
        entered_code = form.otp_code.data
        if entered_code == session.get('otp_code'):
            with sqlite3.connect(DB_FILE) as conn:
                conn.row_factory = sqlite3.Row
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM users WHERE id = ?", (session['user_id'],))
                user = cursor.fetchone()

            if user:
                user_obj = User(id_=user['id'], username=user['username'], email=user['email'])
                login_user(user_obj, remember=False)

                # Sadece OTP ile ilgili session verilerini temizle
                session.pop('otp_code', None)
                session.pop('user_id', None)
                session.pop('username', None)
                session.pop('user_email', None)
                
                flash(f"Hoş geldiniz {user['username']}! Giriş başarılı.", "success")
                return redirect(url_for('index'))
            else:
                flash("Kullanıcı bulunamadı.", "danger")
        else:
            flash("Doğrulama kodu hatalı. Lütfen tekrar deneyin.", "danger")

    user_email = session.get('user_email', '')
    return render_template('otp.html', form=form, user_email=user_email)


# OTP yeniden gönder
@app.route('/resend-otp', methods=['POST'])
def resend_otp():
    if 'user_id' not in session or 'user_email' not in session:
        return jsonify({"status": "error", "message": "Oturum süresi doldu"}), 400

    new_otp = '{:06d}'.format(random.randint(0, 999999))
    session['otp_code'] = new_otp

    if send_otp_email(session['user_email'], new_otp, session['username']):
        return jsonify({"status": "success", "message": f"Yeni kod {session['user_email']} adresine gönderildi"})
    return jsonify({"status": "error", "message": "E-posta gönderilemedi"}), 500


# Çıkış
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash("Çıkış yapıldı. Görüşmek üzere!", "info")
    return redirect(url_for('login'))


# API: Sensor verilerini al
@app.route('/api/data', methods=['POST'])
def receive_data():
    data = request.json
    print("✅ Veri alındı:", data)
    try:
        timestamp = data.get("timestamp", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        deviceId = data.get("deviceId", "unknown")
        heartRate = int(data.get("heartRate", 0))
        spo2 = int(data.get("spo2", 0))
        resp = int(data.get("resp", 0))
    except ValueError:
        return jsonify({"status": "invalid"}), 400

    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO measurements (timestamp, deviceId, heartRate, spo2, resp)
            VALUES (?, ?, ?, ?, ?)
        ''', (timestamp, deviceId, heartRate, spo2, resp))
        conn.commit()

    return jsonify({"status": "success"}), 200


# API: Canlı veri al
@app.route('/get_live_data', methods=['GET'])
def get_live_data():
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            SELECT timestamp, heartRate, spo2, resp
            FROM measurements
            ORDER BY id DESC
            LIMIT 1
        ''')
        row = cursor.fetchone()

    if row:
        timestamp_str = row[0]
        heart_rate = row[1]
        spo2 = row[2]
        resp = row[3]
        
        # VERİ GEÇERLİLİK KONTROLÜ
        if (heart_rate is None or spo2 is None or resp is None or
            heart_rate == 0 or spo2 == 0 or resp == 0 or
            heart_rate < 30 or heart_rate > 200 or
            spo2 < 70 or spo2 > 100 or
            resp < 5 or resp > 50):
            
            return jsonify({
                "timestamp": "",
                "heartRate": "--",
                "spo2": "--",
                "resp": "--"
            })
        
        # ZAMAN KONTROLÜ
        try:
            current_time = datetime.now()
            
            try:
                last_time = datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
            except ValueError:
                try:
                    last_time = datetime.fromisoformat(timestamp_str.replace('T', ' ').replace('Z', ''))
                except ValueError:
                    return jsonify({
                        "timestamp": timestamp_str,
                        "heartRate": heart_rate,
                        "spo2": spo2,
                        "resp": resp
                    })
            
            time_difference = (current_time - last_time).total_seconds()
            
            # 30 saniyeden eski veri
            if time_difference > 30:
                return jsonify({
                    "timestamp": "",
                    "heartRate": "--",
                    "spo2": "--",
                    "resp": "--"
                })
            
            return jsonify({
                "timestamp": timestamp_str,
                "heartRate": heart_rate,
                "spo2": spo2,
                "resp": resp
            })
            
        except Exception as e:
            print(f"Zaman kontrolü hatası: {e}")
            return jsonify({
                "timestamp": timestamp_str,
                "heartRate": heart_rate,
                "spo2": spo2,
                "resp": resp
            })
    else:
        return jsonify({
            "timestamp": "",
            "heartRate": "--",
            "spo2": "--",
            "resp": "--"
        })


# API: Ölçüm geçmişi
@app.route('/api/measurements', methods=['GET'])
def get_measurements():
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute('SELECT timestamp, heartRate, spo2, resp FROM measurements ORDER BY id DESC LIMIT 1')
        last_row = cursor.fetchone()

        if not last_row:
            return jsonify({'status': 'no_data'})

        last_time = datetime.strptime(last_row[0], "%Y-%m-%d %H:%M:%S")
        if (datetime.now() - last_time) > timedelta(seconds=15):
            return jsonify({'status': 'disconnected'})

        cursor.execute('SELECT timestamp, heartRate, spo2, resp FROM measurements ORDER BY id DESC LIMIT 100')
        rows = cursor.fetchall()

    rows.reverse()
    return jsonify({
        'status': 'connected',
        'labels': [r[0] for r in rows],
        'heartRate': [r[1] for r in rows],
        'spo2': [r[2] for r in rows],
        'resp': [r[3] for r in rows],  
    })


# API: Kullanıcı profili
@app.route('/api/profile')
@login_required
def get_profile():
    return jsonify({
        "username": current_user.username,
        "email": current_user.email,
        "id": current_user.id
    })


# Debug: Kullanıcı listesi
@app.route('/debug/users')
def debug_users():
    if not app.debug:
        return jsonify({"error": "Yetkisiz"}), 403
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id, username, email, is_verified FROM users")
        users = cursor.fetchall()
    return jsonify({"users": users})


if __name__ == '__main__':
    init_db()
    print("🚀 VitaScope başlatılıyor...")
    app.run(debug=True)
