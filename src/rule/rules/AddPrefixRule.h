#pragma once

#include "../RuleBase.h"

/**
 * @brief Add prefix rule
 *
 * Adds specified text before the filename
 */
class AddPrefixRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(QString prefix READ prefix WRITE setPrefix NOTIFY prefixChanged)

  public:
    explicit AddPrefixRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "AddPrefix"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    QString prefix() const { return prefix_; }
    void    setPrefix(const QString &prefix);

  signals:
    void prefixChanged();

  private:
    QString prefix_;
};
