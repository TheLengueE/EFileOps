#pragma once

#include "../RuleBase.h"

/**
 * @brief Remove character rule
 *
 * Delete characters from filename with multiple strategies:
 * - remove first N characters
 * - remove last N characters
 * - remove characters from A to B (1-based, inclusive)
 * - remove all digits
 */
class RemoveRule : public RuleBase
{
    Q_OBJECT
    Q_PROPERTY(int removeFirstCount READ removeFirstCount WRITE setRemoveFirstCount NOTIFY removeFirstCountChanged)
    Q_PROPERTY(int removeLastCount READ removeLastCount WRITE setRemoveLastCount NOTIFY removeLastCountChanged)
    Q_PROPERTY(int rangeStart READ rangeStart WRITE setRangeStart NOTIFY rangeStartChanged)
    Q_PROPERTY(int rangeEnd READ rangeEnd WRITE setRangeEnd NOTIFY rangeEndChanged)
    Q_PROPERTY(bool removeDigits READ removeDigits WRITE setRemoveDigits NOTIFY removeDigitsChanged)

  public:
    explicit RemoveRule(QObject *parent = nullptr);

    QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const override;
    QString ruleType() const override { return "Remove"; }
    QString description() const override;
    bool    validate(QString *errorMessage = nullptr) const override;

    QJsonObject toJson() const override;
    void        fromJson(const QJsonObject &json) override;
    void        applyConfig(const QVariantMap &config) override;
    RuleBase   *clone() const override;

    int  removeFirstCount() const { return remove_first_count_; }
    void setRemoveFirstCount(int count);

    int  removeLastCount() const { return remove_last_count_; }
    void setRemoveLastCount(int count);

    int  rangeStart() const { return range_start_; }
    void setRangeStart(int start);

    int  rangeEnd() const { return range_end_; }
    void setRangeEnd(int end);

    bool removeDigits() const { return remove_digits_; }
    void setRemoveDigits(bool remove);

  signals:
    void removeFirstCountChanged();
    void removeLastCountChanged();
    void rangeStartChanged();
    void rangeEndChanged();
    void removeDigitsChanged();

  private:
    int  remove_first_count_;
    int  remove_last_count_;
    int  range_start_;
    int  range_end_;
    bool remove_digits_;
};
