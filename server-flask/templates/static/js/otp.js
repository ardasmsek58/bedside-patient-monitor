
        let countdownTimer;
        let timeLeft = 60;
        
        // OTP input'una sadece rakam girişi
        document.getElementById('otp_code').addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '');
        });

        // OTP yeniden gönder fonksiyonu
        function resendOTP() {
            const resendLink = document.getElementById('resendLink');
            const timer = document.getElementById('timer');
            const countdown = document.getElementById('countdown');
            
            // Eğer zaten sayaç çalışıyorsa işlem yapma
            if (resendLink.classList.contains('disabled')) {
                return;
            }
            
            // AJAX ile OTP yeniden gönder
            fetch('/resend-otp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    // Başarılı mesaj göster
                    showFlashMessage(data.message, 'success');
                    
                    // Link'i devre dışı bırak ve sayaç başlat
                    resendLink.classList.add('disabled');
                    timer.style.display = 'block';
                    timeLeft = 60;
                    countdown.textContent = timeLeft;
                    
                    countdownTimer = setInterval(() => {
                        timeLeft--;
                        countdown.textContent = timeLeft;
                        
                        if (timeLeft <= 0) {
                            clearInterval(countdownTimer);
                            resendLink.classList.remove('disabled');
                            timer.style.display = 'none';
                        }
                    }, 1000);
                } else {
                    showFlashMessage(data.message, 'danger');
                }
            })
            .catch(error => {
                showFlashMessage('Bir hata oluştu. Lütfen tekrar deneyin.', 'danger');
                console.error('Error:', error);
            });
        }

        // Flash mesaj göster fonksiyonu
        function showFlashMessage(message, category) {
            // Varolan flash mesajları temizle
            const existingFlashes = document.querySelectorAll('.flash');
            existingFlashes.forEach(flash => flash.remove());
            
            // Yeni flash mesaj oluştur
            const flashDiv = document.createElement('div');
            flashDiv.className = `flash ${category}`;
            flashDiv.textContent = message;
            
            // OTP form'undan önce ekle
            const form = document.querySelector('form');
            form.parentNode.insertBefore(flashDiv, form);
            
            // 5 saniye sonra otomatik kaldır
            setTimeout(() => {
                flashDiv.remove();
            }, 5000);
        }

        // Sayfa yüklendiğinde otomatik odaklan
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('otp_code').focus();
        });

        // Enter tuşu ile form gönder
        document.getElementById('otp_code').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                document.querySelector('form').submit();
            }
        });
  