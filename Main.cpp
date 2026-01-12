#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QDebug>
#include "src/core/BaseRequest.h"
#include "src/core/BaseResponse.h"
#include "src/core/AppSettings.h"
#include "src/translation/TranslationManager.h"
#include "src/controller/MainController.h"
#include "src/model/FileListModel.h"

int main(int argc, char *argv[])
{
    // Initialize application
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("EFileOps");
    app.setOrganizationDomain("efileops.org");
    app.setApplicationName("EFileOps");
    app.setApplicationVersion("0.1.0");

    // Set UI style
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
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    // Load QML
    engine.load(main_qml_url);

    // Check if loading was successful
    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "Failed to load QML!";
        return -1;
    }

    // Start event loop
    return app.exec();
}
