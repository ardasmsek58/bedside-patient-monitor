#include "testmode.h"
#include "devicemanager.h"

testmode::testmode(QObject *parent) : QObject(parent)
{
    testModeTimer = new QTimer(this);
    connect(testModeTimer, &QTimer::timeout, this, &testmode::generateTestData);

    // Dummy objects (to avoid breaking existing code)
    serial = new QSerialPort(this);
    connectionTimer = new QTimer(this);
    dataRequestTimer = new QTimer(this);
    sequentialTimer = new QTimer(this);

    // Initialize starting values with random but realistic ranges
    m_baseHeartRate = 68 + QRandomGenerator::global()->bounded(15); // 68–82 bpm
    m_baseSpo2 = 96 + QRandomGenerator::global()->bounded(4);       // 96–99%
    m_baseRespRate = 14 + QRandomGenerator::global()->bounded(6);   // 14–19 /min
}

void testmode::setTestMode(bool enabled)
{
    if (m_testMode == enabled)
        return;

    m_testMode = enabled;
    emit testModeChanged();

    if (enabled) {
        qDebug() << "Test mode enabled";
        testDataIndex = 0;
        m_ecgPhase = 0.0;
        m_respPhase = 0.0;
        m_plethPhase = 0.0;
        startMonitoring();
    } else {
        qDebug() << "Test mode disabled";
        stopMonitoring();
    }
}

void testmode::startMonitoring()
{
    if (m_testMode && !m_isMonitoring) {
        m_isMonitoring = true;
        testModeTimer->start(50); // 50ms interval (20 Hz)
        emit monitoringChanged();
        qDebug() << "Test mode monitoring started";
    }
}

void testmode::stopMonitoring()
{
    if (m_isMonitoring) {
        m_isMonitoring = false;
        testModeTimer->stop();
        emit monitoringChanged();
        qDebug() << "Test mode monitoring stopped";
    }
}

void testmode::generateTestData()
{
    if (!m_testMode || !m_isMonitoring)
        return;

    // Every 2 seconds (40 cycles) slightly adjust values
    if (testDataIndex % 40 == 0) {
        // Heart rate: ±2 bpm change
        int hrChange = QRandomGenerator::global()->bounded(-2, 3);
        m_baseHeartRate = qBound(60, m_baseHeartRate + hrChange, 100);

        // SpO₂: ±1% change (rarely)
        if (QRandomGenerator::global()->bounded(100) < 10) { // 10% chance
            int spo2Change = QRandomGenerator::global()->bounded(-1, 2);
            m_baseSpo2 = qBound(95, m_baseSpo2 + spo2Change, 100);
        }

        // Respiration: ±1 /min change
        if (QRandomGenerator::global()->bounded(100) < 20) { // 20% chance
            int respChange = QRandomGenerator::global()->bounded(-1, 2);
            m_baseRespRate = qBound(12, m_baseRespRate + respChange, 25);
        }
    }

    // Small instantaneous variations
    int currentHR = m_baseHeartRate + QRandomGenerator::global()->bounded(-1, 2);
    int currentSpO2 = m_baseSpo2;
    int currentRespRate = m_baseRespRate;

    // Update values
    QString spo2Str = QString::number(currentSpO2);
    QString hrStr = QString::number(currentHR);
    QString respStr = QString::number(currentRespRate);

    if (spo2Str != m_spo2) {
        m_spo2 = spo2Str;
        emit spo2Changed();
    }
    if (hrStr != m_heartRate) {
        m_heartRate = hrStr;
        emit heartRateChanged();
    }
    if (respStr != m_respirationRate) {
        m_respirationRate = respStr;
        emit respirationRateChanged();
    }

    // Generate waveforms
    m_waveformSample = generatePlethWaveform();
    m_respWaveformSample = generateRespWaveform();
    m_ecgWaveformSample = generateECGWaveform();

    emit waveformSampleReceived();
    emit respWaveformSampleReceived();
    emit ecgWaveformSampleReceived();

    testDataIndex++;

    if (testDataIndex % 40 == 0) {
        auto dm = qobject_cast<DeviceManager*>(parent());
        if (dm) {
            dm->sendMeasurementToServer(hrStr, spo2Str, respStr);
            qDebug() << "🌐 Test data is sent:" << hrStr << spo2Str << respStr;
        } else {
            qWarning() << "[testmode] DeviceManager parent not found!";
        }
    }
}

int testmode::generateECGWaveform()
{
    // ECG waveform: P-QRS-T complex
    double heartRateHz = m_baseHeartRate / 60.0;
    double sampleRate = 20.0; // 20 Hz
    m_ecgPhase += 2.0 * M_PI * heartRateHz / sampleRate;

    if (m_ecgPhase > 2.0 * M_PI)
        m_ecgPhase -= 2.0 * M_PI;

    double ecgValue = 127; // Baseline

    // Normalized phase (0–1)
    double normalizedPhase = m_ecgPhase / (2.0 * M_PI);

    if (normalizedPhase < 0.1) {
        // P wave
        double pPhase = normalizedPhase / 0.1 * M_PI;
        ecgValue += 15 * sin(pPhase);
    } else if (normalizedPhase >= 0.15 && normalizedPhase < 0.35) {
        // QRS complex
        double qrsPhase = (normalizedPhase - 0.15) / 0.2;
        if (qrsPhase < 0.3) {
            // Q wave
            ecgValue -= 20 * sin(qrsPhase * M_PI / 0.3);
        } else if (qrsPhase < 0.7) {
            // R wave
            double rPhase = (qrsPhase - 0.3) / 0.4;
            ecgValue += 80 * sin(rPhase * M_PI);
        } else {
            // S wave
            double sPhase = (qrsPhase - 0.7) / 0.3;
            ecgValue -= 30 * sin(sPhase * M_PI);
        }
    } else if (normalizedPhase >= 0.5 && normalizedPhase < 0.8) {
        // T wave
        double tPhase = (normalizedPhase - 0.5) / 0.3 * M_PI;
        ecgValue += 25 * sin(tPhase);
    }

    // Add small noise
    ecgValue += QRandomGenerator::global()->bounded(-3, 4);

    return qBound(0, static_cast<int>(ecgValue), 255);
}

int testmode::generateRespWaveform()
{
    // Respiration waveform: sinusoidal
    double respRateHz = m_baseRespRate / 60.0;
    double sampleRate = 20.0; // 20 Hz
    m_respPhase += 2.0 * M_PI * respRateHz / sampleRate;

    if (m_respPhase > 2.0 * M_PI)
        m_respPhase -= 2.0 * M_PI;

    // Respiration wave (inspiration faster, expiration slower)
    double respValue = 127; // Baseline

    // Asymmetric respiration wave
    if (m_respPhase < M_PI) {
        // Inspiration (fast rise)
        respValue += 50 * sin(m_respPhase);
    } else {
        // Expiration (slow fall)
        respValue += 50 * sin(m_respPhase) * 0.7;
    }

    // Add small noise
    respValue += QRandomGenerator::global()->bounded(-2, 3);

    return qBound(0, static_cast<int>(respValue), 255);
}

int testmode::generatePlethWaveform()
{
    // Plethysmography waveform: synchronized with heart rate
    double heartRateHz = m_baseHeartRate / 60.0;
    double sampleRate = 20.0; // 20 Hz
    m_plethPhase += 2.0 * M_PI * heartRateHz / sampleRate;

    if (m_plethPhase > 2.0 * M_PI)
        m_plethPhase -= 2.0 * M_PI;

    // Pleth wave: quick rise, slow fall
    double plethValue = 127; // Baseline

    double normalizedPhase = m_plethPhase / (2.0 * M_PI);

    if (normalizedPhase < 0.3) {
        // Systole (fast rise)
        double systolePhase = normalizedPhase / 0.3 * M_PI / 2;
        plethValue += 60 * sin(systolePhase);
    } else if (normalizedPhase < 0.6) {
        // Early diastole
        double diastolePhase = (normalizedPhase - 0.3) / 0.3 * M_PI;
        plethValue += 60 * cos(diastolePhase * 0.5);
    } else {
        // Late diastole (dicrotic notch)
        double latePhase = (normalizedPhase - 0.6) / 0.4;
        plethValue += 15 * sin(latePhase * M_PI * 2) * exp(-latePhase * 3);
    }

    // Add small noise
    plethValue += QRandomGenerator::global()->bounded(-2, 3);

    return qBound(0, static_cast<int>(plethValue), 255);
}
