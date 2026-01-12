#include "AddPrefixRule.h"
#include "../../model/FileItem.h"
#include <QJsonObject>

AddPrefixRule::AddPrefixRule(QObject *parent) : RuleBase(parent)
{
    setRuleName(tr("Add Prefix"));
}

QString AddPrefixRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)
    Q_UNUSED(fileIndex)
    return prefix_ + input;
}

QString AddPrefixRule::description() const
{
    if (prefix_.isEmpty())
    {
        return tr("Add Prefix (Not Set)");
    }
    return tr("Add Prefix: \"%1\"").arg(prefix_);
}

bool AddPrefixRule::validate(QString *errorMessage) const
{
    if (prefix_.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = tr("Prefix cannot be empty");
        }
        return false;
    }
    return true;
}

QJsonObject AddPrefixRule::toJson() const
{
    QJsonObject json = RuleBase::toJson();
    json["prefix"]   = prefix_;
    return json;
}

void AddPrefixRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("prefix"))
    {
        setPrefix(json["prefix"].toString());
    }
}

void AddPrefixRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("text"))
    {
        setPrefix(config["text"].toString());
    }
    else if (config.contains("prefix"))
    {
        setPrefix(config["prefix"].toString());
    }
}

RuleBase *AddPrefixRule::clone() const
{
    AddPrefixRule *cloned = new AddPrefixRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setPrefix(prefix_);
    return cloned;
}

void AddPrefixRule::setPrefix(const QString &prefix)
{
    if (prefix_ != prefix)
    {
        prefix_ = prefix;
        emit prefixChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
