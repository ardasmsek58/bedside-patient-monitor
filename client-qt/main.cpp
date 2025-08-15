#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QDir>
#include <QQmlContext>
#include <QDebug>
#include "devicemanager.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");

    QApplication app(argc, argv);
    app.setApplicationName("VitaScope Monitor");

    QQmlApplicationEngine engine;

    // Register DeviceManager to QML
    qmlRegisterType<DeviceManager>("SMMProtocol", 1, 0, "DeviceManager");
    DeviceManager deviceManager;
    engine.rootContext()->setContextProperty("deviceManager", &deviceManager);

    // Add import directory (for components folder)
    engine.addImportPath(QDir::currentPath());

    // ✅ Set the correct path for the main QML file
    const QUrl mainQmlUrl = QUrl::fromLocalFile("/Users/ardasimsek/Documents/bedside_monitor/bedside_monitor_qmake/main.qml");

    // ❗️Exit if QML fails to load
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [mainQmlUrl](QObject *obj, const QUrl &objUrl) {
                         if (!obj && objUrl == mainQmlUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(mainQmlUrl);

    qDebug() << "✅ QML path loaded:" << mainQmlUrl.toString();

    return app.exec();
}
