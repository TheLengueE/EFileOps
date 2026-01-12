#include "RemoveRule.h"
#include "../../model/FileItem.h"
#include "../../core/AppSettings.h"
#include <QJsonObject>

RemoveRule::RemoveRule(QObject *parent) : RuleBase(parent), keyword_(""), case_sensitive_(false)
{
    setRuleName(tr("Remove Files"));
}

QString RemoveRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileIndex)
    // If file should be removed, return empty string as marker
    // Actual removal logic is handled in RuleEngine
    if (shouldRemoveFile(fileItem))
    {
        return "__REMOVE_FILE__"; // Special marker
    }
    return input;
}

bool RemoveRule::shouldRemoveFile(const FileItem *fileItem) const
{
    if (keyword_.isEmpty() || !fileItem)
    {
        return false;
    }

    // Decide what to check based on extension settings
    bool    ignore_extension = AppSettings::instance()->ignoreExtension();
    QString text_to_check;

    if (ignore_extension)
    {
        // Check only filename (without extension)
        text_to_check = fileItem->fileName();
    }
    else
    {
        // Check full filename (with extension)
        text_to_check = fileItem->fileName() + fileItem->extension();
    }

    // Perform keyword matching
    if (case_sensitive_)
    {
        return text_to_check.contains(keyword_, Qt::CaseSensitive);
    }
    else
    {
        return text_to_check.contains(keyword_, Qt::CaseInsensitive);
    }
}

QString RemoveRule::description() const
{
    if (keyword_.isEmpty())
    {
        return tr("Remove Files (Keyword Not Set)");
    }

    QString desc = tr("Remove files containing \"%1\"").arg(keyword_);
    if (case_sensitive_)
    {
        desc += tr(" (Case Sensitive)");
    }
    return desc;
}

bool RemoveRule::validate(QString *errorMessage) const
{
    if (keyword_.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = tr("Keyword cannot be empty");
        }
        return false;
    }

    return true;
}

QJsonObject RemoveRule::toJson() const
{
    QJsonObject json      = RuleBase::toJson();
    json["keyword"]       = keyword_;
    json["caseSensitive"] = case_sensitive_;
    return json;
}

void RemoveRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("keyword"))
    {
        setKeyword(json["keyword"].toString());
    }
    if (json.contains("caseSensitive"))
    {
        setCaseSensitive(json["caseSensitive"].toBool());
    }
}

void RemoveRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("keyword"))
    {
        setKeyword(config["keyword"].toString());
    }
    if (config.contains("caseSensitive"))
    {
        setCaseSensitive(config["caseSensitive"].toBool());
    }
}

RuleBase *RemoveRule::clone() const
{
    RemoveRule *cloned = new RemoveRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setKeyword(keyword_);
    cloned->setCaseSensitive(case_sensitive_);
    return cloned;
}

void RemoveRule::setKeyword(const QString &keyword)
{
    if (keyword_ != keyword)
    {
        keyword_ = keyword;
        emit keywordChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void RemoveRule::setCaseSensitive(bool sensitive)
{
    if (case_sensitive_ != sensitive)
    {
        case_sensitive_ = sensitive;
        emit caseSensitiveChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
