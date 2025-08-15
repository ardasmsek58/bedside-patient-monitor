#include "devicemanager.h"
#include "smmprotocoltest.h"
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDateTime>
#include <QNetworkInterface>

DeviceManager::DeviceManager(QObject *parent) : QObject(parent)
{
    // Create device and helper classes
    realDevice = new SMMProtocolTest();
    testDevice = new testmode(this);
    printer = new print(this);

    // Setup the database
    databaseClass::instance()->setupDatabase();

    // Establish connections
    setupConnections();

    qDebug() << "DeviceManager initialized";
}

QString DeviceManager::userRole() const
{
    return m_userRole;
}

void DeviceManager::setUserRole(const QString &role)
{
    if (m_userRole != role) {
        m_userRole = role;
        emit userRoleChanged();
    }
}

QVariantList DeviceManager::getAllPatients()
{
    return databaseClass::instance()->getAllPatients();
}

bool DeviceManager::addPatient(const QString& id, const QString& name, const QString& surname, const QString& tc) {
    QSqlQuery query;
    query.prepare("INSERT INTO patients (patient_id, name, surname, tc) VALUES (:id, :name, :surname, :tc)");
    query.bindValue(":id", id);
    query.bindValue(":name", name);
    query.bindValue(":surname", surname);
    query.bindValue(":tc", tc);
    return query.exec();
}

QVariantMap DeviceManager::findPatient(const QString& name, const QString& surname, const QString& tc)
{
    return databaseClass::instance()->findPatient(name, surname, tc);
}

QString DeviceManager::currentPatientId() const {
    return m_currentPatientId;
}

void DeviceManager::setCurrentPatientId(const QString& id) {
    if (m_currentPatientId != id) {
        m_currentPatientId = id;
        emit currentPatientIdChanged();
    }
}

QString DeviceManager::heartRateValue() const
{
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("heartRateValue").toString();
    }
    return "0";
}

QString DeviceManager::spo2Value() const
{
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("spo2Value").toString();
    }
    return "0";
}

int DeviceManager::waveformSample() const
{
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("waveformSample").toInt();
    }
    return 0;
}

bool DeviceManager::isMonitoring() const
{
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("isMonitoring").toBool();
    }
    return false;
}

bool DeviceManager::testMode() const
{
    return m_testMode;
}

void DeviceManager::startMonitoring()
{
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        QMetaObject::invokeMethod(activeDevice, "startMonitoring");
        qDebug() << "Monitoring started on" << (m_testMode ? "test device" : "real device");
    }
}

void DeviceManager::stopMonitoring()
{
    // Stop both devices
    QMetaObject::invokeMethod(realDevice, "stopMonitoring");
    QMetaObject::invokeMethod(testDevice, "stopMonitoring");
    qDebug() << "Monitoring stopped on all devices";
}

void DeviceManager::setTestMode(bool enabled)
{
    if (m_testMode == enabled)
        return;

    bool wasMonitoring = isMonitoring();

    // Stop previous device if it was monitoring
    if (wasMonitoring) {
        stopMonitoring();
    }

    // Disconnect current active device
    disconnectDevice(getActiveDevice());

    m_testMode = enabled;
    emit testModeChanged();

    // Connect new active device
    connectDevice(getActiveDevice());

    // Inform active device about test mode status
    if (m_testMode) {
        QMetaObject::invokeMethod(testDevice, "setTestMode", Q_ARG(bool, true));
    }

    // Restart monitoring if it was previously running
    if (wasMonitoring) {
        startMonitoring();
    }

    qDebug() << "Test mode" << (enabled ? "enabled" : "disabled");
}

bool DeviceManager::printWaveformData(const QVariantList& waveformData,
                                      const QVariantList& timestamps,
                                      const QVariantList& ecgData,
                                      const QVariantList& ecgTimestamps)
{
    // Set numeric values for printing
    printer->setHeartRate(heartRateValue());
    printer->setSpo2(spo2Value());
    printer->setRespirationRate(respirationRate());

    return printer->printWaveformData(waveformData, timestamps, ecgData, ecgTimestamps);
}

bool DeviceManager::saveWaveformToPDF(const QVariantList& waveformData,
                                      const QVariantList& timestamps,
                                      const QString& filename,
                                      const QVariantList& ecgData,
                                      const QVariantList& ecgTimestamps)
{
    // Set numeric values for saving
    printer->setHeartRate(heartRateValue());
    printer->setSpo2(spo2Value());
    printer->setRespirationRate(respirationRate());

    return printer->saveWaveformToPDF(waveformData, timestamps, filename, ecgData, ecgTimestamps);
}

QVariantList DeviceManager::getRecentMeasurementsForPatient(const QString& patientId, int limit)
{
    return databaseClass::instance()->getRecentMeasurements(patientId, limit);
}

QObject* DeviceManager::getActiveDevice() const
{
    return m_testMode ? static_cast<QObject*>(testDevice) : static_cast<QObject*>(realDevice);
}

int DeviceManager::respWaveformSample() const {
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("respWaveformSample").toInt();
    }
    return 0;
}

void DeviceManager::onRespWaveformSampleReceived() {
    emit respWaveformSampleReceived();
}

int DeviceManager::ecgWaveformSample() const {
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("ecgWaveformSample").toInt();
    }
    return 0;
}

void DeviceManager::onEcgWaveformSampleReceived() {
    emit ecgWaveformSampleReceived();
}

QString DeviceManager::respirationRate() const {
    QObject* activeDevice = getActiveDevice();
    if (activeDevice) {
        return activeDevice->property("respirationRate").toString();
    }
    return "0";
}

void DeviceManager::onRespirationRateChanged()
{
    emit respirationRateChanged();
}

void DeviceManager::setupConnections()
{
    // Printer connections
    connect(printer, &print::printCompleted, this, &DeviceManager::onPrintCompleted);

    // Initially connect to the real device
    connectDevice(realDevice);
}

void DeviceManager::connectDevice(QObject* device)
{
    if (!device) return;

    // Connect signals
    connect(device, SIGNAL(heartRateChanged()), this, SLOT(onHeartRateChanged()));
    connect(device, SIGNAL(spo2Changed()), this, SLOT(onSpo2Changed()));
    connect(device, SIGNAL(waveformSampleReceived()), this, SLOT(onWaveformSampleReceived()));
    connect(device, SIGNAL(respWaveformSampleReceived()), this, SLOT(onRespWaveformSampleReceived()));
    connect(device, SIGNAL(ecgWaveformSampleReceived()), this, SLOT(onEcgWaveformSampleReceived()));
    connect(device, SIGNAL(respirationRateChanged()), this, SLOT(onRespirationRateChanged()));
    connect(device, SIGNAL(monitoringChanged()), this, SLOT(onMonitoringChanged()));

    qDebug() << "Device connected:" << device->metaObject()->className();
}

void DeviceManager::disconnectDevice(QObject* device)
{
    if (!device) return;

    // Disconnect signals
    disconnect(device, SIGNAL(heartRateChanged()), this, SLOT(onHeartRateChanged()));
    disconnect(device, SIGNAL(spo2Changed()), this, SLOT(onSpo2Changed()));
    disconnect(device, SIGNAL(waveformSampleReceived()), this, SLOT(onWaveformSampleReceived()));
    disconnect(device, SIGNAL(respWaveformSampleReceived()), this, SLOT(onRespWaveformSampleReceived()));
    disconnect(device, SIGNAL(ecgWaveformSampleReceived()), this, SLOT(onEcgWaveformSampleReceived()));
    disconnect(device, SIGNAL(respirationRateChanged()), this, SLOT(onRespirationRateChanged()));
    disconnect(device, SIGNAL(monitoringChanged()), this, SLOT(onMonitoringChanged()));

    qDebug() << "Device disconnected:" << device->metaObject()->className();
}

// Signal forwarding slots
void DeviceManager::onHeartRateChanged() {
    emit heartRateChanged();

    if (!m_testMode && realDevice && !m_currentPatientId.isEmpty()) {
        databaseClass::instance()->insertMeasurement(
            m_currentPatientId,
            realDevice->heartRateValue(),
            realDevice->spo2Value(),
            realDevice->respirationRate()
            );
    }
}

void DeviceManager::onSpo2Changed() {
    emit spo2Changed();

    if (!m_testMode && realDevice && !m_currentPatientId.isEmpty()) {
        databaseClass::instance()->insertMeasurement(
            m_currentPatientId,
            realDevice->heartRateValue(),
            realDevice->spo2Value(),
            realDevice->respirationRate()
            );
    }
}

void DeviceManager::onWaveformSampleReceived()
{
    emit waveformSampleReceived();
}

void DeviceManager::onMonitoringChanged()
{
    emit monitoringChanged();
}

void DeviceManager::onTestModeChanged()
{
    emit testModeChanged();
}

void DeviceManager::onPrintCompleted(bool success, const QString& message)
{
    emit printCompleted(success, message);
}

bool DeviceManager::registerDoctor(const QString &username, const QString &password) {
    return databaseClass::instance()->registerDoctor(username, password);
}

bool DeviceManager::verifyDoctorLogin(const QString &username, const QString &password) {
    return databaseClass::instance()->verifyDoctorLogin(username, password);
}

// Web integration

void DeviceManager::sendMeasurementToServer(const QString &heartRate, const QString &spo2, const QString &resp)
{
    qDebug() << "fonksiyona girildi";

    // Get MAC address from the first valid network interface
    QString deviceId = "UnknownDevice";
    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : interfaces) {
        if (iface.flags().testFlag(QNetworkInterface::IsUp) &&
            iface.flags().testFlag(QNetworkInterface::IsRunning) &&
            !iface.hardwareAddress().isEmpty() &&
            iface.hardwareAddress() != "00:00:00:00:00:00") {
            deviceId = iface.hardwareAddress();
            break;
        }
    }

    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request(QUrl("http://127.0.0.1:5000/api/data"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["deviceId"] = deviceId; // Use MAC address
    json["heartRate"] = heartRate;
    json["spo2"] = spo2;
    json["resp"] = resp;
    json["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    QNetworkReply *reply = manager->post(request, QJsonDocument(json).toJson());

    connect(reply, &QNetworkReply::finished, this, [reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "✅ Data sent:" << reply->readAll();
        } else {
            qWarning() << "❌ Sending error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}

