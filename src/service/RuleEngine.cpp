#include "RuleEngine.h"
#include "FileService.h"
#include "../core/ErrorCodes.h"
#include "../core/AppSettings.h"
#include "../rule/rules/ReplaceRule.h"
#include "../rule/rules/RemoveRule.h"
#include "../rule/rules/AddPrefixRule.h"
#include "../rule/rules/AddSuffixRule.h"
#include "../rule/rules/CaseTransformRule.h"
#include "../rule/rules/NumberingRule.h"
#include "../rule/rules/DateTimeRule.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QFileInfo>

RuleEngine::RuleEngine(QObject *parent) : QObject(parent) {}

RuleEngine::~RuleEngine() { clearRulesInternal(); }

BaseResponse RuleEngine::addRule(RuleBase *rule)
{
    if (!rule)
    {
        return BaseResponse::Error(tr("Rule pointer is null"), ErrorCode::INVALID_PARAM);
    }

    rule->setParent(this);
    rules_.append(rule);

    emit ruleCountChanged();
    // history
    emit ruleAdded(rules_.size() - 1);

    return BaseResponse::SuccessWithData(QVariantMap{{"index", rules_.size() - 1}}, tr("Rule added successfully"));
}

BaseResponse RuleEngine::removeRule(int index)
{
    if (index < 0 || index >= rules_.size())
    {
        return BaseResponse::Error(tr("Rule index out of bounds: %1").arg(index), RuleErrorCode::kRuleIndexOutOfRange);
    }

    RuleBase *rule = rules_.takeAt(index);
    delete rule;

    emit ruleCountChanged();
    emit ruleRemoved(index);

    return BaseResponse::Success(tr("Rule deleted"));
}

BaseResponse RuleEngine::moveRule(int fromIndex, int toIndex)
{
    if (fromIndex < 0 || fromIndex >= rules_.size() || toIndex < 0 || toIndex >= rules_.size())
    {
        return BaseResponse::Error(tr("Rule index out of bounds"), RuleErrorCode::kRuleIndexOutOfRange);
    }

    if (fromIndex == toIndex)
    {
        return BaseResponse::Success(tr("Position unchanged"));
    }

    rules_.move(fromIndex, toIndex);

    emit ruleMoved(fromIndex, toIndex);

    return BaseResponse::Success(tr("Rule position adjusted"));
}

BaseResponse RuleEngine::updateRule(int index, const QVariantMap &config)
{
    if (index < 0 || index >= rules_.size())
    {
        return BaseResponse::Error(tr("Rule index out of bounds: %1").arg(index), RuleErrorCode::kRuleIndexOutOfRange);
    }

    // Get rule type from config, fallback to existing rule's type
    QString ruleType = config.value("ruleType", rules_[index]->ruleType()).toString();

    // Create new rule from factory
    RuleBase *newRule = createRule(ruleType);
    if (!newRule)
    {
        return BaseResponse::Error(tr("Unknown rule type: %1").arg(ruleType), ErrorCode::INVALID_PARAM);
    }

    newRule->applyConfig(config);

    QString errorMsg;
    if (!newRule->validate(&errorMsg))
    {
        delete newRule;
        return BaseResponse::Error(tr("Rule validation failed: %1").arg(errorMsg), RuleErrorCode::kRuleValidationFailed);
    }

    // Replace old rule with new one at same index
    newRule->setParent(this);
    delete rules_[index];
    rules_[index] = newRule;

    emit ruleUpdated(index);

    return BaseResponse::Success(tr("Rule updated successfully"));
}

BaseResponse RuleEngine::clearRules()
{
    if (rules_.isEmpty())
    {
        return BaseResponse::Success(tr("Rule list is already empty"));
    }

    clearRulesInternal();

    emit ruleCountChanged();
    emit rulesCleared();

    return BaseResponse::Success(tr("Rule list cleared"));
}

RuleBase *RuleEngine::getRule(int index) const
{
    if (index >= 0 && index < rules_.size())
    {
        return rules_[index];
    }
    return nullptr;
}

QString RuleEngine::applyRules(const QString &input, const FileItem *fileItem, int fileIndex) const
{
    // First check if any remove rule matches
    for (const RuleBase *rule : rules_)
    {
        if (rule && rule->enabled())
        {
            // Check if it's a remove rule
            const RemoveRule *removeRule = qobject_cast<const RemoveRule *>(rule);
            if (removeRule && removeRule->shouldRemoveFile(fileItem))
            {
                // File should be removed, return special marker
                return "__REMOVE_FILE__";
            }
        }
    }

    // If file doesn't need removal, continue applying other rules
    // Check if ignoring extension
    bool ignore_ext = AppSettings::instance()->ignoreExtension();

    if (ignore_ext && fileItem)
    {
        // Separate filename and extension
        QString base_name = fileItem->fileName();  // Without extension
        QString extension = fileItem->extension(); // With extension (e.g., .txt)

        // Apply rules only to filename (exclude remove rules)
        QString result = base_name;
        for (const RuleBase *rule : rules_)
        {
            if (rule && rule->enabled())
            {
                // Skip remove rules
                const RemoveRule *remove_rule = qobject_cast<const RemoveRule *>(rule);
                if (remove_rule)
                    continue;

                result = rule->apply(result, fileItem, fileIndex);
            }
        }

        // Concatenate back with extension
        return result + extension;
    }
    else
    {
        // Apply rules to full filename (exclude remove rules)
        QString result = input;
        for (const RuleBase *rule : rules_)
        {
            if (rule && rule->enabled())
            {
                // Skip remove rules
                const RemoveRule *remove_rule = qobject_cast<const RemoveRule *>(rule);
                if (remove_rule)
                    continue;

                result = rule->apply(result, fileItem, fileIndex);
            }
        }
        return result;
    }
}

BaseResponse RuleEngine::previewAll(FileService *fileService, const QList<int> &selectedIndices)
{
    if (!fileService)
    {
        return BaseResponse::Error(tr("File service pointer is null"), ErrorCode::INVALID_PARAM);
    }

    if (fileService->fileCount() == 0)
    {
        return BaseResponse::Error(tr("No files to preview"), OperationErrorCode::kNoFiles);
    }

    // Convert to QSet for fast lookup
    QSet<int> selected_set = QSet<int>(selectedIndices.begin(), selectedIndices.end());

    // Generate preview results
    QList<QString>           new_names;
    const QList<FileItem *> &files = fileService->getFiles();

    for (int i = 0; i < files.size(); ++i)
    {
        FileItem *file          = files[i];
        QString   original_name = file->fileName() + file->extension(); // Full filename

        // Apply rules only to selected files
        if (!selected_set.isEmpty() && selected_set.contains(i) && !rules_.isEmpty())
        {
            // Selected file: apply rules
            // applyRules receives full filename, file object and file index, returns full new filename or delete marker
            QString result = applyRules(original_name, file, i);

            // Check if marked for deletion
            if (result == "__REMOVE_FILE__")
            {
                new_names.append("[To be removed]");
            }
            else
            {
                new_names.append(result);
            }
        }
        else
        {
            // Unselected file or no rules: keep original name
            new_names.append(original_name);
        }
    }

    // Update preview
    fileService->updatePreview(new_names);

    emit previewUpdated();

    int processed_count = selected_set.isEmpty() ? 0 : selected_set.size();
    if (processed_count > 0 && !rules_.isEmpty())
    {
        return BaseResponse::Success(tr("Preview updated: Processed %1 selected file(s)").arg(processed_count));
    }
    else
    {
        return BaseResponse::Success(tr("Preview updated"));
    }
}

BaseResponse RuleEngine::validateAll() const
{
    // TODO: Implement rule validation
    return BaseResponse::Success(tr("All rules validated successfully"));
}

BaseResponse RuleEngine::saveToFile(const QString &filePath) const
{
    if (filePath.isEmpty())
    {
        return BaseResponse::Error(tr("File path cannot be empty"), ErrorCode::INVALID_PARAM);
    }

    // Check if there are rules to save
    if (rules_.isEmpty())
    {
        return BaseResponse::Error(tr("No rules to save"), ErrorCode::INVALID_PARAM);
    }

    // Convert rules to JSON
    QJsonArray    json_array = toJson();
    QJsonDocument doc(json_array);

    // Write to file
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        return BaseResponse::Error(tr("Failed to open file for writing: %1").arg(file.errorString()),
                                   ProjectErrorCode::kProjectSaveFailed);
    }

    qint64 bytes_written = file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    if (bytes_written == -1)
    {
        return BaseResponse::Error(tr("Failed to write to file"), ProjectErrorCode::kProjectSaveFailed);
    }

    qDebug() << "[RuleEngine] Saved" << rules_.size() << "rules to" << filePath;
    return BaseResponse::Success(tr("Configuration saved successfully: %1 rule(s)").arg(rules_.size()));
}

BaseResponse RuleEngine::loadFromFile(const QString &filePath)
{
    if (filePath.isEmpty())
    {
        return BaseResponse::Error(tr("File path cannot be empty"), ErrorCode::INVALID_PARAM);
    }

    QFileInfo file_info(filePath);
    if (!file_info.exists())
    {
        return BaseResponse::Error(tr("File does not exist: %1").arg(filePath), FileErrorCode::kFileNotExist);
    }

    // Read file
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        return BaseResponse::Error(tr("Failed to open file for reading: %1").arg(file.errorString()),
                                   ProjectErrorCode::kProjectLoadFailed);
    }

    QByteArray file_data = file.readAll();
    file.close();

    // Parse JSON
    QJsonParseError parse_error;
    QJsonDocument   doc = QJsonDocument::fromJson(file_data, &parse_error);

    if (parse_error.error != QJsonParseError::NoError)
    {
        return BaseResponse::Error(tr("Failed to parse JSON: %1").arg(parse_error.errorString()),
                                   ProjectErrorCode::kProjectInvalidFormat);
    }

    if (!doc.isArray())
    {
        return BaseResponse::Error(tr("Invalid configuration format: expected JSON array"),
                                   ProjectErrorCode::kProjectInvalidFormat);
    }

    // Load rules from JSON
    BaseResponse response = fromJson(doc.array());

    if (response.success)
    {
        qDebug() << "[RuleEngine] Loaded" << rules_.size() << "rules from" << filePath;
    }

    return response;
}

QJsonArray RuleEngine::toJson() const
{
    QJsonArray json_array;

    for (const RuleBase *rule : rules_)
    {
        if (rule)
        {
            json_array.append(rule->toJson());
        }
    }

    return json_array;
}

BaseResponse RuleEngine::fromJson(const QJsonArray &json_array)
{
    if (json_array.isEmpty())
    {
        return BaseResponse::Error(tr("Configuration is empty"), ErrorCode::INVALID_PARAM);
    }

    // Clear existing rules
    clearRulesInternal();

    int loaded_count = 0;
    int failed_count = 0;

    // Load each rule
    for (const QJsonValue &value : json_array)
    {
        if (!value.isObject())
        {
            qWarning() << "[RuleEngine] Skipping invalid JSON value (not an object)";
            failed_count++;
            continue;
        }

        QJsonObject json_obj = value.toObject();

        // Get rule type
        if (!json_obj.contains("type"))
        {
            qWarning() << "[RuleEngine] Skipping rule without type field";
            failed_count++;
            continue;
        }

        QString rule_type = json_obj["type"].toString();

        // Create rule instance using factory
        RuleBase *rule = createRule(rule_type);
        if (!rule)
        {
            qWarning() << "[RuleEngine] Unknown rule type:" << rule_type;
            failed_count++;
            continue;
        }

        // Load rule configuration from JSON
        rule->fromJson(json_obj);

        // Validate rule
        QString error_msg;
        if (!rule->validate(&error_msg))
        {
            qWarning() << "[RuleEngine] Rule validation failed:" << error_msg;
            delete rule;
            failed_count++;
            continue;
        }

        // Add to rule list
        rules_.append(rule);
        loaded_count++;
    }

    // Emit signal to update UI
    emit ruleCountChanged();
    emit rulesCleared(); // Signal to clear UI

    // Notify each rule was added (for UI refresh)
    for (int i = 0; i < rules_.size(); ++i)
    {
        emit ruleAdded(i);
    }

    qDebug() << "[RuleEngine] Loaded" << loaded_count << "rules," << failed_count << "failed";

    if (loaded_count == 0)
    {
        return BaseResponse::Error(tr("No valid rules loaded"), ErrorCode::INVALID_PARAM);
    }

    QString message = tr("Configuration loaded successfully: %1 rule(s)").arg(loaded_count);
    if (failed_count > 0)
    {
        message += tr(", %1 rule(s) failed").arg(failed_count);
    }

    return BaseResponse::Success(message);
}

RuleBase *RuleEngine::createRule(const QString &rule_type)
{
    // Rule factory: create corresponding rule instance based on type string
    if (rule_type == "replace" || rule_type == "Replace")
    {
        return new ReplaceRule();
    }
    else if (rule_type == "remove" || rule_type == "Remove")
    {
        return new RemoveRule();
    }
    else if (rule_type == "addPrefix" || rule_type == "AddPrefix")
    {
        return new AddPrefixRule();
    }
    else if (rule_type == "addSuffix" || rule_type == "AddSuffix")
    {
        return new AddSuffixRule();
    }
    else if (rule_type == "format" || rule_type == "Format")
    {
        return new CaseTransformRule();
    }
    else if (rule_type == "numbering" || rule_type == "Numbering")
    {
        return new NumberingRule();
    }
    else if (rule_type == "dateTime" || rule_type == "DateTime")
    {
        return new DateTimeRule();
    }

    return nullptr;
}

void RuleEngine::clearRulesInternal()
{
    qDeleteAll(rules_);
    rules_.clear();
}

QString RuleEngine::getErrorMessage(const QString &operation, const QString &reason) const
{
    return tr("%1 failed: %2").arg(operation, reason);
}
