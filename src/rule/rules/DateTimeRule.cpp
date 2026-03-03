#include "DateTimeRule.h"
#include "../../model/FileItem.h"
#include <QDateTime>
#include <QJsonObject>

DateTimeRule::DateTimeRule(QObject *parent) : RuleBase(parent)
{
    setRuleName(tr("Add Date/Time"));
}

// ---------------------------------------------------------------------------
// Static helpers
// ---------------------------------------------------------------------------

QString DateTimeRule::presetFormat(int preset)
{
    switch (preset)
    {
    case ISO:      return "YYYY-MM-DD";
    case Compact:  return "YYYYMMDD";
    case US:       return "MM-DD-YYYY";
    case EU:       return "DD.MM.YYYY";
    case DateTime: return "YYYY-MM-DD_HH-mm";
    default:       return "YYYY-MM-DD";
    }
}

QString DateTimeRule::formatDateTime(const QString &fmt, const QDateTime &dt)
{
    QString result = fmt;
    result.replace("{YYYY}", dt.toString("yyyy"));
    result.replace("{MM}",   dt.toString("MM"));
    result.replace("{DD}",   dt.toString("dd"));
    result.replace("{HH}",   dt.toString("HH"));
    result.replace("{mm}",   dt.toString("mm"));
    result.replace("{SS}",   dt.toString("ss"));

    // Also support the simplified notation used by presets (without braces)
    result.replace("YYYY", dt.toString("yyyy"));
    result.replace("MM",   dt.toString("MM"));
    result.replace("DD",   dt.toString("dd"));
    result.replace("HH",   dt.toString("HH"));
    // "mm" must come after "MM" replacement to avoid collision
    result.replace("mm",   dt.toString("mm"));
    result.replace("SS",   dt.toString("ss"));

    return result;
}

// ---------------------------------------------------------------------------
// Core interface
// ---------------------------------------------------------------------------

QString DateTimeRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileIndex)

    QDateTime dt;
    if (fileItem)
    {
        dt = use_modified_time_ ? fileItem->modified() : fileItem->created();
    }

    // Fallback to current time when metadata is unavailable
    if (!dt.isValid())
    {
        dt = QDateTime::currentDateTime();
    }

    QString stamp = formatDateTime(format_, dt);

    if (is_prefix_)
    {
        return stamp + separator_ + input;
    }
    else
    {
        // Insert before the extension so the result remains valid
        // input is full filename including extension (e.g. "photo.jpg")
        int dot = input.lastIndexOf('.');
        if (dot > 0)
        {
            return input.left(dot) + separator_ + stamp + input.mid(dot);
        }
        return input + separator_ + stamp;
    }
}

QString DateTimeRule::description() const
{
    QString pos   = is_prefix_ ? tr("Prefix") : tr("Suffix");
    QString src   = use_modified_time_ ? tr("Modified") : tr("Created");
    return tr("Add %1 Date/Time (%2): \"%3\"").arg(pos, src, format_);
}

bool DateTimeRule::validate(QString *errorMessage) const
{
    if (format_.trimmed().isEmpty())
    {
        if (errorMessage)
            *errorMessage = tr("Format cannot be empty");
        return false;
    }
    return true;
}

// ---------------------------------------------------------------------------
// Serialization
// ---------------------------------------------------------------------------

QJsonObject DateTimeRule::toJson() const
{
    QJsonObject json  = RuleBase::toJson();
    json["isPrefix"]        = is_prefix_;
    json["format"]          = format_;
    json["useModifiedTime"] = use_modified_time_;
    json["separator"]       = separator_;
    return json;
}

void DateTimeRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("isPrefix"))        setIsPrefix(json["isPrefix"].toBool());
    if (json.contains("format"))          setFormat(json["format"].toString());
    if (json.contains("useModifiedTime")) setUseModifiedTime(json["useModifiedTime"].toBool());
    if (json.contains("separator"))       setSeparator(json["separator"].toString());
}

void DateTimeRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config);
    if (config.contains("isPrefix"))        setIsPrefix(config["isPrefix"].toBool());
    if (config.contains("format"))          setFormat(config["format"].toString());
    if (config.contains("useModifiedTime")) setUseModifiedTime(config["useModifiedTime"].toBool());
    if (config.contains("separator"))       setSeparator(config["separator"].toString());
}

// ---------------------------------------------------------------------------
// Clone
// ---------------------------------------------------------------------------

RuleBase *DateTimeRule::clone() const
{
    DateTimeRule *c = new DateTimeRule();
    c->setRuleName(ruleName());
    c->setEnabled(enabled());
    c->setIsPrefix(is_prefix_);
    c->setFormat(format_);
    c->setUseModifiedTime(use_modified_time_);
    c->setSeparator(separator_);
    return c;
}

// ---------------------------------------------------------------------------
// Setters
// ---------------------------------------------------------------------------

void DateTimeRule::setIsPrefix(bool v)
{
    if (is_prefix_ != v)
    {
        is_prefix_ = v;
        emit isPrefixChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void DateTimeRule::setFormat(const QString &fmt)
{
    if (format_ != fmt)
    {
        format_ = fmt;
        emit formatChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void DateTimeRule::setUseModifiedTime(bool v)
{
    if (use_modified_time_ != v)
    {
        use_modified_time_ = v;
        emit useModifiedTimeChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void DateTimeRule::setSeparator(const QString &sep)
{
    if (separator_ != sep)
    {
        separator_ = sep;
        emit separatorChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
