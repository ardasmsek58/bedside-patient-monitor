#ifndef SMMPROTOCOLTEST_H
#define SMMPROTOCOLTEST_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>
#include <QByteArray>
#include <QDebug>
#include <QStringList>


class DeviceManager;

class SMMProtocolTest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString heartRateValue READ heartRateValue NOTIFY heartRateChanged)
    Q_PROPERTY(QString spo2Value READ spo2Value NOTIFY spo2Changed)
    Q_PROPERTY(int waveformSample READ waveformSample NOTIFY waveformSampleReceived)
    Q_PROPERTY(bool isMonitoring READ isMonitoring NOTIFY monitoringChanged)
    Q_PROPERTY(int respWaveformSample READ respWaveformSample NOTIFY respWaveformSampleReceived)
    Q_PROPERTY(int ecgWaveformSample READ ecgWaveformSample NOTIFY ecgWaveformSampleReceived)
    Q_PROPERTY(QString respirationRate READ respirationRate NOTIFY respirationRateChanged)

public:
    SMMProtocolTest(QObject *parent = nullptr);
    ~SMMProtocolTest();

    QString respirationRate() const { return m_respirationRate; }
    QString heartRateValue() const { return m_heartRate; }
    QString spo2Value() const { return m_spo2; }
    int waveformSample() const { return m_waveformSample; }
    int respWaveformSample() const { return m_respSample; }
    int ecgWaveformSample() const { return m_ecgSample; }
    bool isMonitoring() const { return m_isMonitoring; }

    explicit SMMProtocolTest(DeviceManager* manager, QObject* parent = nullptr);  // ✔️ DeviceManager pointer'ı al
    void tryInsertMeasurement();

public slots:

    void start();
    void startMonitoring();
    void stopMonitoring();

signals:

    void respirationRateChanged();
    void heartRateChanged();
    void spo2Changed();
    void waveformSampleReceived();
    void monitoringChanged();
    void respWaveformSampleReceived();
    void ecgWaveformSampleReceived();

private slots:

    void readData();
    void sendConnectionSequence();
    void startSequentialRequests();
    void sendNextPacket();
    void handleError(QSerialPort::SerialPortError error);

private:

    QSerialPort *serial;
    QTimer *connectionTimer;
    QTimer *dataRequestTimer;
    QTimer *sequentialTimer;

    int m_respSample = 0;
    int m_ecgSample = 0;
    QString m_respirationRate;

    // Protocol variables
    QByteArray buffer;
    QList<QByteArray> packetCommands;
    int currentPacketIndex;
    bool connectionSent = false;

    // Status variables
    QString m_heartRate = "0";
    QString m_spo2 = "0";
    int m_waveformSample = 0;
    bool m_isMonitoring = false;

    // Helper functions
    bool connectToDevice(const QString &portName);
    QList<QByteArray> createIndividualCommands();
    QByteArray createSMMPacket(uint8_t code, const QByteArray &data);
    void parseBufferedData();
    void parsePacketByCode(uint8_t code, const QByteArray &payload);
    QByteArray createECGCommandPacket(uint8_t leadCode, uint8_t filterCode, uint8_t gainCode);

    // Temporary cache storage
    QString m_cachedHeartRate = "Invalid";
    QString m_cachedSpO2 = "Invalid";
    QString m_cachedResp = "Invalid";

    // Control to prevent duplicate entries
    bool m_readyToInsert = false;

    DeviceManager* m_deviceManager = nullptr;



};

#endif // SMMPROTOCOLTEST_H
