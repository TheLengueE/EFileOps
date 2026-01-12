#pragma once

#include "../RuleBase.h"

/**
 * @brief Remove file rule
 *
 * Remove files from file list based on keyword matching
 * Note: This does not remove characters from filename, but removes matching files from list
 */
class RemoveRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(QString keyword READ keyword WRITE setKeyword NOTIFY keywordChanged)
    Q_PROPERTY(bool caseSensitive READ caseSensitive WRITE setCaseSensitive NOTIFY caseSensitiveChanged)

  public:
    explicit RemoveRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "Remove"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    // Check if file should be removed (from list)
    bool shouldRemoveFile(const FileItem *fileItem) const;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    QString keyword() const { return keyword_; }
    void    setKeyword(const QString &keyword);

    bool caseSensitive() const { return case_sensitive_; }
    void setCaseSensitive(bool sensitive);

  signals:
    void keywordChanged();
    void caseSensitiveChanged();

  private:
    QString keyword_;        // Match keyword
    bool    case_sensitive_; // Whether case sensitive
};
