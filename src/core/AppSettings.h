#pragma once

#include <QObject>
#include <QSettings>

/**
 * @brief Application settings manager class (singleton)
 *
 * Manages global application settings, with persistent storage using QSettings
 */
class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ignoreExtension READ ignoreExtension WRITE setIgnoreExtension NOTIFY ignoreExtensionChanged)
    Q_PROPERTY(int defaultSortMode READ defaultSortMode WRITE setDefaultSortMode NOTIFY defaultSortModeChanged)

  public:
    static AppSettings *instance();

    // Extension handling settings
    bool ignoreExtension() const { return ignore_extension_; }
    void setIgnoreExtension(bool ignore);

    // Default sort mode (0: by name, 1: by time)
    int  defaultSortMode() const { return default_sort_mode_; }
    void setDefaultSortMode(int mode);

    // Save and load settings
    void save();
    void load();

  signals:
    void ignoreExtensionChanged();
    void defaultSortModeChanged();

  private:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    // Disable copy
    AppSettings(const AppSettings &)            = delete;
    AppSettings &operator=(const AppSettings &) = delete;

  private:
    QSettings *settings_;
    bool       ignore_extension_;  // Whether to ignore extension
    int        default_sort_mode_; // Default sort mode: 0=name, 1=time

    static AppSettings *instance_;
};
