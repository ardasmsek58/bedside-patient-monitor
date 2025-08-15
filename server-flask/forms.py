from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Length, Email, EqualTo, ValidationError
import sqlite3

class LoginForm(FlaskForm):
    username = StringField('Kullanıcı Adı', validators=[DataRequired(), Length(min=3, max=25)])
    password = PasswordField('Şifre', validators=[DataRequired()])
    submit = SubmitField('Giriş Yap')

class RegisterForm(FlaskForm):
    username = StringField('Kullanıcı Adı', validators=[DataRequired(), Length(min=3, max=25)])
    email = StringField('E-Posta', validators=[DataRequired(), Email()])
    password = PasswordField('Şifre', validators=[DataRequired(), Length(min=8)])
    confirm_password = PasswordField('Şifre Tekrar', validators=[
        DataRequired(), EqualTo('password', message='Şifreler eşleşmiyor.')
    ])
    submit = SubmitField('Kayıt Ol')

    def validate_username(self, username):
        """Kullanıcı adının daha önce alınmış olup olmadığını kontrol eder"""
        with sqlite3.connect("veriler.db") as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id FROM users WHERE username = ?", (username.data,))
            user = cursor.fetchone()
            if user:
                raise ValidationError('Bu kullanıcı adı zaten alınmış. Lütfen farklı bir kullanıcı adı seçin.')

    def validate_email(self, email):
        """E-posta adresinin daha önce kayıtlı olup olmadığını kontrol eder"""
        with sqlite3.connect("veriler.db") as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id FROM users WHERE email = ?", (email.data,))
            user = cursor.fetchone()
            if user:
                raise ValidationError('Bu e-posta adresi zaten kayıtlı. Lütfen farklı bir e-posta adresi kullanın.')

    def validate_password(self, password):
        """Şifre güvenlik kurallarını kontrol eder"""
        password_str = password.data
        
        # En az bir büyük harf
        if not any(c.isupper() for c in password_str):
            raise ValidationError('Şifre en az bir büyük harf içermelidir.')
        
        # En az bir küçük harf
        if not any(c.islower() for c in password_str):
            raise ValidationError('Şifre en az bir küçük harf içermelidir.')
        
        # En az bir rakam
        if not any(c.isdigit() for c in password_str):
            raise ValidationError('Şifre en az bir rakam içermelidir.')
        
        # En az bir özel karakter
        special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        if not any(c in special_chars for c in password_str):
            raise ValidationError('Şifre en az bir özel karakter içermelidir (!@#$%^&* vb.).')

class PasswordResetRequestForm(FlaskForm):
    """Şifre sıfırlama talebi formu (gelecekte kullanım için)"""
    email = StringField('E-Posta', validators=[DataRequired(), Email()])
    submit = SubmitField('Şifre Sıfırlama Bağlantısı Gönder')

class PasswordResetForm(FlaskForm):
    """Şifre sıfırlama formu (gelecekte kullanım için)"""
    password = PasswordField('Yeni Şifre', validators=[DataRequired(), Length(min=8)])
    confirm_password = PasswordField('Yeni Şifre Tekrar', validators=[
        DataRequired(), EqualTo('password', message='Şifreler eşleşmiyor.')
    ])
    submit = SubmitField('Şifreyi Sıfırla')

class ProfileUpdateForm(FlaskForm):
    """Profil güncelleme formu (gelecekte kullanım için)"""
    username = StringField('Kullanıcı Adı', validators=[DataRequired(), Length(min=3, max=25)])
    email = StringField('E-Posta', validators=[DataRequired(), Email()])
    submit = SubmitField('Profili Güncelle')

    def __init__(self, original_username, original_email, *args, **kwargs):
        super(ProfileUpdateForm, self).__init__(*args, **kwargs)
        self.original_username = original_username
        self.original_email = original_email

    def validate_username(self, username):
        if username.data != self.original_username:
            with sqlite3.connect("veriler.db") as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT id FROM users WHERE username = ?", (username.data,))
                user = cursor.fetchone()
                if user:
                    raise ValidationError('Bu kullanıcı adı zaten alınmış. Lütfen farklı bir kullanıcı adı seçin.')

    def validate_email(self, email):
        if email.data != self.original_email:
            with sqlite3.connect("veriler.db") as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT id FROM users WHERE email = ?", (email.data,))
                user = cursor.fetchone()
                if user:
                    raise ValidationError('Bu e-posta adresi zaten kayıtlı. Lütfen farklı bir e-posta adresi kullanın.')



class OTPForm(FlaskForm):
    otp_code = StringField('Doğrulama Kodu', validators=[
        DataRequired(message="Kod gerekli."),
        Length(min=6, max=6, message="6 haneli bir kod girin.")
    ])
    submit = SubmitField('Doğrula')
