#pragma once

#include <QObject>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "../core/BaseRequest.h"
#include "../core/BaseResponse.h"
#include "../core/AppSettings.h"
#include "../service/FileService.h"
#include "../service/RuleEngine.h"

class FileListModel; // Forward declaration

/**
 * @brief Main controller
 *
 * Coordinates FileService and RuleEngine, serving as a bridge between QML and C++ business logic
 * Uses a unified Request-Response pattern to handle all operations
 *
 * Supported modules:
 * - "file": File management operations
 * - "rule": Rule management operations
 * - "project": Project management operations
 * - "operation": Execution operations (preview, rename)
 */
class MainController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(FileService *fileService READ fileService CONSTANT)
    Q_PROPERTY(RuleEngine *ruleEngine READ ruleEngine CONSTANT)
    Q_PROPERTY(AppSettings *settings READ settings CONSTANT)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)
    Q_PROPERTY(int lastExecutedCount READ lastExecutedCount NOTIFY executionStatsChanged)
    Q_PROPERTY(int lastSuccessCount READ lastSuccessCount NOTIFY executionStatsChanged)
    Q_PROPERTY(int lastFailureCount READ lastFailureCount NOTIFY executionStatsChanged)

  public:
    explicit MainController(QObject *parent = nullptr);
    virtual ~MainController();

    // Accessors
    FileService *fileService() const { return file_service_; }
    RuleEngine  *ruleEngine() const { return rule_engine_; }
    AppSettings *settings() const { return AppSettings::instance(); }
    QString      statusMessage() const { return status_message_; }
    bool         isBusy() const { return is_busy_; }

    // Set selected file indices (for preview)
    Q_INVOKABLE void setSelectedIndices(const QList<int> &indices);
    QList<int>       selectedIndices() const { return selected_indices_; }

    // Execution statistics accessors
    int lastExecutedCount() const { return last_executed_count_; }
    int lastSuccessCount() const { return last_success_count_; }
    int lastFailureCount() const { return last_failure_count_; }

    // ========== Unified request handling interface ==========
    Q_INVOKABLE BaseResponse handleRequest(const BaseRequest &request);

    // ========== Convenience methods (internally use Request-Response) ==========

    // File operations
    Q_INVOKABLE BaseResponse addFiles(const QStringList &filePaths);
    Q_INVOKABLE BaseResponse addFolder(const QString &folderPath, bool recursive = false);
    Q_INVOKABLE BaseResponse removeFiles(const QList<int> &indices);
    Q_INVOKABLE BaseResponse clearFiles();
    Q_INVOKABLE int          getFolderFileCount(const QString &folderPath, bool recursive = false);

    // Rule operations
    Q_INVOKABLE BaseResponse addRule(const QString &ruleType, const QVariantMap &config = QVariantMap());
    Q_INVOKABLE BaseResponse removeRule(int index);
    Q_INVOKABLE BaseResponse moveRule(int fromIndex, int toIndex);
    Q_INVOKABLE BaseResponse updateRule(int index, const QVariantMap &config);
    Q_INVOKABLE BaseResponse clearRules();

    // Rule configuration save/load
    Q_INVOKABLE BaseResponse saveRulesConfig(const QString &filePath);
    Q_INVOKABLE BaseResponse loadRulesConfig(const QString &filePath);

    // Execution operations
    Q_INVOKABLE BaseResponse preview();
    Q_INVOKABLE BaseResponse execute();

    // History operations
    Q_INVOKABLE BaseResponse undo();
    Q_INVOKABLE BaseResponse redo();

    // Project management
    Q_INVOKABLE BaseResponse saveProject(const QString &filePath);
    Q_INVOKABLE BaseResponse loadProject(const QString &filePath);
    Q_INVOKABLE BaseResponse exportRenameList(const QString &filePath);

    // Session management (auto save/restore)
    Q_INVOKABLE BaseResponse saveSession();
    Q_INVOKABLE BaseResponse loadSession();
    Q_INVOKABLE void         autoSaveSession(); // Called when app is about to quit

    // Set FileListModel reference (called from Main.cpp)
    void setFileListModel(FileListModel *model) { file_list_model_ = model; }

  signals:
    void statusMessageChanged();
    void isBusyChanged();
    void operationCompleted(const BaseResponse &response);
    void progressUpdated(int current, int total);
    void executionStatsChanged();          // Execution statistics changed signal
    void executionFailed(int failedCount); // Execution failed with rollback signal

  private slots:
    void onFileCountChanged();
    void onRuleCountChanged();
    void onRenameExecuted(int successCount, int failureCount);

  private:
    // ========== Request handlers (classified by module) ==========
    BaseResponse handleFileRequest(const BaseRequest &request);
    BaseResponse handleRuleRequest(const BaseRequest &request);
    BaseResponse handleProjectRequest(const BaseRequest &request);
    BaseResponse handleOperationRequest(const BaseRequest &request);

    // ========== Internal utility methods ==========
    void setStatusMessage(const QString &message);
    void setBusy(bool busy);
    void updatePreview();

    // Validate request parameters
    bool validateRequest(const BaseRequest &request, const QStringList &requiredParams, QString *errorMsg = nullptr);

  private:
    FileService   *file_service_;
    RuleEngine    *rule_engine_;
    FileListModel *file_list_model_ = nullptr; // File list model reference (for auto-selection)
    QString        status_message_;
    bool           is_busy_;
    QList<int>     selected_indices_; // Currently selected file indices

    // Last execution statistics
    int last_executed_count_ = 0;
    int last_success_count_  = 0;
    int last_failure_count_  = 0;
};

/**
 * @brief Request/Response constant definitions
 *
 * Unified management of all operation module and action names
 */
namespace RequestAction
{
// File module actions
namespace File
{
constexpr const char *kModule      = "file";
constexpr const char *kAddFiles    = "addFiles";
constexpr const char *kAddFolder   = "addFolder";
constexpr const char *kRemoveFiles = "removeFiles";
constexpr const char *kClear       = "clear";
constexpr const char *kGetFile     = "getFile";
constexpr const char *kGetAll      = "getAll";
} // namespace File

// Rule module actions
namespace Rule
{
constexpr const char *kModule  = "rule";
constexpr const char *kAdd     = "add";
constexpr const char *kRemove  = "remove";
constexpr const char *kMove    = "move";
constexpr const char *kUpdate  = "update";
constexpr const char *kClear   = "clear";
constexpr const char *kGetRule = "getRule";
constexpr const char *kGetAll  = "getAll";
} // namespace Rule

// Project module actions
namespace Project
{
constexpr const char *kModule     = "project";
constexpr const char *kSave       = "save";
constexpr const char *kLoad       = "load";
constexpr const char *kExportList = "exportList";
constexpr const char *kNew        = "new";
} // namespace Project

// Operation module actions
namespace Operation
{
constexpr const char *kModule   = "operation";
constexpr const char *kPreview  = "preview";
constexpr const char *kExecute  = "execute";
constexpr const char *kUndo     = "undo";
constexpr const char *kRedo     = "redo";
constexpr const char *kValidate = "validate";
} // namespace Operation
} // namespace RequestAction
