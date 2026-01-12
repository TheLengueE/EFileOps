#pragma once

#include "../RuleBase.h"

/**
 * @brief Add suffix rule
 *
 * Adds specified text after the filename (before extension)
 */
class AddSuffixRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(QString suffix READ suffix WRITE setSuffix NOTIFY suffixChanged)

  public:
    explicit AddSuffixRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "AddSuffix"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    QString suffix() const { return suffix_; }
    void    setSuffix(const QString &suffix);

  signals:
    void suffixChanged();

  private:
    QString suffix_;
};
