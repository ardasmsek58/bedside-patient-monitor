#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QNetworkAccessManager>
#include "smmprotocoltest.h"
#include "testmode.h"
#include "print.h"
#include "database.h"

class DeviceManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString heartRateValue READ heartRateValue NOTIFY heartRateChanged)
    Q_PROPERTY(QString spo2Value READ spo2Value NOTIFY spo2Changed)
    Q_PROPERTY(int waveformSample READ waveformSample NOTIFY waveformSampleReceived)
    Q_PROPERTY(bool isMonitoring READ isMonitoring NOTIFY monitoringChanged)
    Q_PROPERTY(bool testMode READ testMode WRITE setTestMode NOTIFY testModeChanged)
    Q_PROPERTY(int respWaveformSample READ respWaveformSample NOTIFY respWaveformSampleReceived)
    Q_PROPERTY(int ecgWaveformSample READ ecgWaveformSample NOTIFY ecgWaveformSampleReceived)
    Q_PROPERTY(QString respirationRate READ respirationRate NOTIFY respirationRateChanged)
    Q_PROPERTY(QString userRole READ userRole WRITE setUserRole NOTIFY userRoleChanged)
    Q_PROPERTY(QString currentPatientId READ currentPatientId WRITE setCurrentPatientId NOTIFY currentPatientIdChanged)

public:
    explicit DeviceManager(QObject *parent = nullptr);

    QString currentPatientId() const;
    QString userRole() const;
    QString respirationRate() const;
    QString heartRateValue() const;
    QString spo2Value() const;
    int waveformSample() const;
    bool isMonitoring() const;
    bool testMode() const;
    int respWaveformSample() const;
    int ecgWaveformSample() const;
    void setUserRole(const QString& role);

    Q_INVOKABLE bool registerDoctor(const QString &username, const QString &password);
    Q_INVOKABLE bool verifyDoctorLogin(const QString &username, const QString &password);
    Q_INVOKABLE bool addPatient(const QString& id, const QString& name, const QString& surname, const QString& tc);
    Q_INVOKABLE void setCurrentPatientId(const QString& id);
    Q_INVOKABLE QVariantList getRecentMeasurementsForPatient(const QString& patientId, int limit = 20);
    Q_INVOKABLE QVariantMap findPatient(const QString& name, const QString& surname, const QString& tc);
    Q_INVOKABLE QVariantList getAllPatients();


public slots:

    void startMonitoring();
    void stopMonitoring();
    void setTestMode(bool enabled);

    bool printWaveformData(const QVariantList& waveformData,
                           const QVariantList& timestamps,
                           const QVariantList& ecgData,
                           const QVariantList& ecgTimestamps);

    bool saveWaveformToPDF(const QVariantList& waveformData,
                           const QVariantList& timestamps,
                           const QString& filename,
                           const QVariantList& ecgData,
                           const QVariantList& ecgTimestamps);

    void sendMeasurementToServer(const QString &heartRate, const QString &spo2, const QString &resp);


signals:

    void respirationRateChanged();
    void heartRateChanged();
    void spo2Changed();
    void waveformSampleReceived();
    void monitoringChanged();
    void testModeChanged();
    void printCompleted(bool success, const QString& message);
    void respWaveformSampleReceived();
    void ecgWaveformSampleReceived();
    void userRoleChanged();
    void currentPatientIdChanged();

private slots:

    void onHeartRateChanged();
    void onSpo2Changed();
    void onWaveformSampleReceived();
    void onMonitoringChanged();
    void onTestModeChanged();
    void onPrintCompleted(bool success, const QString& message);
    void onRespWaveformSampleReceived();
    void onEcgWaveformSampleReceived();
    void onRespirationRateChanged();

private:

    SMMProtocolTest *realDevice;
    testmode *testDevice;
    print *printer;
    databaseClass *database;

    // Status variables
    bool m_testMode = false;

    // Helper function to return the active device
    QObject* getActiveDevice() const;

    // Functions to set up connections
    void setupConnections();
    void connectDevice(QObject* device);
    void disconnectDevice(QObject* device);

    // For user separation
    QString m_userRole = "guest"; // default
    QString m_currentPatientId;


};

#endif // DEVICEMANAGER_H
