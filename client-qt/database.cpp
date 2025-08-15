#include "database.h"
#include <QCryptographicHash>

databaseClass::databaseClass(QObject *parent) : QObject(parent)
{}

// Static instance initialization
databaseClass* databaseClass::s_instance = nullptr;

// Singleton access
databaseClass* databaseClass::instance()
{
    if (!s_instance)
        s_instance = new databaseClass();
    return s_instance;
}

void databaseClass::setupDatabase()
{
    static bool alreadySetup = false;
    if (alreadySetup) {
        qWarning() << "setupDatabase has already been executed. Skipping.";
        return;
    }
    alreadySetup = true;

    database = QSqlDatabase::addDatabase("QSQLITE");
    database.setDatabaseName("vitalsigns.db");

    if (!database.open()) {
        qWarning() << "Failed to open database:" << database.lastError().text();
        return;
    }

    QSqlQuery query;

    // Create Doctors table
    QString createDoctorTable = R"(
        CREATE TABLE IF NOT EXISTS Doctors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
        )
    )";

    // Create Patients table
    QString createPatientsTable = R"(
        CREATE TABLE IF NOT EXISTS patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            surname TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            tc TEXT NOT NULL
        )
    )";

    // Create Monitor Data table
    QString createMeasurementsTable = R"(
        CREATE TABLE IF NOT EXISTS monitor_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            heartRate TEXT,
            spo2 TEXT,
            resp TEXT,
            FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        )
    )";

    if (!query.exec(createDoctorTable))
        qWarning() << "Failed to create Doctors table:" << query.lastError().text();
    else
        qDebug() << "Doctors table ready.";

    if (!query.exec(createPatientsTable))
        qWarning() << "Failed to create Patients table:" << query.lastError().text();
    else
        qDebug() << "Patients table ready.";

    if (!query.exec(createMeasurementsTable))
        qWarning() << "Failed to create monitor_data table:" << query.lastError().text();
    else
        qDebug() << "Measurements table ready.";
}

QVariantList databaseClass::getAllPatients()
{
    QVariantList patients;

    if (!database.isOpen()) {
        qWarning() << "Database is not open!";
        return patients;
    }

    QSqlQuery query;
    query.prepare("SELECT patient_id, name, surname, tc FROM patients ORDER BY name, surname");

    if (query.exec()) {
        while (query.next()) {
            QVariantMap patient;
            patient["patient_id"] = query.value("patient_id").toString();
            patient["name"] = query.value("name").toString();
            patient["surname"] = query.value("surname").toString();
            patient["tc"] = query.value("tc").toString();
            patients.append(patient);
        }
        qDebug() << "✅ Retrieved" << patients.count() << "patient records.";
    } else {
        qWarning() << "❌ Failed to retrieve patient list:" << query.lastError().text();
    }

    return patients;
}

bool databaseClass::addPatient(const QString& patientId, const QString& name, const QString& surname)
{
    if (!database.isOpen())
        return false;

    QSqlQuery query;
    query.prepare("INSERT INTO patients (patient_id, name, surname) VALUES (?, ?, ?)");
    query.addBindValue(patientId);
    query.addBindValue(name);
    query.addBindValue(surname);

    if (!query.exec()) {
        qWarning() << "Failed to add patient:" << query.lastError().text();
        return false;
    }

    qDebug() << "New patient added:" << patientId << name << surname;
    return true;
}

QVariantMap databaseClass::findPatient(const QString& name, const QString& surname, const QString& tc)
{
    QVariantMap result;
    QSqlQuery query;
    query.prepare("SELECT patient_id, name, surname, tc FROM patients WHERE name = :name AND surname = :surname AND tc = :tc");
    query.bindValue(":name", name);
    query.bindValue(":surname", surname);
    query.bindValue(":tc", tc);

    if (query.exec() && query.next()) {
        result["patient_id"] = query.value("patient_id").toString();
        result["name"] = query.value("name").toString();
        result["surname"] = query.value("surname").toString();
        result["tc"] = query.value("tc").toString();
    }

    return result;
}

bool databaseClass::verifyDoctorLogin(const QString& username, const QString& password)
{
    QSqlQuery query;
    query.prepare("SELECT password FROM Doctors WHERE username = :username");
    query.bindValue(":username", username);

    if (!query.exec() || !query.next()) {
        qWarning() << "User not found:" << query.lastError().text();
        return false;
    }

    QString storedHash = query.value(0).toString();
    QString inputHash = QString(QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256).toHex());

    return storedHash == inputHash;
}

bool databaseClass::registerDoctor(const QString& username, const QString& password)
{
    QString hashedPassword = QString(QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256).toHex());

    QSqlQuery query;
    query.prepare("INSERT INTO Doctors (username, password) VALUES (:username, :password)");
    query.bindValue(":username", username);
    query.bindValue(":password", hashedPassword);

    if (!query.exec()) {
        qWarning() << "Registration failed:" << query.lastError().text();
        return false;
    }

    return true;
}

void databaseClass::insertMeasurement(const QString &patientId, const QString &heartRate, const QString &spo2, const QString &resp)
{
    static QDateTime lastInsertTime;

    if (!database.isOpen())
        return;

    QDateTime now = QDateTime::currentDateTime();

    // Prevent inserting within 3 seconds of the last entry
    if (lastInsertTime.isValid() && lastInsertTime.secsTo(now) < 3) {
        return;
    }

    lastInsertTime = now;

    QString localTime = now.toString("yyyy-MM-dd HH:mm:ss");

    QSqlQuery query;
    query.prepare("INSERT INTO monitor_data (patient_id, timestamp, heartRate, spo2, resp) "
                  "VALUES (:pid, :ts, :hr, :sp, :resp)");
    query.bindValue(":pid", patientId);
    query.bindValue(":ts", localTime);
    query.bindValue(":hr", heartRate);
    query.bindValue(":sp", spo2);
    query.bindValue(":resp", resp);

    if (!query.exec()) {
        qWarning() << "Failed to insert measurement:" << query.lastError().text();
    } else {
        qDebug() << "Measurement inserted → Patient:" << patientId
                 << "| Time:" << localTime
                 << "| HR:" << heartRate
                 << "| SpO2:" << spo2
                 << "| RESP:" << resp;
    }
}

QVariantList databaseClass::getRecentMeasurements(const QString& patientId, int limit)
{
    QVariantList measurements;

    if (!database.isOpen()) {
        qWarning() << "Database is not open!";
        return measurements;
    }

    QSqlQuery query;
    query.prepare("SELECT timestamp, heartRate, spo2, resp FROM monitor_data "
                  "WHERE patient_id = :pid "
                  "ORDER BY timestamp DESC LIMIT :limit");
    query.bindValue(":pid", patientId);
    query.bindValue(":limit", limit);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap record;
            record["timestamp"] = query.value(0).toString();
            record["heartRate"] = query.value(1).toString();
            record["spo2"] = query.value(2).toString();
            record["resp"] = query.value(3).toString();
            measurements.append(record);
        }
        qDebug() << measurements.count() << "records retrieved (Patient ID:" << patientId << ")";
    } else {
        qWarning() << "Query error:" << query.lastError().text();
    }

    return measurements;
}
