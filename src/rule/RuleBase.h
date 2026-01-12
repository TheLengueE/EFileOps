#pragma once

#include <QObject>
#include <QString>
#include <QJsonObject>

class FileItem;

/**
 * @brief Rename rule base class
 *
 * Abstract base class for all concrete rule classes, defines unified interface
 * Supports serialization/deserialization for saving configuration
 */
class RuleBase : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ruleType READ ruleType CONSTANT)
    Q_PROPERTY(QString ruleName READ ruleName WRITE setRuleName NOTIFY ruleNameChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)

  public:
    explicit RuleBase(QObject *parent = nullptr);
    virtual ~RuleBase() = default;

    // Core method: Apply rule
    virtual QString apply(const QString &input, const FileItem *fileItem, int fileIndex = -1) const = 0;

    // Rule type identifier (for deserialization)
    virtual QString ruleType() const = 0;

    // Rule display name
    QString ruleName() const { return rule_name_; }
    void    setRuleName(const QString &name);

    // Whether enabled
    bool enabled() const { return enabled_; }
    void setEnabled(bool enabled);

    // Rule description (for UI display)
    virtual QString description() const = 0;

    // Validate rule configuration
    virtual bool validate(QString *errorMessage = nullptr) const = 0;

    // Serialization/Deserialization
    virtual QJsonObject toJson() const;
    virtual void        fromJson(const QJsonObject &json);

    // Apply configuration from QVariantMap (used by MainController)
    virtual void applyConfig(const QVariantMap &config);

    // Clone rule (for undo/redo)
    virtual RuleBase *clone() const = 0;

  signals:
    void ruleNameChanged();
    void enabledChanged();
    void descriptionChanged();
    void configChanged();

  protected:
    QString rule_name_;
    bool    enabled_;
};
