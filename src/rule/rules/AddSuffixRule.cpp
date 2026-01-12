#include "AddSuffixRule.h"
#include "../../model/FileItem.h"
#include <QJsonObject>

AddSuffixRule::AddSuffixRule(QObject *parent) : RuleBase(parent)
{
    setRuleName(tr("Add Suffix"));
}

QString AddSuffixRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)
    Q_UNUSED(fileIndex)
    return input + suffix_;
}

QString AddSuffixRule::description() const
{
    if (suffix_.isEmpty())
    {
        return tr("Add Suffix (Not Set)");
    }
    return tr("Add Suffix: \"%1\"").arg(suffix_);
}

bool AddSuffixRule::validate(QString *errorMessage) const
{
    if (suffix_.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = tr("Suffix cannot be empty");
        }
        return false;
    }
    return true;
}

QJsonObject AddSuffixRule::toJson() const
{
    QJsonObject json = RuleBase::toJson();
    json["suffix"]   = suffix_;
    return json;
}

void AddSuffixRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("suffix"))
    {
        setSuffix(json["suffix"].toString());
    }
}

void AddSuffixRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("text"))
    {
        setSuffix(config["text"].toString());
    }
    else if (config.contains("suffix"))
    {
        setSuffix(config["suffix"].toString());
    }
}

RuleBase *AddSuffixRule::clone() const
{
    AddSuffixRule *cloned = new AddSuffixRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setSuffix(suffix_);
    return cloned;
}

void AddSuffixRule::setSuffix(const QString &suffix)
{
    if (suffix_ != suffix)
    {
        suffix_ = suffix;
        emit suffixChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
