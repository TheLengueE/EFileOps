#include "RuleBase.h"
#include <QJsonObject>
#include <QVariantMap>

RuleBase::RuleBase(QObject *parent) : QObject(parent), enabled_(true) {}

void RuleBase::setRuleName(const QString &name)
{
    if (rule_name_ != name)
    {
        rule_name_ = name;
        emit ruleNameChanged();
    }
}

void RuleBase::setEnabled(bool enabled)
{
    if (enabled_ != enabled)
    {
        enabled_ = enabled;
        emit enabledChanged();
    }
}

QJsonObject RuleBase::toJson() const
{
    QJsonObject json;
    json["type"]    = ruleType();
    json["name"]    = rule_name_;
    json["enabled"] = enabled_;
    return json;
}

void RuleBase::fromJson(const QJsonObject &json)
{
    if (json.contains("name"))
    {
        setRuleName(json["name"].toString());
    }
    if (json.contains("enabled"))
    {
        setEnabled(json["enabled"].toBool());
    }
}

void RuleBase::applyConfig(const QVariantMap &config)
{
    // Base class handles common fields (e.g., name)
    if (config.contains("name"))
    {
        setRuleName(config["name"].toString());
    }
    if (config.contains("enabled"))
    {
        setEnabled(config["enabled"].toBool());
    }
}
