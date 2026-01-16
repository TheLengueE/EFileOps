#include "MainController.h"
#include "../core/ErrorCodes.h"
#include "../util/FileSystemHelper.h"
#include "../model/FileListModel.h"
#include "../core/AppSettings.h"

MainController::MainController(QObject *parent)
    : QObject(parent), file_service_(new FileService(this)), rule_engine_(new RuleEngine(this)), is_busy_(false)
{
    // Connect signals
    connect(file_service_, &FileService::fileCountChanged, this, &MainController::onFileCountChanged);
    connect(rule_engine_, &RuleEngine::ruleCountChanged, this, &MainController::onRuleCountChanged);
    connect(file_service_, &FileService::renameExecuted, this, &MainController::onRenameExecuted);

    // Listen to settings changes, auto update preview
    connect(AppSettings::instance(), &AppSettings::ignoreExtensionChanged, this, &MainController::updatePreview);
}

MainController::~MainController() {}

BaseResponse MainController::handleRequest(const BaseRequest &request)
{
    const QString module = request.module;

    if (module == RequestAction::File::kModule)
    {
        return handleFileRequest(request);
    }
    else if (module == RequestAction::Rule::kModule)
    {
        return handleRuleRequest(request);
    }
    else if (module == RequestAction::Project::kModule)
    {
        return handleProjectRequest(request);
    }
    else if (module == RequestAction::Operation::kModule)
    {
        return handleOperationRequest(request);
    }
    else
    {
        return BaseResponse::Error(tr("Unknown module: %1").arg(module), ErrorCode::UNKNOWN_MODULE);
    }
}

BaseResponse MainController::addFiles(const QStringList &filePaths)
{
    int old_count = file_service_->fileCount();

    setBusy(true);
    auto response = file_service_->addFiles(filePaths);
    setBusy(false);

    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Auto-select newly added files (before sorting)
    if (response.success && file_list_model_)
    {
        int new_count   = file_service_->fileCount();
        int added_count = new_count - old_count;
        if (added_count > 0)
        {
            file_list_model_->selectRange(old_count, new_count);
            qDebug() << "[MainController] Auto-selected newly added files, range:" << old_count << "to" << new_count;

            // Apply default sort mode after selection
            int default_sort_mode = AppSettings::instance()->defaultSortMode();
            file_service_->sortFiles((default_sort_mode == 1) ? FileService::SortType::ByModifiedTime
                                                              : FileService::SortType::ByName);
            qDebug() << "[MainController] Applied default sort mode:" << default_sort_mode;
        }
    }

    return response;
}

BaseResponse MainController::addFolder(const QString &folderPath, bool recursive)
{
    int old_count = file_service_->fileCount();

    setBusy(true);
    auto response = file_service_->addFolder(folderPath, recursive);
    setBusy(false);

    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Auto-select newly added files (before sorting)
    if (response.success && file_list_model_)
    {
        int new_count   = file_service_->fileCount();
        int added_count = new_count - old_count;
        if (added_count > 0)
        {
            file_list_model_->selectRange(old_count, new_count);
            qDebug() << "[MainController] Auto-selected newly added files, range:" << old_count << "to" << new_count;

            // Apply default sort mode after selection
            int default_sort_mode = AppSettings::instance()->defaultSortMode();
            file_service_->sortFiles((default_sort_mode == 1) ? FileService::SortType::ByModifiedTime
                                                              : FileService::SortType::ByName);
            qDebug() << "[MainController] Applied default sort mode:" << default_sort_mode;
        }
    }

    return response;
}

BaseResponse MainController::removeFiles(const QList<int> &indices)
{
    setBusy(true);
    auto response = file_service_->removeFiles(indices);
    setBusy(false);

    setStatusMessage(response.message);
    emit operationCompleted(response);

    return response;
}

BaseResponse MainController::clearFiles()
{
    auto response = file_service_->clear();
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Reset execution statistics
    if (response.success)
    {
        last_executed_count_ = 0;
        last_success_count_  = 0;
        last_failure_count_  = 0;
        emit executionStatsChanged();
    }

    return response;
}

int MainController::getFolderFileCount(const QString &folderPath, bool recursive)
{
    QStringList files = FileSystemHelper::getFilesInDirectory(folderPath, recursive);
    return files.size();
}

BaseResponse MainController::addRule(const QString &ruleType, const QVariantMap &config)
{
    // Use rule factory to create rule instance
    RuleBase *rule = RuleEngine::createRule(ruleType);

    if (!rule)
    {
        return BaseResponse::Error(tr("Unknown rule type: %1").arg(ruleType), ErrorCode::INVALID_PARAM);
    }

    // Let the rule apply its own configuration
    rule->applyConfig(config);

    // Validate rule
    QString errorMsg;
    if (!rule->validate(&errorMsg))
    {
        delete rule;
        return BaseResponse::Error(tr("Rule validation failed: %1").arg(errorMsg),
                                   RuleErrorCode::kRuleValidationFailed);
    }

    // Add rule to engine
    auto response = rule_engine_->addRule(rule);

    if (response.success)
    {
        setStatusMessage(response.message);
        emit operationCompleted(response);

        // Update preview immediately after adding rule
        updatePreview();
    }
    else
    {
        delete rule; // Delete rule if addition failed
    }

    return response;
}

BaseResponse MainController::removeRule(int index)
{
    auto response = rule_engine_->removeRule(index);
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Update preview immediately after removing rule
    if (response.success)
    {
        updatePreview();
    }

    return response;
}

BaseResponse MainController::moveRule(int fromIndex, int toIndex)
{
    auto response = rule_engine_->moveRule(fromIndex, toIndex);
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Update preview immediately after moving rule
    if (response.success)
    {
        updatePreview();
    }

    return response;
}

BaseResponse MainController::updateRule(int index, const QVariantMap &config)
{
    auto response = rule_engine_->updateRule(index, config);
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Update preview immediately after updating rule
    if (response.success)
    {
        updatePreview();
    }

    return response;
}

BaseResponse MainController::clearRules()
{
    auto response = rule_engine_->clearRules();
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Update preview immediately after clearing rules
    if (response.success)
    {
        updatePreview();
    }

    return response;
}

BaseResponse MainController::saveRulesConfig(const QString &filePath)
{
    auto response = rule_engine_->saveToFile(filePath);
    setStatusMessage(response.message);
    emit operationCompleted(response);
    return response;
}

BaseResponse MainController::loadRulesConfig(const QString &filePath)
{
    auto response = rule_engine_->loadFromFile(filePath);
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Update preview after loading rules
    if (response.success)
    {
        updatePreview();
    }

    return response;
}

BaseResponse MainController::preview()
{
    setBusy(true);
    auto response = rule_engine_->previewAll(file_service_);
    setBusy(false);

    setStatusMessage(response.message);
    emit operationCompleted(response);

    return response;
}

BaseResponse MainController::execute()
{
    qDebug() << "[MainController::execute] Start executing rename";
    qDebug() << "  Selected files count:" << selected_indices_.size();
    qDebug() << "  Rules count:" << rule_engine_->ruleCount();

    // Validate if any files are selected
    if (selected_indices_.isEmpty())
    {
        qDebug() << "  [Error] No files selected";
        return BaseResponse::Error(tr("Please select files to process first"), OperationErrorCode::kNoFiles);
    }

    setBusy(true);
    auto response = file_service_->executeRename(selected_indices_);
    setBusy(false);

    qDebug() << "  Execution result:" << (response.success ? "Success" : "Failed");
    qDebug() << "  Return message:" << response.message;

    setStatusMessage(response.message);
    emit operationCompleted(response);

    return response;
}

BaseResponse MainController::undo()
{
    auto response = file_service_->undo();
    setStatusMessage(response.message);
    emit operationCompleted(response);

    // Reset execution statistics after successful undo
    if (response.success)
    {
        last_executed_count_ = 0;
        last_success_count_  = 0;
        last_failure_count_  = 0;
        emit executionStatsChanged();
    }

    return response;
}

BaseResponse MainController::redo()
{
    auto response = file_service_->redo();
    setStatusMessage(response.message);
    emit operationCompleted(response);
    return response;
}

BaseResponse MainController::saveProject(const QString &filePath)
{
    QJsonObject project;
    project["version"] = "1.0";

    // Save files
    QJsonArray filesArray;
    for (int i = 0; i < file_service_->fileCount(); ++i)
    {
        FileItem   *item = file_service_->getFile(i);
        QJsonObject fileObj;
        fileObj["originalPath"] = item->originalPath();
        fileObj["newName"]      = item->newName();
        filesArray.append(fileObj);
    }
    project["files"] = filesArray;

    // Save rules
    QJsonArray rulesArray;
    for (int i = 0; i < rule_engine_->ruleCount(); ++i)
    {
        RuleBase *rule = rule_engine_->getRule(i);
        if (rule)
        {
            rulesArray.append(rule->toJson());
        }
    }
    project["rules"] = rulesArray;

    // Write to file
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly))
    {
        return BaseResponse::Error(tr("Failed to save project: %1").arg(filePath), FileErrorCode::kFileOpenFailed);
    }

    QJsonDocument doc(project);
    file.write(doc.toJson());
    file.close();

    return BaseResponse::Success(tr("Project saved successfully"));
}

BaseResponse MainController::loadProject(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
    {
        return BaseResponse::Error(tr("Failed to load project: %1").arg(filePath), FileErrorCode::kFileOpenFailed);
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject())
    {
        return BaseResponse::Error(tr("Invalid project file format"), FileErrorCode::kFileFormatError);
    }

    QJsonObject project = doc.object();

    // Clear current state
    clearFiles();
    clearRules();

    // Load files
    QJsonArray  filesArray = project["files"].toArray();
    QStringList filePaths;
    for (const QJsonValue &value : filesArray)
    {
        QJsonObject fileObj      = value.toObject();
        QString     originalPath = fileObj["originalPath"].toString();
        if (QFileInfo::exists(originalPath))
        {
            filePaths.append(originalPath);
        }
    }

    if (!filePaths.isEmpty())
    {
        addFiles(filePaths);
    }

    // Load rules
    QJsonArray rulesArray = project["rules"].toArray();
    for (const QJsonValue &value : rulesArray)
    {
        QJsonObject ruleObj  = value.toObject();
        QString     ruleType = ruleObj["ruleType"].toString();

        // Create rule and load config
        RuleBase *rule = RuleEngine::createRule(ruleType);
        if (rule)
        {
            rule->fromJson(ruleObj);
            auto response = rule_engine_->addRule(rule);
            if (!response.success)
            {
                delete rule;
            }
        }
    }

    // Trigger preview
    preview();

    return BaseResponse::Success(tr("Project loaded successfully"));
}

BaseResponse MainController::exportRenameList(const QString &filePath)
{
    // TODO: Implement export rename list
    return BaseResponse::Error(tr("Feature not implemented yet"), ErrorCode::NOT_IMPLEMENTED);
}

BaseResponse MainController::saveSession()
{
    QString sessionPath = AppSettings::instance()->getSessionFilePath();

    // Ensure directory exists
    QFileInfo fileInfo(sessionPath);
    QDir().mkpath(fileInfo.absolutePath());

    return saveProject(sessionPath);
}

BaseResponse MainController::loadSession()
{
    QString sessionPath = AppSettings::instance()->getSessionFilePath();

    if (!QFileInfo::exists(sessionPath))
    {
        qDebug() << "[MainController] No session file found, starting fresh";
        return BaseResponse::Success(tr("No previous session found"));
    }

    qDebug() << "[MainController] Loading session from:" << sessionPath;
    return loadProject(sessionPath);
}

void MainController::autoSaveSession()
{
    if (!AppSettings::instance()->autoRestoreSession())
    {
        qDebug() << "[MainController] Auto restore disabled, skipping session save";
        return;
    }

    // Only save if there are files or rules
    if (file_service_->fileCount() == 0 && rule_engine_->ruleCount() == 0)
    {
        qDebug() << "[MainController] No content to save";
        return;
    }

    qDebug() << "[MainController] Auto-saving session...";
    auto response = saveSession();
    if (response.success)
    {
        qDebug() << "[MainController] Session saved successfully";
    }
    else
    {
        qWarning() << "[MainController] Failed to save session:" << response.message;
    }
}

void MainController::onFileCountChanged()
{
    // Auto update preview when file count changes
    if (rule_engine_->ruleCount() > 0)
    {
        updatePreview();
    }
}

void MainController::onRuleCountChanged()
{
    // Auto update preview when rule count changes
    if (file_service_->fileCount() > 0)
    {
        updatePreview();
    }
}

void MainController::onRenameExecuted(int successCount, int failureCount)
{
    // Update execution statistics
    last_executed_count_ = successCount + failureCount;
    last_success_count_  = successCount;
    last_failure_count_  = failureCount;

    emit executionStatsChanged();

    // If there were failures and rollback occurred (successCount = 0), emit executionFailed signal
    if (failureCount > 0 && successCount == 0)
    {
        emit executionFailed(failureCount);
    }

    QString msg = tr("Rename complete: Successful %1, failed %2").arg(successCount).arg(failureCount);
    setStatusMessage(msg);
}

BaseResponse MainController::handleFileRequest(const BaseRequest &request)
{
    const QString action = request.action;

    if (action == RequestAction::File::kAddFiles)
    {
        QStringList paths = request.params["filePaths"].toStringList();
        return addFiles(paths);
    }
    else if (action == RequestAction::File::kAddFolder)
    {
        QString path      = request.params["folderPath"].toString();
        bool    recursive = request.params.value("recursive", false).toBool();
        return addFolder(path, recursive);
    }
    else if (action == RequestAction::File::kRemoveFiles)
    {
        QList<int> indices = request.params["indices"].value<QList<int>>();
        return removeFiles(indices);
    }
    else if (action == RequestAction::File::kClear)
    {
        return clearFiles();
    }

    return BaseResponse::Error(tr("Unknown file operation: %1").arg(action), ErrorCode::UNKNOWN_ACTION);
}

BaseResponse MainController::handleRuleRequest(const BaseRequest &request)
{
    const QString action = request.action;

    if (action == RequestAction::Rule::kAdd)
    {
        QString     type   = request.params["ruleType"].toString();
        QVariantMap config = request.params["config"].toMap();
        return addRule(type, config);
    }
    else if (action == RequestAction::Rule::kRemove)
    {
        int index = request.params["index"].toInt();
        return removeRule(index);
    }
    else if (action == RequestAction::Rule::kMove)
    {
        int from = request.params["fromIndex"].toInt();
        int to   = request.params["toIndex"].toInt();
        return moveRule(from, to);
    }
    else if (action == RequestAction::Rule::kClear)
    {
        return clearRules();
    }

    return BaseResponse::Error(tr("Unknown rule operation: %1").arg(action), ErrorCode::UNKNOWN_ACTION);
}

BaseResponse MainController::handleProjectRequest(const BaseRequest &request)
{
    const QString action = request.action;

    if (action == RequestAction::Project::kSave)
    {
        QString path = request.params["filePath"].toString();
        return saveProject(path);
    }
    else if (action == RequestAction::Project::kLoad)
    {
        QString path = request.params["filePath"].toString();
        return loadProject(path);
    }
    else if (action == RequestAction::Project::kExportList)
    {
        QString path = request.params["filePath"].toString();
        return exportRenameList(path);
    }

    return BaseResponse::Error(tr("Unknown project operation: %1").arg(action), ErrorCode::UNKNOWN_ACTION);
}

BaseResponse MainController::handleOperationRequest(const BaseRequest &request)
{
    const QString action = request.action;

    if (action == RequestAction::Operation::kPreview)
    {
        return preview();
    }
    else if (action == RequestAction::Operation::kExecute)
    {
        return execute();
    }
    else if (action == RequestAction::Operation::kUndo)
    {
        return undo();
    }
    else if (action == RequestAction::Operation::kRedo)
    {
        return redo();
    }

    return BaseResponse::Error(tr("Unknown operation: %1").arg(action), ErrorCode::UNKNOWN_ACTION);
}

void MainController::setStatusMessage(const QString &message)
{
    if (status_message_ != message)
    {
        status_message_ = message;
        emit statusMessageChanged();
    }
}

void MainController::setBusy(bool busy)
{
    if (is_busy_ != busy)
    {
        is_busy_ = busy;
        emit isBusyChanged();
    }
}

void MainController::updatePreview()
{
    // Auto preview update, using currently selected file indices
    rule_engine_->previewAll(file_service_, selected_indices_);
}

void MainController::setSelectedIndices(const QList<int> &indices)
{
    selected_indices_ = indices;
    qDebug() << "[MainController] Set selected indices, count:" << indices.size();
    // Auto update preview when selection state changes
    if (rule_engine_->ruleCount() > 0)
    {
        updatePreview();
    }
}

bool MainController::validateRequest(const BaseRequest &request, const QStringList &requiredParams, QString *errorMsg)
{
    for (const QString &param : requiredParams)
    {
        if (!request.params.contains(param))
        {
            if (errorMsg)
            {
                *errorMsg = tr("Missing required parameter: %1").arg(param);
            }
            return false;
        }
    }
    return true;
}
