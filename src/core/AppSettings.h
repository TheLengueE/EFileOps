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
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(
        bool autoRestoreSession READ autoRestoreSession WRITE setAutoRestoreSession NOTIFY autoRestoreSessionChanged)

  public:
    static AppSettings *instance();

    // Extension handling settings
    bool ignoreExtension() const { return ignore_extension_; }
    void setIgnoreExtension(bool ignore);

    // Default sort mode (0: by name, 1: by time)
    int  defaultSortMode() const { return default_sort_mode_; }
    void setDefaultSortMode(int mode);

    // Language setting
    QString language() const { return language_; }
    void    setLanguage(const QString &lang);

    // Auto restore session
    bool autoRestoreSession() const { return auto_restore_session_; }
    void setAutoRestoreSession(bool enable);

    // Session file path
    QString getSessionFilePath() const;

    // Save and load settings
    void save();
    void load();

  signals:
    void ignoreExtensionChanged();
    void defaultSortModeChanged();
    void languageChanged();
    void autoRestoreSessionChanged();

  private:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    // Disable copy
    AppSettings(const AppSettings &)            = delete;
    AppSettings &operator=(const AppSettings &) = delete;

  private:
    QSettings *settings_;
    bool       ignore_extension_;     // Whether to ignore extension
    int        default_sort_mode_;    // Default sort mode: 0=name, 1=time
    QString    language_;             // Language: en_US, zh_CN
    bool       auto_restore_session_; // Auto restore session on startup

    static AppSettings *instance_;
};
