
        // DOM elementleri
        const form = document.getElementById('registerForm');
        const inputs = document.querySelectorAll('input');
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');
        const registerBtn = document.getElementById('registerBtn');

        // Form animasyonları
        inputs.forEach(input => {
            input.addEventListener('focus', function () {
                this.parentElement.style.transform = 'translateY(-2px)';
            });

            input.addEventListener('blur', function () {
                this.parentElement.style.transform = 'translateY(0)';
            });
        });

        // Şifre gücü kontrolü
        if (passwordInput) {
            passwordInput.addEventListener('input', function () {
                const password = this.value;
                const strength = calculatePasswordStrength(password);

                if (strengthFill && strengthText) {
                    strengthFill.style.width = strength.percentage + '%';
                    strengthText.textContent = strength.text;

                    // Renk değişimi
                    if (strength.percentage < 30) {
                        strengthFill.style.background = '#ff4757';
                    } else if (strength.percentage < 70) {
                        strengthFill.style.background = '#ffa502';
                    } else {
                        strengthFill.style.background = '#2ed573';
                    }
                }
            });
        }

        // Şifre eşleşme kontrolü
        if (confirmPasswordInput) {
            confirmPasswordInput.addEventListener('input', function () {
                const password = passwordInput.value;
                const confirmPassword = this.value;

                if (confirmPassword && password !== confirmPassword) {
                    this.style.borderColor = '#ff4757';
                    this.style.boxShadow = '0 0 10px rgba(255, 71, 87, 0.3)';
                } else if (confirmPassword && password === confirmPassword) {
                    this.style.borderColor = '#2ed573';
                    this.style.boxShadow = '0 0 10px rgba(46, 213, 115, 0.3)';
                } else {
                    this.style.borderColor = 'rgba(79, 172, 254, 0.2)';
                    this.style.boxShadow = 'none';
                }
            });
        }

        // Şifre gücü hesaplama fonksiyonu
        function calculatePasswordStrength(password) {
            let strength = 0;
            let text = 'Çok zayıf';

            if (password.length >= 8) strength += 20;
            if (password.length >= 12) strength += 10;
            if (password.match(/[a-z]/)) strength += 20;
            if (password.match(/[A-Z]/)) strength += 20;
            if (password.match(/[0-9]/)) strength += 20;
            if (password.match(/[^a-zA-Z0-9]/)) strength += 20;

            if (strength >= 90) {
                text = 'Çok güçlü';
            } else if (strength >= 70) {
                text = 'Güçlü';
            } else if (strength >= 50) {
                text = 'Orta';
            } else if (strength >= 30) {
                text = 'Zayıf';
            }

            return {
                percentage: Math.min(strength, 100),
                text: text
            };
        }

        // Form submit animasyonu (isteğe bağlı)
        form.addEventListener('submit', function () {
            registerBtn.innerHTML = '<span style="display: inline-block; animation: spin 1s linear infinite;">⏳</span> Hesap Oluşturuluyor...';
            registerBtn.disabled = true;
        });

        // Dinamik parçacık oluşturma
        function createParticle() {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.left = Math.random() * 100 + '%';
            particle.style.top = Math.random() * 100 + '%';
            particle.style.width = Math.random() * 4 + 2 + 'px';
            particle.style.height = particle.style.width;
            particle.style.animationDelay = Math.random() * 6 + 's';
            particle.style.animationDuration = Math.random() * 3 + 4 + 's';

            document.querySelector('.bg-animation').appendChild(particle);

            setTimeout(() => {
                particle.remove();
            }, 8000);
        }

        // Her 2.5 saniyede bir yeni parçacık oluştur
        setInterval(createParticle, 2500);

        // Kullanım koşulları ve gizlilik politikası fonksiyonları
        function showTerms() {
            alert('Kullanım Koşulları sayfası açılacak...');
        }

        function showPrivacy() {
            alert('Gizlilik Politikası sayfası açılacak...');
        }

        // Spin animasyonu için CSS
        const style = document.createElement('style');
        style.textContent = `
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        `;
        document.head.appendChild(style);
    