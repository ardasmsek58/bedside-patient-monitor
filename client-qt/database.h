#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariantList>
#include <QVariantMap>
#include <QDateTime>
#include <QDebug>

class databaseClass : public QObject
{
    Q_OBJECT

public:
    explicit databaseClass(QObject *parent = nullptr);

    static databaseClass* instance();

    // Database setup
    void setupDatabase();

    // Insert measurement (with 3-second control)
    Q_INVOKABLE void insertMeasurement(const QString& patientId, const QString& heartRate, const QString& spo2, const QString& resp);

    // Get recent measurements
    Q_INVOKABLE QVariantList getRecentMeasurements(const QString& patientId, int limit = 20);

    // Verify login credentials
    Q_INVOKABLE bool verifyDoctorLogin(const QString& username, const QString& password);

    // Register a new doctor
    Q_INVOKABLE bool registerDoctor(const QString& username, const QString& password);

    // Add a new patient record
    Q_INVOKABLE bool addPatient(const QString& patientId, const QString& name, const QString& surname);

    // Retrieve a specific patient
    QVariantMap findPatient(const QString& name, const QString& surname, const QString& tc);

    // Get all patients
    QVariantList getAllPatients();

private:

    QSqlDatabase database;
    static databaseClass* s_instance;
};

#endif // DATABASE_H
