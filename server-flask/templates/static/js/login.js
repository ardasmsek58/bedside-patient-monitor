
  
        // Form animasyonları
        const inputs = document.querySelectorAll('input');
        inputs.forEach(input => {
            input.addEventListener('focus', function () {
                this.parentElement.style.transform = 'translateY(-2px)';
            });

            input.addEventListener('blur', function () {
                this.parentElement.style.transform = 'translateY(0)';
            });
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

        // Her 3 saniyede bir yeni parçacık oluştur
        setInterval(createParticle, 3000);
 