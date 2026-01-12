#include "CaseTransformRule.h"
#include "../../model/FileItem.h"
#include <QJsonObject>
#include <QRegularExpression>

CaseTransformRule::CaseTransformRule(QObject *parent) : RuleBase(parent), case_type_(LowerCase)
{
    setRuleName(tr("Case Transform"));
}

QString CaseTransformRule::apply(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    Q_UNUSED(fileItem)
    Q_UNUSED(fileIndex)

    // Separate filename and extension
    QString name_without_ext = input;
    QString extension;

    int last_dot_index = input.lastIndexOf('.');
    if (last_dot_index > 0)
    { // Greater than 0 ensures not a hidden file (e.g., .gitignore)
        name_without_ext = input.left(last_dot_index);
        extension        = input.mid(last_dot_index); // Includes the dot
    }

    // Apply format transformation only to the filename part
    QString transformed_name;
    switch (case_type_)
    {
    case UpperCase:
        transformed_name = name_without_ext.toUpper();
        break;
    case LowerCase:
        transformed_name = name_without_ext.toLower();
        break;
    case TitleCase:
        transformed_name = toTitleCase(name_without_ext);
        break;
    case WordTitleCase:
        transformed_name = toWordTitleCase(name_without_ext);
        break;
    case CamelCase:
        transformed_name = toCamelCase(name_without_ext);
        break;
    case SnakeCase:
        transformed_name = toSnakeCase(name_without_ext);
        break;
    case KebabCase:
        transformed_name = toKebabCase(name_without_ext);
        break;
    default:
        transformed_name = name_without_ext;
    }

    // Concatenate filename and extension (keep extension as-is)
    return transformed_name + extension;
}

QString CaseTransformRule::description() const
{
    QString type_str;
    switch (case_type_)
    {
    case UpperCase:
        type_str = tr("UPPERCASE");
        break;
    case LowerCase:
        type_str = tr("lowercase");
        break;
    case TitleCase:
        type_str = tr("Capitalize");
        break;
    case WordTitleCase:
        type_str = tr("Title Case");
        break;
    case CamelCase:
        type_str = tr("camelCase");
        break;
    case SnakeCase:
        type_str = tr("snake_case");
        break;
    case KebabCase:
        type_str = tr("kebab-case");
        break;
    }
    return tr("Transform to %1").arg(type_str);
}

bool CaseTransformRule::validate(QString *errorMessage) const
{
    Q_UNUSED(errorMessage)
    return true;
}

QJsonObject CaseTransformRule::toJson() const
{
    QJsonObject json = RuleBase::toJson();
    json["caseType"] = static_cast<int>(case_type_);
    return json;
}

void CaseTransformRule::fromJson(const QJsonObject &json)
{
    RuleBase::fromJson(json);
    if (json.contains("caseType"))
    {
        setCaseType(static_cast<CaseType>(json["caseType"].toInt()));
    }
}

void CaseTransformRule::applyConfig(const QVariantMap &config)
{
    RuleBase::applyConfig(config); // Call base class first
    if (config.contains("caseType"))
    {
        setCaseType(static_cast<CaseType>(config["caseType"].toInt()));
    }
}

RuleBase *CaseTransformRule::clone() const
{
    CaseTransformRule *cloned = new CaseTransformRule();
    cloned->setRuleName(ruleName());
    cloned->setEnabled(enabled());
    cloned->setCaseType(case_type_);
    return cloned;
}

void CaseTransformRule::setCaseType(CaseType type)
{
    if (case_type_ != type)
    {
        case_type_ = type;
        emit caseTypeChanged();
        emit configChanged();
        emit descriptionChanged();
    }
}

QString CaseTransformRule::toTitleCase(const QString &input) const
{
    if (input.isEmpty())
        return input;

    QString result = input;
    result[0]      = result[0].toUpper();
    for (int i = 1; i < result.length(); ++i)
    {
        result[i] = result[i].toLower();
    }
    return result;
}

QString CaseTransformRule::toWordTitleCase(const QString &input) const
{
    if (input.isEmpty())
        return input;

    QString result;
    bool    capitalize_next = true;

    // Define delimiters: space, underscore, dot, hyphen
    QSet<QChar> delimiters = {' ', '_', '.', '-'};

    for (int i = 0; i < input.length(); ++i)
    {
        QChar c = input[i];

        if (delimiters.contains(c))
        {
            // Keep delimiter as-is, capitalize next letter
            result += c;
            capitalize_next = true;
        }
        else
        {
            // Handle letter based on whether it needs capitalization
            if (capitalize_next && c.isLetter())
            {
                result += c.toUpper();
                capitalize_next = false;
            }
            else
            {
                result += c.toLower();
            }
        }
    }

    return result;
}

QString CaseTransformRule::toCamelCase(const QString &input) const
{
    QString result = input;
    result.replace(QRegularExpression("[\\s_-]+"), " ");

    QStringList words = result.split(' ', Qt::SkipEmptyParts);
    if (words.isEmpty())
        return QString();

    QString output = words[0].toLower();
    for (int i = 1; i < words.size(); ++i)
    {
        if (!words[i].isEmpty())
        {
            output += words[i][0].toUpper() + words[i].mid(1).toLower();
        }
    }
    return output;
}

QString CaseTransformRule::toSnakeCase(const QString &input) const
{
    QString result = input;

    // Camel case to underscore: insert before capital letters
    result.replace(QRegularExpression("([a-z])([A-Z])"), "\\1_\\2");

    // Convert spaces and hyphens to underscores
    result.replace(QRegularExpression("[\\s-]+"), "_");

    // All lowercase
    result = result.toLower();

    // Remove consecutive underscores
    result.replace(QRegularExpression("_+"), "_");

    return result;
}

QString CaseTransformRule::toKebabCase(const QString &input) const
{
    QString result = input;

    // Camel case to hyphen
    result.replace(QRegularExpression("([a-z])([A-Z])"), "\\1-\\2");

    // Convert spaces and underscores to hyphens
    result.replace(QRegularExpression("[\\s_]+"), "-");

    // All lowercase
    result = result.toLower();

    // Remove consecutive hyphens
    result.replace(QRegularExpression("-+"), "-");

    return result;
}
