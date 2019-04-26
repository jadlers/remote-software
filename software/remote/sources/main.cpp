#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QFile>
#include <QFileInfo>

#include "launcher.h"
#include "jsonfile.h"
#include "display_control.h"
#include "translation.h"


int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    //    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    
    // LOADING FONTS
    QFontDatabase::addApplicationFont(QStringLiteral("/usr/lib/fonts/OpenSans-Regular.ttf"));
    QFontDatabase::addApplicationFont(QStringLiteral("/usr/lib/fonts/OpenSans-Light.ttf"));
    QFontDatabase::addApplicationFont(QStringLiteral("/usr/lib/fonts/OpenSans-Bold.ttf"));

    // LOADING CUSTOM SCRIPT LAUNCHER AND JSON READER
    qmlRegisterType<Launcher>("Launcher", 1, 0, "Launcher");
    qmlRegisterType<JsonFile>("JsonFile", 1, 0, "JsonFile");
    qmlRegisterType<DisplayControl>("DisplayControl", 1, 0, "DisplayControl");
    
    QQmlApplicationEngine engine;

    // Get the applications dir path and expose it to QML (prevents setting the JSON config variable)
    QString appPath = app.applicationDirPath();
    QString macPath = QFileInfo(appPath + "/../../").canonicalPath();

    // In case the translation file does not exist at root level (which is copied via the .pro file)
    // we are probably running on a mac, which gives a different result for the applicationDirPath
    // (actually points to '.../remote.app/Contents/MacOS/remote')
    if ((!QFile::exists(appPath + "/translations.json")) && (QFile::exists(macPath + "/translations.json"))) {
        appPath = macPath;
    }
    engine.rootContext()->setContextProperty("appPath", appPath);

    // Determine configuration path
    QString configPath = appPath;
    if (QFile::exists("/mnt/boot/config.json")) {
        configPath = "/mnt/boot";
    }
    engine.rootContext()->setContextProperty("configPath", configPath);

    // TRANSLATION
    TranslationHandler transHndl(&engine);
    engine.rootContext()->setContextProperty("translateHandler", &transHndl);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}