#ifndef TESTMODE_H
#define TESTMODE_H

#include <QObject>
#include <QTimer>
#include <QSerialPort>
#include <QRandomGenerator>
#include <QDebug>


class testmode : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool testMode READ testMode WRITE setTestMode NOTIFY testModeChanged)
    Q_PROPERTY(QString heartRateValue READ heartRateValue NOTIFY heartRateChanged)
    Q_PROPERTY(QString spo2Value READ spo2Value NOTIFY spo2Changed)
    Q_PROPERTY(int waveformSample READ waveformSample NOTIFY waveformSampleReceived)
    Q_PROPERTY(bool isMonitoring READ isMonitoring NOTIFY monitoringChanged)
    Q_PROPERTY(int respWaveformSample READ respWaveformSample NOTIFY respWaveformSampleReceived)
    Q_PROPERTY(int ecgWaveformSample READ ecgWaveformSample NOTIFY ecgWaveformSampleReceived)
    Q_PROPERTY(QString respirationRate READ respirationRate NOTIFY respirationRateChanged)

public:
    explicit testmode(QObject *parent = nullptr);

    QString respirationRate() const { return m_respirationRate; }
    QString heartRateValue() const { return m_heartRate; }
    QString spo2Value() const { return m_spo2; }
    int waveformSample() const { return m_waveformSample; }
    bool isMonitoring() const { return m_isMonitoring; }
    int respWaveformSample() const { return m_respWaveformSample; }
    int ecgWaveformSample() const { return m_ecgWaveformSample; }
    bool testMode() const { return m_testMode; }

public slots:

    void setTestMode(bool enabled);
    void startMonitoring();
    void stopMonitoring();

signals:

    void testModeChanged();
    void heartRateChanged();
    void spo2Changed();
    void waveformSampleReceived();
    void monitoringChanged();
    void respWaveformSampleReceived();
    void ecgWaveformSampleReceived();
    void respirationRateChanged();

private slots:

    void generateTestData();

private:
    // Test mode variables
    bool m_testMode = false;
    bool m_isMonitoring = false;
    int testDataIndex = 0;

    // Simulated data
    QString m_heartRate = "72";
    QString m_spo2 = "98";
    QString m_respirationRate = "16";
    int m_waveformSample = 127;
    int m_respWaveformSample = 127;
    int m_ecgWaveformSample = 127;

    // Base values for stable readings
    int m_baseHeartRate = 72;
    int m_baseSpo2 = 98;
    int m_baseRespRate = 16;

    // Phase variables for waveform generation
    double m_ecgPhase = 0.0;
    double m_respPhase = 0.0;
    double m_plethPhase = 0.0;

    // Timers
    QTimer *testModeTimer;

    // Dummy objects (to avoid breaking existing code)
    QSerialPort *serial;
    QTimer *connectionTimer;
    QTimer *dataRequestTimer;
    QTimer *sequentialTimer;

    // Helper functions
    int generateECGWaveform();
    int generateRespWaveform();
    int generatePlethWaveform();

};

#endif // TESTMODE_H
