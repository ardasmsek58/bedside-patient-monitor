QT += core gui qml quick serialport sql printsupport quickcontrols2

CONFIG += c++17
CONFIG += qt quick

SOURCES += \
    main.cpp \
    smmprotocoltest.cpp \
    testmode.cpp \
    database.cpp \
    print.cpp \
    devicemanager.cpp

HEADERS += \
    smmprotocoltest.h \
    testmode.h \
    database.h \
    print.h \
    devicemanager.h

RESOURCES += \
    resources.qrc


QML_IMPORT_PATH += components

DISTFILES += \
    components/doctor/BottomBar.qml \
    components/doctor/BottomVitalsRow.qml \
    components/doctor/DoctorLogin.qml \
    components/doctor/DoctorRegister.qml \
    components/doctor/DoctorView.qml \
    components/doctor/PatientSelector.qml \
    components/doctor/PrintDialog.qml \
    components/doctor/TestModeButton.qml \
    components/doctor/VitalsGraphRow.qml \
    components/doctor/history.qml \
    main.qml \
    DoctorView.qml \
    GuestView.qml \
    DoctorLogin.qml \
    DoctorRegister.qml \
    TestModeButton.qml


OTHER_FILES += \
    components/doctor/*.qml \
    components/visitor/*.qml \
    components/*.qml \
    main.qml
