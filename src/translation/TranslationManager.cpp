#include "TranslationManager.h"
#include "../core/BaseRequest.h"
#include "../core/BaseResponse.h"
#include <QCoreApplication>
#include <QLocale>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QSettings>

TranslationManager::TranslationManager(QObject *parent)
    : QObject(parent), translator_(new QTranslator(this)), current_locale_("en_US")
{
    // Initialize translation files path
    translations_path_ = QCoreApplication::applicationDirPath() + "/translations";

    // Initialize available locales list
    InitializeAvailableLocales();

    // Try to load system language
    const QLocale system_locale      = QLocale::system();
    QString       system_locale_name = system_locale.name();

    qDebug() << "[TranslationManager] System locale:" << system_locale_name;
    qDebug() << "[TranslationManager] Translations path:" << translations_path_;

    // Determine initial language: Saved > System > English (source)
    QString initial_locale = "en_US"; // Default to English (source text language)
    
    // Try to load saved language preference from settings
    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
    QString saved_locale = settings.value("language", "").toString();
    
    if (!saved_locale.isEmpty() && IsValidLocale(saved_locale))
    {
        initial_locale = saved_locale;
        qDebug() << "[TranslationManager] Using saved language preference:" << saved_locale;
    }
    else if (IsValidLocale(system_locale_name))
    {
        // Use system language if supported
        initial_locale = system_locale_name;
        qDebug() << "[TranslationManager] Using system language:" << system_locale_name;
    }
    else
    {
        qDebug() << "[TranslationManager] System language not supported, using English";
    }

    qDebug() << "[TranslationManager] ========== Initialization Start ==========";
    qDebug() << "[TranslationManager] Available locales:" << available_locales_;
    qDebug() << "[TranslationManager] Attempting to load language:" << initial_locale;
    
    auto response = HandleSwitchLanguage(initial_locale);
    if (!response.success)
    {
        qWarning() << "[TranslationManager] ✗ Failed to load language:" << response.message;
        // Fallback to English if initial language fails
        if (initial_locale != "en_US")
        {
            qDebug() << "[TranslationManager] Falling back to English";
            HandleSwitchLanguage("en_US");
        }
    }
    else
    {
        qDebug() << "[TranslationManager] ✓ Successfully loaded language:" << initial_locale;
    }
    qDebug() << "[TranslationManager] ========== Initialization End ==========";
    qDebug() << "";
}

TranslationManager::~TranslationManager()
{
    if (translator_)
    {
        QCoreApplication::removeTranslator(translator_);
    }
}

void TranslationManager::InitializeAvailableLocales()
{
    // Define supported languages list
    available_locales_ = {"zh_CN", "en_US", "de_DE"};

    // Optional: Scan translations directory to verify file existence
    QDir dir(translations_path_);
    if (dir.exists())
    {
        qDebug() << "[TranslationManager] Available translations:";
        for (const QString &locale : available_locales_)
        {
            QString qm_file = QString("fileops_%1.qm").arg(locale);
            bool    exists  = QFileInfo::exists(dir.filePath(qm_file));
            qDebug() << "  -" << locale << ":" << (exists ? "✓" : "✗");
        }
    }
    else
    {
        qWarning() << "[TranslationManager] Translations directory not found:" << translations_path_;
    }
}

bool TranslationManager::IsValidLocale(QString locale) const { return available_locales_.contains(locale); }

BaseResponse TranslationManager::handleRequest(QString module, QString action, QVariantMap params)
{
    // Validate module name
    if (module != "translation")
    {
        return BaseResponse::Error("Invalid module name. Expected 'translation'", ErrorCode::INVALID_PARAM);
    }

    // Dispatch based on action
    BaseResponse response;

    if (action == "switch")
    {
        QString locale = params.value("locale").toString();
        response       = HandleSwitchLanguage(locale);
    }
    else if (action == "getState")
    {
        response = HandleGetState();
    }
    else if (action == "getAvailable")
    {
        response = BaseResponse::Success("Available languages retrieved");
        response.setData("availableLocales", available_locales_);
        response.setData("currentLocale", current_locale_);
    }
    else
    {
        response = BaseResponse::Error(
            QString("Unknown action: %1\nSupported actions: switch, getState, getAvailable").arg(action),
            ErrorCode::INVALID_PARAM);
    }

    return response;
}

BaseResponse TranslationManager::HandleSwitchLanguage(QString locale)
{
    // Validate parameters
    if (locale.isEmpty())
    {
        return BaseResponse::Error("Language code cannot be empty. Please provide a valid locale (e.g., zh_CN, en_US)",
                                   ErrorCode::INVALID_PARAM);
    }

    if (!IsValidLocale(locale))
    {
        return BaseResponse::Error(
            QString("Unsupported language: %1\nAvailable languages: %2").arg(locale).arg(available_locales_.join(", ")),
            ErrorCode::INVALID_PARAM);
    }

    // Check if already set to current language
    if (current_locale_ == locale)
    {
        qDebug() << "[TranslationManager] Language already set to:" << locale;
        return BaseResponse::Success(QString("Language already set to %1").arg(locale))
            .setData("currentLocale", locale)
            .setData("availableLocales", available_locales_);
    }

    // Remove old translator
    QCoreApplication::removeTranslator(translator_);

    // Load new translation
    const QString qm_file = QString("fileops_%1").arg(locale);
    const QString full_path = translations_path_ + "/" + qm_file + ".qm";
    qDebug() << "[TranslationManager] ========== Loading Translation ==========";
    qDebug() << "[TranslationManager] QM file name:" << qm_file;
    qDebug() << "[TranslationManager] Full path:" << full_path;
    qDebug() << "[TranslationManager] Translations path:" << translations_path_;
    qDebug() << "[TranslationManager] File exists:" << QFileInfo::exists(full_path);

    if (translator_->load(qm_file, translations_path_))
    {
        qDebug() << "[TranslationManager] ✓ QM file loaded successfully";
        
        // Install new translator
        bool installed = QCoreApplication::installTranslator(translator_);
        qDebug() << "[TranslationManager] Translator installed:" << (installed ? "✓ YES" : "✗ NO");
        
        // **CRITICAL**: Send LanguageChange event to trigger UI retranslation
        // This forces all QML Text/Label components to re-evaluate their text bindings
        QEvent languageChangeEvent(QEvent::LanguageChange);
        QCoreApplication::sendEvent(QCoreApplication::instance(), &languageChangeEvent);
        qDebug() << "[TranslationManager] ✓ LanguageChange event sent to QML engine";
        
        // Test translation with English source text
        QString test_tr = QCoreApplication::translate("ReplaceRule", "Find and Replace");
        qDebug() << "[TranslationManager] Test translation (Find and Replace):" << test_tr;

        // Update current locale
        QString old_locale = current_locale_;
        current_locale_    = locale;

        // Save language preference to settings
        QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
        settings.setValue("language", locale);
        settings.sync();

        qDebug() << "[TranslationManager] ✓ Language switched:" << old_locale << "→" << locale;
        qDebug() << "[TranslationManager] ✓ Language preference saved to settings";
        qDebug() << "[TranslationManager] ========== Translation Loaded ==========";
        qDebug() << "";

        // Create success response
        BaseResponse response = BaseResponse::Success(QString("Language switched to %1").arg(locale));
        response.setData("currentLocale", locale);
        response.setData("previousLocale", old_locale);
        response.setData("availableLocales", available_locales_);

        // Emit signals
        emit currentLocaleChanged();
        emit languageChanged(response);

        return response;
    }
    else
    {
        // Load failed, restore old translation
        qWarning() << "[TranslationManager] ✗ Failed to load QM file";
        qWarning() << "[TranslationManager] Attempted file:" << qm_file;
        qWarning() << "[TranslationManager] Attempted path:" << translations_path_;
        qWarning() << "[TranslationManager] Full file path:" << full_path;
        
        QDir dir(translations_path_);
        if (dir.exists()) {
            qWarning() << "[TranslationManager] Directory contents:";
            QStringList files = dir.entryList(QDir::Files);
            for (const QString &file : files) {
                qWarning() << "  -" << file;
            }
        } else {
            qWarning() << "[TranslationManager] ✗ Translations directory does not exist!";
        }

        const QString old_qm_file = QString("fileops_%1").arg(current_locale_);
        if (translator_->load(old_qm_file, translations_path_))
        {
            QCoreApplication::installTranslator(translator_);
            qDebug() << "[TranslationManager] Restored previous translator:" << old_qm_file;
        }

        return BaseResponse::Error(
            QString("Failed to load translation file: %1.qm\nPlease check if the file exists in:\n%2")
                .arg(qm_file)
                .arg(translations_path_),
            ErrorCode::NOT_FOUND);
    }
}

BaseResponse TranslationManager::HandleGetState()
{
    BaseResponse response = BaseResponse::Success(QString("Current language: %1").arg(current_locale_));
    response.setData("currentLocale", current_locale_);
    response.setData("availableLocales", available_locales_);
    return response;
}
