# Client (Qt/QML)

Bu klasör, Qt/QML kullanılarak geliştirilen masaüstü hasta başı monitör uygulamasını içerir.

## İçerik
- **bedside_monitor_qmake.pro** — qmake proje dosyası.
- **main.cpp** — Qt uygulamasının giriş noktası.
- **main.qml** — Ana kullanıcı arayüzü (UI).
- **database.cpp / .h** — SQLite veritabanı entegrasyonu.
- **devicemanager.cpp / .h** — Seri port üzerinden cihaz ile veri iletişimi ve paket çözümleme.
- **print.cpp / .h** — QPrinter kullanarak yazdırma işlemleri.
- **smmprotocoltest.cpp / .h** — pSMM-V12.1 protokolü ile veri işleme.
- **testmode.cpp / .h** — Test modu ve sahte veri üretimi.
- **components/** — QML bileşenleri (doktor ve ziyaretçi arayüzleri).

## Notlar
- `build/` klasörü versiyon kontrolüne dahil edilmez.
- Qt 6.2+ ile uyumlu şekilde geliştirilmiştir.
