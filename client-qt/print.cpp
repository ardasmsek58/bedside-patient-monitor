#include "print.h"

print::print(QObject *parent) : QObject(parent)
{}

bool print::printWaveformData(const QVariantList& waveformData, const QVariantList& timestamps,
                              const QVariantList& ecgData, const QVariantList& ecgTimestamps)
{
    QPrinter printer;
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Landscape); // Landscape layout
    printer.setOutputFormat(QPrinter::NativeFormat);

    QPrintDialog printDialog(&printer);
    printDialog.setWindowTitle("VitaScope Print Graph");

    if (printDialog.exec() != QDialog::Accepted) {
        emit printCompleted(false, "Printing canceled");
        return false;
    }

    QPainter painter(&printer);
    if (!painter.isActive()) {
        emit printCompleted(false, "Printing could not be started");
        return false;
    }

    QRect pageRect = printer.pageRect(QPrinter::DevicePixel).toRect();
    int pageWidth = pageRect.width();
    int pageHeight = pageRect.height();

    int yPos = 0;

    // Report header
    drawReportHeader(&painter, pageWidth, yPos);

    // Vital signs section
    drawVitalSigns(&painter, pageWidth, yPos);

    // Adjust graph height for landscape layout
    int graphHeight = (pageHeight - yPos - 150) / (ecgData.isEmpty() ? 1 : 2) - 30;

    // SpO₂ waveform
    QRect spo2GraphRect(50, yPos, pageWidth - 100, graphHeight);
    drawGridOnPainter(&painter, spo2GraphRect);
    drawWaveformOnPainter(&painter, waveformData, spo2GraphRect, "SpO₂ Waveform", QColor(0, 188, 212));
    yPos = spo2GraphRect.bottom() + 30;

    // ECG waveform (if available)
    if (!ecgData.isEmpty()) {
        QRect ecgGraphRect(50, yPos, pageWidth - 100, graphHeight);
        drawGridOnPainter(&painter, ecgGraphRect);
        drawWaveformOnPainter(&painter, ecgData, ecgGraphRect, "ECG Waveform", QColor(255, 87, 34));
        yPos = ecgGraphRect.bottom() + 30;

        // Footer info
        drawReportFooter(&painter, pageWidth, yPos, ecgGraphRect);
    } else {
        // If no ECG, footer for SpO₂ graph
        drawReportFooter(&painter, pageWidth, yPos, spo2GraphRect);
    }

    painter.end();

    emit printCompleted(true, "Graph printed successfully");
    return true;
}

bool print::saveWaveformToPDF(const QVariantList& waveformData, const QVariantList& timestamps,
                              const QString& filename, const QVariantList& ecgData, const QVariantList& ecgTimestamps)
{
    QString documentsPath = getDocumentsPath();
    QString pdfFileName = filename.isEmpty() ?
                              QString("VitaScope_Graph_%1.pdf").arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss")) :
                              filename;

    QString fullPath = documentsPath + "/" + pdfFileName;

    QPrinter printer;
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Landscape); // Landscape layout
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setOutputFileName(fullPath);

    QPainter painter(&printer);
    if (!painter.isActive()) {
        emit printCompleted(false, "PDF could not be created");
        return false;
    }

    QRect pageRect = printer.pageRect(QPrinter::DevicePixel).toRect();
    int pageWidth = pageRect.width();
    int pageHeight = pageRect.height();

    int yPos = 0;

    // Report header
    drawReportHeader(&painter, pageWidth, yPos);

    // Vital signs section
    drawVitalSigns(&painter, pageWidth, yPos);

    // Adjust graph height for landscape layout
    int graphHeight = (pageHeight - yPos - 150) / (ecgData.isEmpty() ? 1 : 2) - 30;

    // SpO₂ waveform
    QRect spo2GraphRect(50, yPos, pageWidth - 100, graphHeight);
    drawGridOnPainter(&painter, spo2GraphRect);
    drawWaveformOnPainter(&painter, waveformData, spo2GraphRect, "SpO₂ Waveform", QColor(0, 188, 212));
    yPos = spo2GraphRect.bottom() + 30;

    // ECG waveform (if available)
    if (!ecgData.isEmpty()) {
        QRect ecgGraphRect(50, yPos, pageWidth - 100, graphHeight);
        drawGridOnPainter(&painter, ecgGraphRect);
        drawWaveformOnPainter(&painter, ecgData, ecgGraphRect, "ECG Waveform", QColor(255, 87, 34));
        yPos = ecgGraphRect.bottom() + 30;

        // Footer info
        drawReportFooter(&painter, pageWidth, yPos, ecgGraphRect);
    } else {
        // If no ECG, footer for SpO₂ graph
        drawReportFooter(&painter, pageWidth, yPos, spo2GraphRect);
    }

    painter.end();

    emit printCompleted(true, "PDF saved successfully: " + fullPath);
    return true;
}

QString print::getDocumentsPath()
{
    QString documentsPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    // Create VitaScope folder
    QDir dir(documentsPath);
    if (!dir.exists("VitaScope")) {
        dir.mkpath("VitaScope");
    }

    return documentsPath + "/VitaScope";
}

void print::drawWaveformOnPainter(QPainter* painter, const QVariantList& waveformData, const QRect& rect,
                                  const QString& title, const QColor& color)
{
    if (waveformData.isEmpty() || !painter) {
        return;
    }

    // Draw waveform
    painter->setPen(QPen(color, 2));
    painter->setRenderHint(QPainter::Antialiasing, true);

    QPolygonF waveform;

    for (int i = 0; i < waveformData.size(); ++i) {
        bool ok;
        double value = waveformData[i].toDouble(&ok);
        if (!ok) continue;

        // X coordinate: distribute across graph width
        double x = rect.left() + (static_cast<double>(i) / (waveformData.size() - 1)) * rect.width();

        // Y coordinate: normalize 0-255 range to graph height
        double y = rect.bottom() - (value / 255.0) * rect.height();

        waveform.append(QPointF(x, y));
    }

    if (waveform.size() > 1) {
        painter->drawPolyline(waveform);
    }

    // Draw graph border
    painter->setPen(QPen(Qt::black, 1));
    painter->drawRect(rect);

    // Graph title
    painter->setFont(QFont("Arial", 10, QFont::Bold));
    painter->setPen(QPen(color, 2));
    painter->drawText(rect.left() + 10, rect.top() + 20, title);
    painter->setPen(QPen(Qt::black, 1));
    painter->setFont(QFont("Arial", 9));
    painter->drawText(rect.right() - 100, rect.top() + 20, "Speed: 25mm/s");

    // Y-axis values
    painter->drawText(rect.left() - 30, rect.top() + 10, "255");
    painter->drawText(rect.left() - 30, rect.center().y(), "128");
    painter->drawText(rect.left() - 30, rect.bottom() - 5, "0");

    // X-axis time labels
    painter->drawText(rect.left(), rect.bottom() + 20, "0s");
    painter->drawText(rect.left() + rect.width() * 0.25, rect.bottom() + 20, "1.25s");
    painter->drawText(rect.center().x() - 10, rect.bottom() + 20, "2.5s");
    painter->drawText(rect.left() + rect.width() * 0.75, rect.bottom() + 20, "3.75s");
    painter->drawText(rect.right() - 20, rect.bottom() + 20, "5s");
}

void print::drawGridOnPainter(QPainter* painter, const QRect& rect)
{
    if (!painter) return;

    painter->setPen(QPen(QColor(200, 200, 200), 1, Qt::DotLine));

    // Vertical grid lines
    int verticalLines = 20;
    for (int i = 0; i <= verticalLines; ++i) {
        double x = rect.left() + (static_cast<double>(i) / verticalLines) * rect.width();
        painter->drawLine(QPointF(x, rect.top()), QPointF(x, rect.bottom()));
    }

    // Horizontal grid lines
    int horizontalLines = 8;
    for (int i = 0; i <= horizontalLines; ++i) {
        double y = rect.top() + (static_cast<double>(i) / horizontalLines) * rect.height();
        painter->drawLine(QPointF(rect.left(), y), QPointF(rect.right(), y));
    }
}

void print::drawReportHeader(QPainter* painter, int pageWidth, int& yPos)
{
    painter->setFont(QFont("Arial", 16, QFont::Bold));
    painter->setPen(QPen(Qt::black, 2));
    painter->drawText(QRect(0, yPos, pageWidth, 80), Qt::AlignCenter, "VitaScope - Multi-Parameter Patient Monitor Report");
    yPos += 100; // Reserve space for header
}

void print::drawVitalSigns(QPainter* painter, int pageWidth, int& yPos)
{
    painter->setFont(QFont("Arial", 12));
    painter->setPen(QPen(Qt::black, 1));

    QString date = QDateTime::currentDateTime().toString("dd.MM.yyyy");
    QString time = QDateTime::currentDateTime().toString("hh:mm:ss");

    int leftX = 50;              // Left block position
    int rightX = pageWidth - 150; // Right block position
    int lineHeight = 20;          // Line spacing

    // Left block: Date & Time
    painter->drawText(leftX, yPos, "Date: " + date);
    yPos += lineHeight;
    painter->drawText(leftX, yPos, "Time: " + time);

    // Right block: Vital Signs
    int rightY = yPos - (lineHeight * 2);
    painter->drawText(rightX, rightY, "Respiration: " + m_respirationRate + " br/min");
    rightY += lineHeight;
    painter->drawText(rightX, rightY, "SpO₂: " + m_spo2 + "%");
    rightY += lineHeight;
    painter->drawText(rightX, rightY, "Heart Rate: " + m_heartRate + " bpm");

    yPos += 30; // Leave space for lower content
}

void print::drawReportFooter(QPainter* painter, int pageWidth, int& yPos, const QRect& lastGraphRect)
{
    painter->setFont(QFont("Arial", 10));
    painter->setPen(QPen(Qt::black, 1));

    yPos += 30;
    // Footer info
    painter->drawText(50, yPos, "Note: This graph shows 5 seconds of waveform data. | Speed: 25mm/s | Device: VitaScope Monitor");
    yPos += 15;
    painter->drawText(50, yPos, "SpO₂: Blood Oxygen Saturation | ECG: Electrocardiogram | Resp: Respiration | Printed: " + QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss"));
}

QString print::getCurrentDateTime()
{
    return QDateTime::currentDateTime().toString("dd.MM.yyyy");
}
