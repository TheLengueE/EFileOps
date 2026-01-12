#pragma once

#include <QObject>
#include <QList>
#include "../model/FileItem.h"
#include "../core/BaseResponse.h"

/**
 * @brief File service class
 *
 * Responsible for file list management, add, remove, clear operations
 * Supports undo/redo functionality
 * All operations return BaseResponse unified format
 */
class FileService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int fileCount READ fileCount NOTIFY fileCountChanged)
    Q_PROPERTY(int maxFileCount READ maxFileCount CONSTANT)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY canRedoChanged)

  public:
    enum class SortType
    {
        ByName,        // Sort by file name
        ByModifiedTime // Sort by modification time
    };
    Q_ENUM(SortType)

    static constexpr int kMaxFileCount = 4096;

    explicit FileService(QObject *parent = nullptr);
    virtual ~FileService();

    // File operations (return BaseResponse)
    Q_INVOKABLE BaseResponse addFile(const QString &filePath);
    Q_INVOKABLE BaseResponse addFiles(const QStringList &filePaths);
    Q_INVOKABLE BaseResponse addFolder(const QString &folderPath, bool recursive = false);
    Q_INVOKABLE BaseResponse removeFile(int index);
    Q_INVOKABLE BaseResponse removeFiles(const QList<int> &indices);
    Q_INVOKABLE BaseResponse clear();

    // Accessors
    int                      fileCount() const { return files_.size(); }
    int                      maxFileCount() const { return kMaxFileCount; }
    const QList<FileItem *> &getFiles() const { return files_; }
    FileItem                *getFile(int index) const;

    // Undo/Redo
    bool                     canUndo() const { return current_history_index_ > 0; }
    bool                     canRedo() const { return current_history_index_ < history_.size() - 1; }
    Q_INVOKABLE BaseResponse undo();
    Q_INVOKABLE BaseResponse redo();
    Q_INVOKABLE void         clearHistory();

    // Save snapshot (for undo)
    void saveSnapshot();

    // Batch execute rename (only for selected files)
    Q_INVOKABLE BaseResponse executeRename(const QList<int> &selectedIndices = QList<int>());

    // Preview update (called by rule engine)
    void updatePreview(const QList<QString> &newNames);

    // Export/Import
    Q_INVOKABLE BaseResponse exportToJson(const QString &filePath) const;
    Q_INVOKABLE BaseResponse importFromJson(const QString &filePath);

    // Sort
    Q_INVOKABLE void sortFiles(SortType sortType);

  signals:
    void fileCountChanged();
    void filesAdded(int count);
    void filesRemoved(int count);
    void fileUpdated(int index);
    void allFilesCleared();
    void filesRestored(); // Restore file list after undo/redo
    void filesSorted();   // Files sorted
    void canUndoChanged();
    void canRedoChanged();
    void renameExecuted(int successCount, int failureCount);
    void errorOccurred(const QString &message);

  private:
    struct Snapshot
    {
        QList<FileItem *> files;
        QDateTime         timestamp;

        // Deep copy constructor
        Snapshot() = default;
        Snapshot(const Snapshot &other);
        ~Snapshot();
        Snapshot &operator=(const Snapshot &other);
    };

    bool isFilePathValid(const QString &filePath) const;
    bool isDuplicate(const QString &filePath) const;
    void addToHistory(const Snapshot &snapshot);
    void trimHistory();
    void clearFiles(); // Internal cleanup method

    // Error message generation
    QString getErrorMessage(const QString &operation, const QString &reason) const;

  private:
    // Note: FileItem uses QObject parent-child relationship for memory management
    // Alternative: Could use QList<QSharedPointer<FileItem>> for shared ownership
    QList<FileItem *>    files_; // FileService owns and is responsible for releasing
    QList<Snapshot>      history_;
    int                  current_history_index_;
    static constexpr int kMaxHistorySize = 50;

    // Performance optimization: Use QSet to cache file paths, avoid O(n²) duplicate checks
    QSet<QString> file_path_cache_; // Store normalized file paths
};
