from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired, Length, Regexp

class OTPForm(FlaskForm):
    otp_code = StringField('Doğrulama Kodu', validators=[
        DataRequired(message="Kod boş bırakılamaz."),
        Length(min=6, max=6, message="Kod 6 haneli olmalıdır."),
        Regexp('^[0-9]{6}$', message="Kod sadece rakamlardan oluşmalıdır.")
    ])
    submit = SubmitField('Doğrula')

