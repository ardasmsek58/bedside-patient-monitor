#include "smmprotocoltest.h"
#include "database.h"
#include "devicemanager.h"

#include <QDebug>
#include <QThread>
#include <QSqlQuery>
#include <QSqlError>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>
#ifdef Q_OS_MAC
#include <IOKit/serial/ioss.h>
#endif

SMMProtocolTest::SMMProtocolTest(QObject *parent) : QObject(parent)
{
    serial = new QSerialPort(this);
    connectionTimer = new QTimer(this);
    dataRequestTimer = new QTimer(this);
    sequentialTimer = new QTimer(this);

    connect(serial, &QSerialPort::readyRead, this, &SMMProtocolTest::readData);
    connect(serial, &QSerialPort::errorOccurred, this, &SMMProtocolTest::handleError);
    connect(connectionTimer, &QTimer::timeout, this, &SMMProtocolTest::sendConnectionSequence);
    connect(dataRequestTimer, &QTimer::timeout, this, &SMMProtocolTest::startSequentialRequests);
    connect(sequentialTimer, &QTimer::timeout, this, &SMMProtocolTest::sendNextPacket);

    dataRequestTimer->setSingleShot(false);
    sequentialTimer->setSingleShot(true);

    currentPacketIndex = 0;
    packetCommands = createIndividualCommands();
}

SMMProtocolTest::~SMMProtocolTest()
{
    if (serial && serial->isOpen()) {
        serial->close();
    }
}

void SMMProtocolTest::start()
{
    databaseClass::instance()->setupDatabase();

    QStringList portNamesToTry = {
        "/dev/cu.PL2303G-USBtoUART110",
        "cu.PL2303G-USBtoUART110"
    };

    bool connected = false;
    for (const QString &portName : portNamesToTry) {
        if (connectToDevice(portName)) {
            qDebug() << "Connection successful:" << portName;
            connected = true;
            break;
        }
    }

    if (!connected) {
        qWarning() << "Could not connect to any port.";
    }
}

void SMMProtocolTest::startMonitoring()
{
    if (m_isMonitoring) {
        return; // Monitoring is already active
    }

    m_isMonitoring = true;
    emit monitoringChanged();

    // Restart monitoring
    start();
    qDebug() << "Monitoring started";
}

void SMMProtocolTest::stopMonitoring()
{
    m_isMonitoring = false;

    // Stop all timers
    connectionTimer->stop();
    dataRequestTimer->stop();
    sequentialTimer->stop();

    // Close serial port
    if (serial && serial->isOpen()) {
        serial->close();
    }

    connectionSent = false;
    qDebug() << "Monitoring stopped";
    emit monitoringChanged();
}

bool SMMProtocolTest::connectToDevice(const QString &portName)
{
    if (serial->isOpen()) {
        serial->close();
        QThread::msleep(100);
    }

    serial->setPortName(portName);
    serial->setBaudRate(QSerialPort::Baud115200);
    serial->setParity(QSerialPort::OddParity);
    serial->setDataBits(QSerialPort::Data8);
    serial->setStopBits(QSerialPort::OneStop);
    serial->setFlowControl(QSerialPort::NoFlowControl);

    if (!serial->open(QIODevice::ReadWrite)) {
        qWarning() << "Port could not be opened:" << serial->errorString();
        return false;
    }

#ifdef Q_OS_MAC
    int fd = serial->handle();
    int customBaud = 375000;
    if (fd != -1 && ioctl(fd, IOSSIOSPEED, &customBaud) == 0) {
        qDebug() << "Baud rate set to 375000.";
    } else {
        qWarning() << "Custom baud rate could not be set.";
    }
#endif

    serial->clear();
    connectionTimer->start(1000);
    m_isMonitoring = true;
    emit monitoringChanged();
    return true;
}

void SMMProtocolTest::sendConnectionSequence()
{
    if (connectionSent || !serial->isOpen()) return;

    QByteArray handshake = QByteArray::fromHex("BF5FFF");
    serial->write(handshake);
    serial->flush();
    serial->waitForBytesWritten(1000);

    connectionSent = true;
    connectionTimer->stop();

    QTimer::singleShot(2000, [this]() {
        if (m_isMonitoring) {
            dataRequestTimer->start(5000);
        }
    });
}

void SMMProtocolTest::startSequentialRequests()
{
    if (!serial->isOpen() || !m_isMonitoring) return;

    currentPacketIndex = 0;
    sendNextPacket();
}

void SMMProtocolTest::sendNextPacket()
{
    if (!serial->isOpen() || !m_isMonitoring || currentPacketIndex >= packetCommands.size()) return;

    QByteArray packet = packetCommands[currentPacketIndex];
    serial->write(packet);
    serial->flush();
    serial->waitForBytesWritten(100);

    currentPacketIndex++;
    if (currentPacketIndex < packetCommands.size() && m_isMonitoring) {
        sequentialTimer->start(1000);
    }
}

QList<QByteArray> SMMProtocolTest::createIndividualCommands()
{
    QList<QByteArray> commands;
    commands.append(createSMMPacket(0x01, QByteArray::fromHex("0203030301000000050101")));
    commands.append(createSMMPacket(0x02, QByteArray()));
    commands.append(createSMMPacket(0x03, QByteArray())); // RESP waveform
    commands.append(createSMMPacket(0x04, QByteArray::fromHex("0100")));
    return commands;
}

QByteArray SMMProtocolTest::createSMMPacket(uint8_t code, const QByteArray &data)
{
    QByteArray packet;
    packet.append(0xAA);
    packet.append(0x55);
    uint8_t length = data.size() + 1;
    packet.append(length);
    packet.append(code);
    packet.append(data);

    uint8_t checksum = length + code;
    for (char byte : data) {
        checksum += static_cast<uint8_t>(byte);
    }
    packet.append(checksum);
    return packet;
}

void SMMProtocolTest::readData()
{
    if (!m_isMonitoring) return;

    QByteArray incoming = serial->readAll();
    if (incoming.isEmpty()) return;

    qDebug() << "Incoming data:" << incoming.toHex(' ').toUpper();

    buffer.append(incoming);
    parseBufferedData();
}

void SMMProtocolTest::parseBufferedData()
{
    while (buffer.size() >= 4) {
        int headerIndex = buffer.indexOf(QByteArray::fromHex("AA55"));
        if (headerIndex == -1) {
            buffer.clear();
            return;
        }

        if (headerIndex > 0)
            buffer.remove(0, headerIndex);

        if (buffer.size() < 4)
            return;

        uint8_t length = static_cast<uint8_t>(buffer[2]);
        int totalSize = 3 + length + 1;

        if (buffer.size() < totalSize)
            return;

        QByteArray packet = buffer.left(totalSize);
        uint8_t code = static_cast<uint8_t>(packet[3]);
        QByteArray payload = packet.mid(4, length - 1);

        uint8_t receivedChecksum = static_cast<uint8_t>(packet[totalSize - 1]);
        uint8_t calculatedChecksum = length + code;
        for (char byte : payload) {
            calculatedChecksum += static_cast<uint8_t>(byte);
        }

        if (receivedChecksum == calculatedChecksum) {
            parsePacketByCode(code, payload);
        }

        buffer.remove(0, totalSize);
    }
}

void SMMProtocolTest::parsePacketByCode(uint8_t code, const QByteArray &payload)
{
    QString hexDump;
    for (uint8_t byte : payload) {
        hexDump += QString("%1 ").arg(byte, 2, 16, QLatin1Char('0')).toUpper();
    }

    switch (code) {
    case 0x01:
    {
        if (payload.size() >= 57) // 56 byte ECG + 1 FLAG2
        {
            const QStringList leadNames = {
                "Lead I", "Lead II", "Lead III", "Lead V",
                "Lead aVR", "Lead aVF", "Lead aVL"
            };

            const int samplesPerLead = 8;

            for (int lead = 0; lead < 7; ++lead)
            {
                int startIndex = lead * samplesPerLead;
                QVector<uint8_t> samples;

                for (int i = 0; i < samplesPerLead; ++i) {
                    samples.append(static_cast<uint8_t>(payload[startIndex + i]));
                }

                // Send sample to UI only for Lead I
                if (lead == 0 && !samples.isEmpty()) {
                    m_ecgSample = samples.last();
                    emit ecgWaveformSampleReceived();
                    qDebug() << QString("📈 [ECG] %1 → %2")
                                    .arg(leadNames[lead])
                                    .arg(samples.last());
                }

                // Display all leads in terminal (optional)
                qDebug() << QString("[0x01] %1 Samples:").arg(leadNames[lead]) << samples;
            }

            // FLAG2 analysis
            uint8_t flag2 = static_cast<uint8_t>(payload[56]);
            qDebug() << "[0x01] FLAG2:" << QString("0x%1").arg(flag2, 2, 16, QChar('0')).toUpper();
        }
        else
        {
            qWarning() << "[0x01] ECG Graphic Data packet too short:" << payload.size();
        }
        break;
    }

    case 0x03: {
        if (payload.size() >= 1) {
            m_respSample = static_cast<uint8_t>(payload[0]);
            emit respWaveformSampleReceived();
        }
        break;
    }

    case 0x04: {
        if (payload.size() >= 6) {
            uint8_t rr = static_cast<uint8_t>(payload[4]);

            if (rr == 0 || rr == 0xFF || rr < 5 || rr > 80) {
                qDebug() << "[0x04] RESP value invalid or sensor not connected:" << rr;
                m_respirationRate = "Geçersiz";
                m_cachedResp = "Geçersiz";
                emit respirationRateChanged();
            } else {
                QString rrStr = QString::number(rr);
                m_respirationRate = rrStr;
                m_cachedResp = rrStr;
                emit respirationRateChanged();
                qDebug() << "Emitted respirationRateChanged:" << rrStr;
            }

            tryInsertMeasurement();
        }
        break;
    }

    case 0x15: {
        if (payload.size() >= 6) {
            uint8_t waveformRaw = static_cast<uint8_t>(payload[1]);
            uint8_t spo2 = static_cast<uint8_t>(payload[3]);
            uint16_t pulse = (static_cast<uint8_t>(payload[4]) << 8) | static_cast<uint8_t>(payload[5]);

            QString spo2Str = (spo2 == 0x7F || spo2 > 100) ? "Geçersiz" : QString::number(spo2);
            QString pulseStr = (pulse > 240 || pulse == 0 || pulse == 0xFFFF) ? "Geçersiz" : QString::number(pulse);

            if (spo2Str != m_spo2) {
                m_spo2 = spo2Str;
                m_cachedSpO2 = spo2Str;
                emit spo2Changed();
            }

            if (pulseStr != m_heartRate) {
                m_heartRate = pulseStr;
                m_cachedHeartRate = pulseStr;
                emit heartRateChanged();
            }

            m_waveformSample = waveformRaw;
            emit waveformSampleReceived();

            tryInsertMeasurement();
        }
        break;
    }

    default:
        break;
    }
}

SMMProtocolTest::SMMProtocolTest(DeviceManager* manager, QObject* parent)
    : QObject(parent), m_deviceManager(manager)
{}

void SMMProtocolTest::tryInsertMeasurement()
{
    if (!m_readyToInsert)
        return;

    QString patientId = m_deviceManager ? m_deviceManager->currentPatientId() : "";

    if (m_cachedHeartRate != "Geçersiz" &&
        m_cachedSpO2 != "Geçersiz" &&
        m_cachedResp != "Geçersiz" &&
        !patientId.isEmpty())
    {
        databaseClass::instance()->insertMeasurement(
            patientId,
            m_cachedHeartRate,
            m_cachedSpO2,
            m_cachedResp
            );

        qDebug() << "Measurement data added:" << patientId
                 << "HR:" << m_cachedHeartRate
                 << "SpO2:" << m_cachedSpO2
                 << "RESP:" << m_cachedResp;

        m_readyToInsert = false;
    }
}

void SMMProtocolTest::handleError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError)
        return;

    qWarning() << "Serial Port Error:" << error << "-" << serial->errorString();

    if (error == QSerialPort::ResourceError || error == QSerialPort::DeviceNotFoundError) {
        if (m_isMonitoring) {
            connectionSent = false;
            connectionTimer->start(2000);
        }
    }
}
