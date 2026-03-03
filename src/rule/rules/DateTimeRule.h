#pragma once

#include "../RuleBase.h"

/**
 * @brief DateTime stamp rule
 *
 * Adds a formatted date/time stamp (from file metadata) as prefix or suffix.
 *
 * Supported format tokens:
 *   {YYYY} - 4-digit year        {MM}   - 2-digit month
 *   {DD}   - 2-digit day         {HH}   - hour (24h)
 *   {mm}   - minute              {SS}   - second
 *
 * Preset formats (locale-aware):
 *   ISO      : YYYY-MM-DD          (universal)
 *   Compact  : YYYYMMDD            (universal)
 *   US       : MM-DD-YYYY          (en_US style)
 *   EU       : DD.MM.YYYY          (de_DE style)
 *   DateTime : YYYY-MM-DD_HH-mm   (universal)
 */
class DateTimeRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(bool isPrefix READ isPrefix WRITE setIsPrefix NOTIFY isPrefixChanged)
    Q_PROPERTY(QString format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(bool useModifiedTime READ useModifiedTime WRITE setUseModifiedTime NOTIFY useModifiedTimeChanged)
    Q_PROPERTY(QString separator READ separator WRITE setSeparator NOTIFY separatorChanged)

  public:
    // Preset format identifiers
    enum FormatPreset
    {
        ISO      = 0, // YYYY-MM-DD
        Compact  = 1, // YYYYMMDD
        US       = 2, // MM-DD-YYYY
        EU       = 3, // DD.MM.YYYY
        DateTime = 4, // YYYY-MM-DD_HH-mm
        Custom   = 5  // user-defined format string
    };
    Q_ENUM(FormatPreset)

    explicit DateTimeRule(QObject *parent = nullptr);

    // RuleBase interface
    QString   apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString   ruleType() const override { return "DateTime"; }
    QString   description() const override;
    bool      validate(QString *errorMessage = nullptr) const override;
    RuleBase *clone() const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;

    // Property accessors
    bool    isPrefix() const { return is_prefix_; }
    QString format() const { return format_; }
    bool    useModifiedTime() const { return use_modified_time_; }
    QString separator() const { return separator_; }

    void setIsPrefix(bool v);
    void setFormat(const QString &fmt);
    void setUseModifiedTime(bool v);
    void setSeparator(const QString &sep);

    // Apply format template to a QDateTime
    static QString formatDateTime(const QString &fmt, const QDateTime &dt);

    // Built-in preset format strings
    static QString presetFormat(int preset);

  signals:
    void isPrefixChanged();
    void formatChanged();
    void useModifiedTimeChanged();
    void separatorChanged();

  private:
    bool    is_prefix_         = true;            // true=prefix, false=suffix
    QString format_            = "YYYY-MM-DD";    // active format template
    bool    use_modified_time_ = true;            // true=modified time, false=created time
    QString separator_         = "_";             // separator between stamp and filename
};
