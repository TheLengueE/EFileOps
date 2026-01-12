#pragma once

#include "../RuleBase.h"

/**
 * @brief Find and replace rule
 *
 * Find and replace text in filenames
 * Supports case sensitivity and regular expressions
 */
class ReplaceRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(QString findText READ findText WRITE setFindText NOTIFY findTextChanged)
    Q_PROPERTY(QString replaceText READ replaceText WRITE setReplaceText NOTIFY replaceTextChanged)
    Q_PROPERTY(bool caseSensitive READ caseSensitive WRITE setCaseSensitive NOTIFY caseSensitiveChanged)
    Q_PROPERTY(bool useRegex READ useRegex WRITE setUseRegex NOTIFY useRegexChanged)

  public:
    explicit ReplaceRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "Replace"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    QString findText() const { return find_text_; }
    void    setFindText(const QString &text);

    QString replaceText() const { return replace_text_; }
    void    setReplaceText(const QString &text);

    bool caseSensitive() const { return case_sensitive_; }
    void setCaseSensitive(bool sensitive);

    bool useRegex() const { return use_regex_; }
    void setUseRegex(bool useRegex);

  signals:
    void findTextChanged();
    void replaceTextChanged();
    void caseSensitiveChanged();
    void useRegexChanged();

  private:
    QString find_text_;
    QString replace_text_;
    bool    case_sensitive_;
    bool    use_regex_;
};
