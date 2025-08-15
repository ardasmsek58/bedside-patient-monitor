
        // Background animation
        function createParticles() {
            const animation = document.getElementById('bgAnimation');
            const particleCount = 50;

            for (let i = 0; i < particleCount; i++) {
                const particle = document.createElement('div');
                particle.className = 'particle';
                particle.style.left = Math.random() * 100 + '%';
                particle.style.top = Math.random() * 100 + '%';
                particle.style.animationDelay = Math.random() * 6 + 's';
                particle.style.animationDuration = (Math.random() * 3 + 3) + 's';
                animation.appendChild(particle);
            }
        }

        // Veri saklama için global değişkenler
        let timeLabels = [];
        let heartRateData = [];
        let spo2Data = [];
        let respData = []; 
        const maxDataPoints = 30; 

        // Zaman etiketi oluşturma fonksiyonu
        function createTimeLabel() {
            const now = new Date();
            return now.toLocaleTimeString('tr-TR', {
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
        }

        
        const ctx = document.getElementById('chart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: timeLabels,
                datasets: [
                    {
                        label: 'Kalp Atış Hızı (bpm)',
                        data: heartRateData,
                        borderColor: '#4CAF50',
                        backgroundColor: 'rgba(76, 175, 80, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 8,
                        pointBackgroundColor: '#4CAF50',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        yAxisID: 'y'
                    },
                    {
                        label: 'SpO₂ (%)',
                        data: spo2Data,
                        borderColor: '#03A9F4',
                        backgroundColor: 'rgba(3, 169, 244, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 8,
                        pointBackgroundColor: '#03A9F4',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        yAxisID: 'y1'
                    },
                    {
                        label: 'Solunum Hızı (/min)', 
                        data: respData,
                        borderColor: '#607D8B',
                        backgroundColor: 'rgba(96, 125, 139, 0.1)',
                        borderWidth: 3,
                        fill: false, 
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 8,
                        pointBackgroundColor: '#607D8B',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        yAxisID: 'y2' 
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                plugins: {
                    legend: {
                        labels: {
                            color: '#e0e0e0',
                            font: {
                                size: 14,
                                weight: 'bold'
                            },
                            padding: 20
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        titleColor: '#ffffff',
                        bodyColor: '#ffffff',
                        borderColor: '#4facfe',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: true,
                        callbacks: {
                            title: function (context) {
                                return 'Zaman: ' + context[0].label;
                            },
                            afterBody: function () {
                                return 'Güncelleme: 10 saniye';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Zaman (10 saniye aralıkla)',
                            color: '#b0b0b0',
                            font: {
                                size: 14,
                                weight: 'bold'
                            }
                        },
                        ticks: {
                            color: '#888',
                            font: {
                                size: 12
                            },
                            maxTicksLimit: 10,
                            autoSkip: true
                        },
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)',
                            lineWidth: 1
                        }
                    },
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        title: {
                            display: true,
                            text: 'Kalp Atış Hızı (bpm)',
                            color: '#4CAF50',
                            font: {
                                size: 14,
                                weight: 'bold'
                            }
                        },
                        min: 50,
                        max: 120,
                        ticks: {
                            color: '#4CAF50',
                            font: {
                                size: 12
                            },
                            stepSize: 10
                        },
                        grid: {
                            color: 'rgba(76, 175, 80, 0.1)',
                            lineWidth: 1
                        }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: {
                            display: true,
                            text: 'SpO₂ (%)',
                            color: '#03A9F4',
                            font: {
                                size: 14,
                                weight: 'bold'
                            }
                        },
                        min: 85,
                        max: 100,
                        ticks: {
                            color: '#03A9F4',
                            font: {
                                size: 12
                            },
                            stepSize: 2
                        },
                        grid: {
                            drawOnChartArea: false,
                            color: 'rgba(3, 169, 244, 0.1)',
                            lineWidth: 1
                        }
                    },
                    y2: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: {
                            display: true,
                            text: 'Solunum Hızı (/min)',
                            color: '#CCCCCC', 
                            font: {
                                size: 14,
                                weight: 'bold'
                            }
                        },
                        min: 5,
                        max: 40,
                        ticks: {
                            color: '#CCCCCC', 
                            font: {
                                size: 12
                            },
                            stepSize: 5
                        },
                        grid: {
                            drawOnChartArea: false,
                            color: 'rgba(204, 204, 204, 0.1)', 
                            lineWidth: 1
                        }
                    }


                },
                elements: {
                    line: {
                        borderWidth: 3
                    },
                    point: {
                        radius: 5,
                        hoverRadius: 8
                    }
                }
            }
        });

        // Data fetching with improved error handling and connection status
        async function fetchData() {
            try {
                const response = await fetch('/get_live_data');

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const data = await response.json();

                // Veri kontrolü - eğer veri yok, null, undefined veya "--" ise
                if (!data ||
                    data.heartRate === "--" ||
                    data.spo2 === "--" ||
                    data.resp === "--" ||
                    data.heartRate == null ||
                    data.spo2 == null ||
                    data.resp == null ||
                    data.heartRate === undefined ||
                    data.spo2 === undefined ||
                    data.resp === undefined ||
                    !data.timestamp) {

                    
                    document.getElementById('hr').textContent = '--';
                    document.getElementById('spo2').textContent = '--';
                    document.getElementById('resp').textContent = '--'; 

                    document.getElementById('connectionStatus').textContent = '🔴 Sensör Bağlı Değil';
                    document.getElementById('connectionStatus').className = 'connection-status disconnected';

                    // Status indicator'ları inactive yap
                    document.querySelectorAll('.status-indicator').forEach(indicator => {
                        indicator.classList.add('inactive');
                    });

                    console.log('Sensör bağlantısı yok - eski veri gösterilmiyor');
                    return;
                }

                const latestHR = parseInt(data.heartRate);
                const latestSpO2 = parseInt(data.spo2);
                const latestResp = parseInt(data.resp);

                // Geçerli veri aralığı kontrolü
                const isValidHR = !isNaN(latestHR) && latestHR > 30 && latestHR < 200;
                const isValidSpO2 = !isNaN(latestSpO2) && latestSpO2 > 70 && latestSpO2 <= 100;
                const isValidResp = !isNaN(latestResp) && latestResp > 5 && latestResp < 50;

                if (isValidHR && isValidSpO2 && isValidResp) {
                    // Tüm değerleri güncelle
                    updateValue('hr', latestHR);
                    updateValue('spo2', latestSpO2);
                    updateValue('resp', latestResp); 

                    
                    addDataPoint(latestHR, latestSpO2, latestResp);

                    // Bağlantı durumu güncelleme
                    document.getElementById('connectionStatus').textContent = '🟢 Canlı Veri Alınıyor';
                    document.getElementById('connectionStatus').className = 'connection-status connected';

                    // Canlı veriler için status indicator'ları aktif yap
                    document.querySelector('.hr-card .status-indicator').classList.remove('inactive');
                    document.querySelector('.spo2-card .status-indicator').classList.remove('inactive');
                    document.querySelector('.resp-card .status-indicator').classList.remove('inactive');

                    console.log(`Yeni veri: HR=${latestHR}, SpO2=${latestSpO2}, Resp=${latestResp}, Zaman=${data.timestamp}`);
                } else {
                    // Geçersiz değerler için "--" göster ve hangi değerin geçersiz olduğunu kontrol et
                    if (!isValidHR) {
                        document.getElementById('hr').textContent = '--';
                        document.querySelector('.hr-card .status-indicator').classList.add('inactive');
                    } else {
                        updateValue('hr', latestHR);
                        document.querySelector('.hr-card .status-indicator').classList.remove('inactive');
                    }

                    if (!isValidSpO2) {
                        document.getElementById('spo2').textContent = '--';
                        document.querySelector('.spo2-card .status-indicator').classList.add('inactive');
                    } else {
                        updateValue('spo2', latestSpO2);
                        document.querySelector('.spo2-card .status-indicator').classList.remove('inactive');
                    }

                    if (!isValidResp) {
                        document.getElementById('resp').textContent = '--';
                        document.querySelector('.resp-card .status-indicator').classList.add('inactive');
                    } else {
                        updateValue('resp', latestResp);
                        document.querySelector('.resp-card .status-indicator').classList.remove('inactive');
                    }

                    // Kısmen geçerli veriler varsa grafiği güncelle
                    if (isValidHR && isValidSpO2 && isValidResp) {
                        addDataPoint(latestHR, latestSpO2, latestResp);
                    }

                    document.getElementById('connectionStatus').textContent = '🟡 Kısmi/Geçersiz Sensör Verisi';
                    document.getElementById('connectionStatus').className = 'connection-status disconnected';

                    console.log(`Kısmi veri: HR=${isValidHR ? latestHR : 'geçersiz'}, SpO2=${isValidSpO2 ? latestSpO2 : 'geçersiz'}, Resp=${isValidResp ? latestResp : 'geçersiz'}`);
                }

            } catch (error) {
                console.error('Veri çekme hatası:', error);

                // Hata durumunda tüm değerleri "--" yap
                document.getElementById('hr').textContent = '--';
                document.getElementById('spo2').textContent = '--';
                document.getElementById('resp').textContent = '--';

                // Tüm status indicator'ları inactive yap
                document.querySelectorAll('.status-indicator').forEach(indicator => {
                    indicator.classList.add('inactive');
                });

                document.getElementById('connectionStatus').textContent = '🔴 Bağlantı Hatası';
                document.getElementById('connectionStatus').className = 'connection-status disconnected';
            }
        }

        
        function addDataPoint(hr, spo2, resp) {
            // Sadece geçerli sayısal değerler varsa grafik güncelle
            if (isNaN(hr) || isNaN(spo2) || isNaN(resp) || hr <= 0 || spo2 <= 0 || resp <= 0) {
                console.log('Geçersiz veri nedeniyle grafik güncellenmedi:', { hr, spo2, resp });
                return; 
            }

            const timeLabel = createTimeLabel();

            // Tüm veri dizilerine yeni değerleri ekle
            timeLabels.push(timeLabel);
            heartRateData.push(hr);
            spo2Data.push(spo2);
            respData.push(resp); 

            // Maksimum veri noktası sınırını kontrol et
            if (timeLabels.length > maxDataPoints) {
                timeLabels.shift();
                heartRateData.shift();
                spo2Data.shift();
                respData.shift(); 
            }

            
            chart.data.labels = timeLabels;
            chart.data.datasets[0].data = heartRateData;
            chart.data.datasets[1].data = spo2Data;
            chart.data.datasets[2].data = respData; 

            
            chart.update('active');

            console.log(`Grafik güncellendi: ${timeLabel} - HR:${hr}, SpO2:${spo2}, Resp:${resp}`);
        }

        // Smooth value update with animation
        function updateValue(elementId, newValue) {
            const element = document.getElementById(elementId);
            if (!element) {
                console.error(`Element bulunamadı: ${elementId}`);
                return;
            }

            const currentValue = parseInt(element.textContent) || 0;

            if (currentValue !== newValue) {
                element.style.transform = 'scale(1.1)';
                element.style.transition = 'transform 0.3s ease';

                setTimeout(() => {
                    element.textContent = newValue;
                    element.style.transform = 'scale(1)';
                }, 150);
            }
        }

        // Initialize
        createParticles();

        // İlk veri çekme
        fetchData();

        // 10 saniyede bir veri çek
        const dataInterval = setInterval(fetchData, 10000);

        // Add some interactivity
        document.querySelectorAll('.metric-card').forEach(card => {
            card.addEventListener('click', () => {
                card.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    card.style.transform = 'translateY(-5px)';
                }, 100);
            });
        });

        // Sayfa kapatılırken interval'i temizle
        window.addEventListener('beforeunload', () => {
            if (dataInterval) {
                clearInterval(dataInterval);
                console.log('Veri çekme interval\'i temizlendi');
            }
        });

        // Sayfa yüklendiğinde bilgi mesajı
        console.log('VitaScope Dashboard başlatıldı - 10 saniye güncellenme aralığı');
        console.log('Desteklenen veriler: Kalp Atış Hızı, SpO2, Solunum Hızı');

        // Hata durumlarında yeniden bağlanma mekanizması
        let reconnectAttempts = 0;
        const maxReconnectAttempts = 3;

        function attemptReconnection() {
            if (reconnectAttempts < maxReconnectAttempts) {
                reconnectAttempts++;
                console.log(`Yeniden bağlanma denemesi ${reconnectAttempts}/${maxReconnectAttempts}`);

                setTimeout(() => {
                    fetchData().then(() => {
                        reconnectAttempts = 0; 
                    }).catch(() => {
                        if (reconnectAttempts < maxReconnectAttempts) {
                            attemptReconnection();
                        } else {
                            console.log('Maksimum yeniden bağlanma denemesi aşıldı');
                            document.getElementById('connectionStatus').textContent = '🔴 Bağlantı Başarısız';
                        }
                    });
                }, 5000); 
            }
        }
