#pragma once

#include "../RuleBase.h"

/**
 * @brief Case transform rule
 *
 * Transform file name case format
 */
class CaseTransformRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(CaseType caseType READ caseType WRITE setCaseType NOTIFY caseTypeChanged)

  public:
    enum CaseType
    {
        UpperCase,     // All uppercase: FILENAME
        LowerCase,     // All lowercase: filename
        TitleCase,     // First letter uppercase: Filename
        WordTitleCase, // Word first letter uppercase: Hello_World or Hello World
        CamelCase,     // Camel case: fileName
        SnakeCase,     // Snake case: file_name
        KebabCase      // Kebab case: file-name
    };
    Q_ENUM(CaseType)

    explicit CaseTransformRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "CaseTransform"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    CaseType caseType() const { return case_type_; }
    void     setCaseType(CaseType type);

  signals:
    void caseTypeChanged();

  private:
    QString toTitleCase(const QString &input) const;
    QString toWordTitleCase(const QString &input) const;
    QString toCamelCase(const QString &input) const;
    QString toSnakeCase(const QString &input) const;
    QString toKebabCase(const QString &input) const;

  private:
    CaseType case_type_;
};
