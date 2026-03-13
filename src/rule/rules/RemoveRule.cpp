#include "RemoveRule.h"
#include <QJsonObject>
#include <QRegularExpression>
#include <QStringList>

RemoveRule::RemoveRule(QObject *parent)
    : RuleBase(parent), remove_first_count_(0), remove_last_count_(0), range_start_(0), range_end_(0), remove_digits_(false)
{
    setRuleName(tr("Delete Characters"));
}

QString RemoveRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)
    Q_UNUSED(fileIndex)

    QString result = input;

    if (remove_first_count_ > 0 && !result.isEmpty())
    {
        int count = qMin(remove_first_count_, result.size());
        result    = result.mid(count);
    }

    if (remove_last_count_ > 0 && !result.isEmpty())
    {
        int count = qMin(remove_last_count_, result.size());
        result.chop(count);
    }

    if (range_start_ > 0 && range_end_ >= range_start_ && !result.isEmpty())
    {
        int safe_start = qMax(1, qMin(range_start_, result.size()));
        int safe_end   = qMax(1, qMin(range_end_, result.size()));
        if (safe_start <= safe_end)
        {
            result.remove(safe_start - 1, safe_end - safe_start + 1);
        }
    }

    if (remove_digits_ && !result.isEmpty())
    {
        result.remove(QRegularExpression("\\d"));
    }

    return result;
}

QString RemoveRule::description() const
{
    QStringList parts;
    if (remove_first_count_ > 0)
    {
        parts.append(tr("first %1 char(s)").arg(remove_first_count_));
    }
    if (remove_last_count_ > 0)
    {
        parts.append(tr("last %1 char(s)").arg(remove_last_count_));
    }
    if (range_start_ > 0 && range_end_ >= range_start_)
    {
        parts.append(tr("position %1-%2").arg(range_start_).arg(range_end_));
    }
    if (remove_digits_)
    {
        parts.append(tr("all digits"));
    }

    if (parts.isEmpty())
    {
        return tr("Delete Characters (No operation set)");
    }

    return tr("Delete characters: %1").arg(parts.join(", "));
}

bool RemoveRule::validate(QString *errorMessage) const
{
    bool has_any_operation = remove_first_count_ > 0 || remove_last_count_ > 0 || remove_digits_ ||
                             (range_start_ > 0 && range_end_ > 0);

    if (!has_any_operation)
    {
        if (errorMessage)
        {
            *errorMessage = tr("At least one delete operation must be configured");
        }
        return false;
    }

    if (remove_first_count_ < 0 || remove_last_count_ < 0 || range_start_ < 0 || range_end_ < 0)
    {
        if (errorMessage)
        {
            *errorMessage = tr("Delete counts and range positions must be >= 0");
        }
        return false;
    }

    if ((range_start_ > 0 || range_end_ > 0) && !(range_start_ > 0 && range_end_ > 0 && range_start_ <= range_end_))
    {
        if (errorMessage)
        {
            *errorMessage = tr("Range must be valid: start and end must be > 0 and start <= end");
        }
        return false;
    }

    return true;
}

QJsonObject RemoveRule::toJson() const
{
    QJsonObject json          = RuleBase::toJson();
    json["removeFirstCount"]  = remove_first_count_;
    json["removeLastCount"]   = remove_last_count_;
    json["rangeStart"]        = range_start_;
    json["rangeEnd"]          = range_end_;
    json["removeDigits"]      = remove_digits_;
    return json;
}

void RemoveRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("removeFirstCount"))
    {
        setRemoveFirstCount(json["removeFirstCount"].toInt());
    }
    if (json.contains("removeLastCount"))
    {
        setRemoveLastCount(json["removeLastCount"].toInt());
    }
    if (json.contains("rangeStart"))
    {
        setRangeStart(json["rangeStart"].toInt());
    }
    if (json.contains("rangeEnd"))
    {
        setRangeEnd(json["rangeEnd"].toInt());
    }
    if (json.contains("removeDigits"))
    {
        setRemoveDigits(json["removeDigits"].toBool());
    }
}

void RemoveRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("removeFirstCount"))
    {
        setRemoveFirstCount(config["removeFirstCount"].toInt());
    }
    if (config.contains("removeLastCount"))
    {
        setRemoveLastCount(config["removeLastCount"].toInt());
    }
    if (config.contains("rangeStart"))
    {
        setRangeStart(config["rangeStart"].toInt());
    }
    if (config.contains("rangeEnd"))
    {
        setRangeEnd(config["rangeEnd"].toInt());
    }
    if (config.contains("removeDigits"))
    {
        setRemoveDigits(config["removeDigits"].toBool());
    }
}

RuleBase *RemoveRule::clone() const
{
    RemoveRule *cloned = new RemoveRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setRemoveFirstCount(remove_first_count_);
    cloned->setRemoveLastCount(remove_last_count_);
    cloned->setRangeStart(range_start_);
    cloned->setRangeEnd(range_end_);
    cloned->setRemoveDigits(remove_digits_);
    return cloned;
}

void RemoveRule::setRemoveFirstCount(int count)
{
    int safe_count = qMax(0, count);
    if (remove_first_count_ != safe_count)
    {
        remove_first_count_ = safe_count;
        emit removeFirstCountChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void RemoveRule::setRemoveLastCount(int count)
{
    int safe_count = qMax(0, count);
    if (remove_last_count_ != safe_count)
    {
        remove_last_count_ = safe_count;
        emit removeLastCountChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void RemoveRule::setRangeStart(int start)
{
    int safe_start = qMax(0, start);
    if (range_start_ != safe_start)
    {
        range_start_ = safe_start;
        emit rangeStartChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void RemoveRule::setRangeEnd(int end)
{
    int safe_end = qMax(0, end);
    if (range_end_ != safe_end)
    {
        range_end_ = safe_end;
        emit rangeEndChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void RemoveRule::setRemoveDigits(bool remove)
{
    if (remove_digits_ != remove)
    {
        remove_digits_ = remove;
        emit removeDigitsChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
