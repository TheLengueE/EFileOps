#pragma once

#include <QObject>
#include <QList>
#include "../rule/RuleBase.h"
#include "../core/BaseResponse.h"

class FileService;

/**
 * @brief Rule engine
 *
 * Manages all rename rules, responsible for adding, removing, sorting, executing rules
 * Collaborates with FileService to implement preview and batch processing
 * All operations return BaseResponse unified format
 */
class RuleEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int ruleCount READ ruleCount NOTIFY ruleCountChanged)
    Q_PROPERTY(bool hasRules READ hasRules NOTIFY ruleCountChanged)

  public:
    explicit RuleEngine(QObject *parent = nullptr);
    virtual ~RuleEngine();

    // Rule management (return BaseResponse)
    Q_INVOKABLE BaseResponse addRule(RuleBase *rule);
    Q_INVOKABLE BaseResponse removeRule(int index);
    Q_INVOKABLE BaseResponse moveRule(int fromIndex, int toIndex);
    Q_INVOKABLE BaseResponse updateRule(int index, const QVariantMap &config);
    Q_INVOKABLE BaseResponse clearRules();

    // Accessors
    int                      ruleCount() const { return rules_.size(); }
    bool                     hasRules() const { return !rules_.isEmpty(); }
    const QList<RuleBase *> &getRules() const { return rules_; }
    Q_INVOKABLE RuleBase    *getRule(int index) const;

    // Apply rule chain to single file
    QString applyRules(const QString &input, const FileItem *fileItem, int fileIndex = -1) const;

    // Preview all files (collaborate with FileService)
    Q_INVOKABLE BaseResponse previewAll(FileService *fileService, const QList<int> &selectedIndices = QList<int>());

    // Validate all rules
    BaseResponse validateAll() const;

    // Serialization/Deserialization
    Q_INVOKABLE BaseResponse saveToFile(const QString &filePath) const;
    Q_INVOKABLE BaseResponse loadFromFile(const QString &filePath);
    QJsonArray               toJson() const;
    BaseResponse             fromJson(const QJsonArray &jsonArray);

    // Rule factory (create rule instance based on type string)
    static RuleBase *createRule(const QString &ruleType);

  signals:
    void ruleCountChanged();
    void ruleAdded(int index);
    void ruleRemoved(int index);
    void ruleMoved(int fromIndex, int toIndex);
    void ruleUpdated(int index);
    void rulesCleared();
    void previewUpdated();
    void errorOccurred(const QString &message);

  private:
    void    clearRulesInternal(); // Internal cleanup method
    QString getErrorMessage(const QString &operation, const QString &reason) const;

  private:
    QList<RuleBase *> rules_; // RuleEngine owns and is responsible for releasing
};
