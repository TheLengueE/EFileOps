#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtGlobal>
#include <QDebug>
#include "src/core/BaseRequest.h"
#include "src/core/BaseResponse.h"
#include "src/core/AppSettings.h"
#include "src/translation/TranslationManager.h"
#include "src/controller/MainController.h"
#include "src/model/FileListModel.h"
#include "src/util/SimpleLog.h"

// catch qml message function
static void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QString level;

    switch (type)
    {
    case QtDebugMsg:
        level = "DEBUG";
        break;
    case QtInfoMsg:
        level = "INFO";
        break;
    case QtWarningMsg:
        level = "WARN";
        break;
    case QtCriticalMsg:
        level = "ERROR";
        break;
    case QtFatalMsg:
        level = "FATAL";
        break;
    }

    QString line =
        QString("[%1] [%2] %3").arg(QDateTime::currentDateTime().toString("HH:mm:ss.zzz")).arg(level).arg(msg);

    SimpleLog::write("{}", line);
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Initialize qInstallMessageHandler
#ifdef QT_DEBUG
    qInstallMessageHandler(qtMessageHandler);
#endif

    // Set application metadata
    app.setOrganizationName("EFileOps");
    app.setOrganizationDomain("efileops.org");
    app.setApplicationName("EFileOps");
    app.setApplicationVersion("1.0.0");

    // Set Qt UI style
    QQuickStyle::setStyle("Basic");

    // Initialize application settings (singleton)
    AppSettings::instance();

    // Register common data types to QML (shared across all modules)
    qRegisterMetaType<BaseRequest>("BaseRequest");
    qRegisterMetaType<BaseResponse>("BaseResponse");

    // Register C++ types to QML
    qmlRegisterType<MainController>("EFileOps", 1, 0, "MainController");
    qmlRegisterType<FileListModel>("EFileOps", 1, 0, "FileListModel");

    // Create QML engine
    QQmlApplicationEngine engine;

    // Create and register translation manager instance
    TranslationManager translation_manager;
    engine.rootContext()->setContextProperty("translationManager", &translation_manager);
    QObject::connect(&translation_manager, &TranslationManager::languageChanged, [&engine]() { engine.retranslate(); });

    // Create and register main controller instance
    MainController main_controller;
    engine.rootContext()->setContextProperty("mainController", &main_controller);

    // Create and register file list model
    FileListModel file_list_model(main_controller.fileService());
    engine.rootContext()->setContextProperty("fileListModel", &file_list_model);

    // Set file list model reference to main controller (for auto-selection after adding files)
    main_controller.setFileListModel(&file_list_model);

    // Auto-restore session if enabled
    if (AppSettings::instance()->autoRestoreSession())
    {
        SimpleLog::write("[Main] Auto-restore enabled, loading previous session...");
        main_controller.loadSession();
    }

    // Connect app aboutToQuit signal to save session
    QObject::connect(&app, &QGuiApplication::aboutToQuit,
                     [&main_controller]()
                     {
                         SimpleLog::write("[Main] Application closing, saving session...");
                         main_controller.autoSaveSession();
                     });

    // Add import path for EUI components (loaded at runtime from qml/EUI/)
    QString qml_path = QCoreApplication::applicationDirPath() + "/qml";
    engine.addImportPath(qml_path);

    // Load main QML file
    const QUrl main_qml_url(u"qrc:/EFileOps/qml/Main.qml"_qs);

    // Connect loading failure signal
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [main_qml_url](QObject *obj, const QUrl &obj_url)
        {
            if (!obj && main_qml_url == obj_url)
            {
                SimpleLog::write("[Main] Failed to load main QML file, exiting application.");
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(main_qml_url);

    // Check if loading was successful
    if (engine.rootObjects().isEmpty())
    {
        SimpleLog::write("[Main] No root objects found after loading QML, exiting application.");
        return -1;
    }

    return app.exec();
}
