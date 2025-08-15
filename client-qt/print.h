#ifndef PRINT_H
#define PRINT_H

#include <QObject>
#include <QPrinter>
#include <QPainter>
#include <QPrintDialog>
#include <QPageLayout>
#include <QPageSize>
#include <QDialog>
#include <QDateTime>
#include <QStandardPaths>
#include <QDir>
#include <QVariantList>
#include <QFont>
#include <QPen>
#include <QPolygonF>
#include <QRect>
#include <QColor>
#include <QDebug>

class print : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString heartRate READ heartRate WRITE setHeartRate NOTIFY heartRateChanged)
    Q_PROPERTY(QString spo2 READ spo2 WRITE setSpo2 NOTIFY spo2Changed)
    Q_PROPERTY(QString respirationRate READ respirationRate WRITE setRespirationRate NOTIFY respirationRateChanged)

public:
    explicit print(QObject *parent = nullptr);

    QString heartRate() const { return m_heartRate; }
    void setHeartRate(const QString &heartRate) {
        if (m_heartRate != heartRate) {
            m_heartRate = heartRate;
            emit heartRateChanged();
        }
    }
    QString spo2() const { return m_spo2; }
    void setSpo2(const QString &spo2) {
        if (m_spo2 != spo2) {
            m_spo2 = spo2;
            emit spo2Changed();
        }
    }
    QString respirationRate() const { return m_respirationRate; }
    void setRespirationRate(const QString &respirationRate) {
        if (m_respirationRate != respirationRate) {
            m_respirationRate = respirationRate;
            emit respirationRateChanged();
        }
    }

public slots:

    bool printWaveformData(const QVariantList& waveformData, const QVariantList& timestamps,
                           const QVariantList& ecgData = QVariantList(), const QVariantList& ecgTimestamps = QVariantList());
    bool saveWaveformToPDF(const QVariantList& waveformData, const QVariantList& timestamps,
                           const QString& filename = "", const QVariantList& ecgData = QVariantList(),
                           const QVariantList& ecgTimestamps = QVariantList());

signals:

    void heartRateChanged();
    void spo2Changed();
    void respirationRateChanged();
    void printCompleted(bool success, const QString& message);

private:

    QString m_heartRate = "0";
    QString m_spo2 = "0";
    QString m_respirationRate = "0";

    // Helper functions
    QString getDocumentsPath();
    void drawWaveformOnPainter(QPainter* painter, const QVariantList& waveformData, const QRect& rect,
                               const QString& title, const QColor& color);
    void drawGridOnPainter(QPainter* painter, const QRect& rect);
    QString getCurrentDateTime();
    void drawReportHeader(QPainter* painter, int pageWidth, int& yPos);
    void drawVitalSigns(QPainter* painter, int pageWidth, int& yPos);
    void drawReportFooter(QPainter* painter, int pageWidth, int& yPos, const QRect& lastGraphRect);
};

#endif // PRINT_H
