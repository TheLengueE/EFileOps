#include "NumberingRule.h"
#include "../../model/FileItem.h"
#include <QJsonObject>

NumberingRule::NumberingRule(QObject *parent)
    : RuleBase(parent), position_(Position::Prefix), start_number_(1),
      padding_length_(3) // Default zero padding of 3 digits
      ,
      separator_("_")
{
    setRuleName(tr("Numbering"));
}

QString NumberingRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)

    // Return original input if index is invalid
    if (fileIndex < 0)
    {
        return input;
    }

    // Calculate current file number
    int number = fileIndex + start_number_;

    // Format number string
    QString number_str;
    if (padding_length_ > 0)
    {
        // With zero padding: e.g., 001, 002, 003
        number_str = QString("%1").arg(number, padding_length_, 10, QChar('0'));
    }
    else
    {
        // Without zero padding: e.g., 1, 2, 3
        number_str = QString::number(number);
    }

    // Add number based on position
    if (position_ == Position::Prefix)
    {
        // Prefix: 001_name.txt
        return number_str + separator_ + input;
    }
    else
    {
        // Suffix: name_001.txt
        return input + separator_ + number_str;
    }
}

QString NumberingRule::description() const
{
    QString pos_text     = (position_ == Position::Prefix) ? tr("Prefix") : tr("Suffix");
    QString padding_text = (padding_length_ > 0) ? tr(", %1 digits").arg(padding_length_) : tr(", no padding");

    return tr("Numbering (%1, Start %2%3, Separator '%4')").arg(pos_text).arg(start_number_).arg(padding_text).arg(separator_);
}

bool NumberingRule::validate(QString *errorMessage) const
{
    if (start_number_ < 0)
    {
        if (errorMessage)
        {
            *errorMessage = tr("Start number cannot be negative");
        }
        return false;
    }

    if (padding_length_ < 0 || padding_length_ > 10)
    {
        if (errorMessage)
        {
            *errorMessage = tr("Padding length must be between 0-10");
        }
        return false;
    }

    if (separator_.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = tr("Separator cannot be empty");
        }
        return false;
    }

    return true;
}

QJsonObject NumberingRule::toJson() const
{
    QJsonObject json      = RuleBase::toJson();
    json["position"]      = static_cast<int>(position_);
    json["startNumber"]   = start_number_;
    json["paddingLength"] = padding_length_;
    json["separator"]     = separator_;
    return json;
}

void NumberingRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    position_       = static_cast<Position>(json["position"].toInt());
    start_number_   = json["startNumber"].toInt(1);
    padding_length_ = json["paddingLength"].toInt(3);
    separator_      = json["separator"].toString("_");
}

void NumberingRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("position"))
    {
        setPosition(static_cast<Position>(config["position"].toInt()));
    }
    if (config.contains("startNumber"))
    {
        setStartNumber(config["startNumber"].toInt());
    }
    if (config.contains("paddingLength"))
    {
        setPaddingLength(config["paddingLength"].toInt());
    }
    if (config.contains("separator"))
    {
        setSeparator(config["separator"].toString());
    }
}

RuleBase *NumberingRule::clone() const
{
    NumberingRule *rule = new NumberingRule();
    rule->setEnabled(enabled());
    rule->setPosition(position_);
    rule->setStartNumber(start_number_);
    rule->setPaddingLength(padding_length_);
    rule->setSeparator(separator_);
    return rule;
}

void NumberingRule::setPosition(Position pos)
{
    if (position_ != pos)
    {
        position_ = pos;
        emit positionChanged();
        emit configChanged();
    }
}

void NumberingRule::setStartNumber(int num)
{
    if (start_number_ != num && num >= 0)
    {
        start_number_ = num;
        emit startNumberChanged();
        emit configChanged();
    }
}

void NumberingRule::setPaddingLength(int length)
{
    if (padding_length_ != length && length >= 0 && length <= 10)
    {
        padding_length_ = length;
        emit paddingLengthChanged();
        emit configChanged();
    }
}

void NumberingRule::setSeparator(const QString &sep)
{
    if (separator_ != sep && !sep.isEmpty())
    {
        separator_ = sep;
        emit separatorChanged();
        emit configChanged();
    }
}
