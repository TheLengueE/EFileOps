#include "ReplaceRule.h"
#include "../../model/FileItem.h"
#include <QJsonObject>
#include <QRegularExpression>

ReplaceRule::ReplaceRule(QObject *parent) : RuleBase(parent), case_sensitive_(false), use_regex_(false)
{
    setRuleName(tr("Find and Replace"));
}

QString ReplaceRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)
    Q_UNUSED(fileIndex)

    if (find_text_.isEmpty())
    {
        return input;
    }

    QString result = input;

    if (use_regex_)
    {
        QRegularExpression::PatternOptions options = QRegularExpression::NoPatternOption;
        if (!case_sensitive_)
        {
            options |= QRegularExpression::CaseInsensitiveOption;
        }
        QRegularExpression regex(find_text_, options);
        result.replace(regex, replace_text_);
    }
    else
    {
        Qt::CaseSensitivity cs = case_sensitive_ ? Qt::CaseSensitive : Qt::CaseInsensitive;
        result.replace(find_text_, replace_text_, cs);
    }

    return result;
}

QString ReplaceRule::description() const
{
    if (find_text_.isEmpty())
    {
        return tr("Find and Replace (Not Set)");
    }
    QString desc = tr("Replace \"%1\" with \"%2\"").arg(find_text_, replace_text_);
    if (use_regex_)
    {
        desc += tr(" (Regex)");
    }
    return desc;
}

bool ReplaceRule::validate(QString *errorMessage) const
{
    if (find_text_.isEmpty())
    {
        if (errorMessage)
        {
            *errorMessage = tr("Find text cannot be empty");
        }
        return false;
    }

    if (use_regex_)
    {
        QRegularExpression regex(find_text_);
        if (!regex.isValid())
        {
            if (errorMessage)
            {
                *errorMessage = tr("Invalid regex: %1").arg(regex.errorString());
            }
            return false;
        }
    }

    return true;
}

QJsonObject ReplaceRule::toJson() const
{
    QJsonObject json      = RuleBase::toJson();
    json["findText"]      = find_text_;
    json["replaceText"]   = replace_text_;
    json["caseSensitive"] = case_sensitive_;
    json["useRegex"]      = use_regex_;
    return json;
}

void ReplaceRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("findText"))
    {
        setFindText(json["findText"].toString());
    }
    if (json.contains("replaceText"))
    {
        setReplaceText(json["replaceText"].toString());
    }
    if (json.contains("caseSensitive"))
    {
        setCaseSensitive(json["caseSensitive"].toBool());
    }
    if (json.contains("useRegex"))
    {
        setUseRegex(json["useRegex"].toBool());
    }
}

void ReplaceRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("findText"))
    {
        setFindText(config["findText"].toString());
    }
    if (config.contains("replaceText"))
    {
        setReplaceText(config["replaceText"].toString());
    }
    if (config.contains("caseSensitive"))
    {
        setCaseSensitive(config["caseSensitive"].toBool());
    }
    if (config.contains("useRegex"))
    {
        setUseRegex(config["useRegex"].toBool());
    }
}

RuleBase *ReplaceRule::clone() const
{
    ReplaceRule *cloned = new ReplaceRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setFindText(find_text_);
    cloned->setReplaceText(replace_text_);
    cloned->setCaseSensitive(case_sensitive_);
    cloned->setUseRegex(use_regex_);
    return cloned;
}

void ReplaceRule::setFindText(const QString &text)
{
    if (find_text_ != text)
    {
        find_text_ = text;
        emit findTextChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void ReplaceRule::setReplaceText(const QString &text)
{
    if (replace_text_ != text)
    {
        replace_text_ = text;
        emit replaceTextChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

void ReplaceRule::setCaseSensitive(bool sensitive)
{
    if (case_sensitive_ != sensitive)
    {
        case_sensitive_ = sensitive;
        emit caseSensitiveChanged();
        emit configChanged();
    }
}

void ReplaceRule::setUseRegex(bool useRegex)
{
    if (use_regex_ != useRegex)
    {
        use_regex_ = useRegex;
        emit useRegexChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}
