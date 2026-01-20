#include "AppSettings.h"
#include <QCoreApplication>
#include <QStandardPaths>

AppSettings *AppSettings::instance_ = nullptr;

AppSettings::AppSettings(QObject *parent)
    : QObject(parent), settings_(nullptr), ignore_extension_(false), // Default: do not ignore extension
      default_sort_mode_(0),                                         // Default: sort by name
      language_("en_US"),                                            // Default: English
      auto_restore_session_(true)                                    // Default: auto restore
{
    // Create QSettings using application organization and name
    settings_ = new QSettings(QCoreApplication::organizationName(), QCoreApplication::applicationName(), this);

    load();
}

AppSettings::~AppSettings() { save(); }

AppSettings *AppSettings::instance()
{
    if (!instance_)
    {
        instance_ = new AppSettings();
    }
    return instance_;
}

void AppSettings::setIgnoreExtension(bool ignore)
{
    if (ignore_extension_ != ignore)
    {
        ignore_extension_ = ignore;
        save();
        emit ignoreExtensionChanged();
    }
}

void AppSettings::setDefaultSortMode(int mode)
{
    if (default_sort_mode_ != mode)
    {
        default_sort_mode_ = mode;
        save();
        emit defaultSortModeChanged();
    }
}

void AppSettings::setLanguage(const QString &lang)
{
    if (language_ != lang)
    {
        language_ = lang;
        save();
        emit languageChanged();
    }
}

void AppSettings::setAutoRestoreSession(bool enable)
{
    if (auto_restore_session_ != enable)
    {
        auto_restore_session_ = enable;
        save();
        emit autoRestoreSessionChanged();
    }
}

QString AppSettings::getSessionFilePath() const
{
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    return dataPath + "/session.json";
}

void AppSettings::save()
{
    if (settings_)
    {
        settings_->setValue("ignoreExtension", ignore_extension_);
        settings_->setValue("defaultSortMode", default_sort_mode_);
        settings_->setValue("language", language_);
        settings_->setValue("autoRestoreSession", auto_restore_session_);
        settings_->sync();
    }
}

void AppSettings::load()
{
    if (settings_)
    {
        ignore_extension_     = settings_->value("ignoreExtension", false).toBool();
        default_sort_mode_    = settings_->value("defaultSortMode", 0).toInt();
        language_             = settings_->value("language", "zh_CN").toString();
        auto_restore_session_ = settings_->value("autoRestoreSession", true).toBool();
    }
}
