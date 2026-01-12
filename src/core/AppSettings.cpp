#include "AppSettings.h"
#include <QCoreApplication>

AppSettings *AppSettings::instance_ = nullptr;

AppSettings::AppSettings(QObject *parent)
    : QObject(parent), settings_(nullptr), ignore_extension_(false), // Default: do not ignore extension
      default_sort_mode_(0)                                           // Default: sort by name
{
    // Create QSettings using application organization and name
    settings_ = new QSettings(QCoreApplication::organizationName(), QCoreApplication::applicationName(), this

    );

    // Load settings
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

void AppSettings::save()
{
    if (settings_)
    {
        settings_->setValue("ignoreExtension", ignore_extension_);
        settings_->setValue("defaultSortMode", default_sort_mode_);
        settings_->sync();
    }
}

void AppSettings::load()
{
    if (settings_)
    {
        ignore_extension_  = settings_->value("ignoreExtension", false).toBool();
        default_sort_mode_ = settings_->value("defaultSortMode", 0).toInt();
    }
}
