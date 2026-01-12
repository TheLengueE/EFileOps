#pragma once

#include <QString>
#include <QDateTime>
#include <QObject>

/**
 * @brief File item data model
 *
 * Stores metadata and rename status for a single file
 */
class FileItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString originalPath READ originalPath CONSTANT)
    Q_PROPERTY(QString fileName READ fileName CONSTANT)
    Q_PROPERTY(QString extension READ extension CONSTANT)
    Q_PROPERTY(QString newName READ newName WRITE setNewName NOTIFY newNameChanged)
    Q_PROPERTY(qint64 size READ size CONSTANT)
    Q_PROPERTY(QDateTime created READ created CONSTANT)
    Q_PROPERTY(QDateTime modified READ modified CONSTANT)
    Q_PROPERTY(bool hasError READ hasError WRITE setHasError NOTIFY hasErrorChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage WRITE setErrorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(
        ExecutionStatus executionStatus READ executionStatus WRITE setExecutionStatus NOTIFY executionStatusChanged)

  public:
    enum class ExecutionStatus
    {
        Pending, // Pending execution
        Success, // Execution success
        Failed   // Execution failed
    };
    Q_ENUM(ExecutionStatus)

    explicit FileItem(QObject *parent = nullptr);
    FileItem(const QString &filePath, QObject *parent = nullptr);

    // Getters
    QString         originalPath() const { return original_path_; }
    QString         fileName() const { return file_name_; }
    QString         extension() const { return extension_; }
    QString         newName() const { return new_name_; }
    qint64          size() const { return size_; }
    QDateTime       created() const { return created_; }
    QDateTime       modified() const { return modified_; }
    bool            hasError() const { return has_error_; }
    QString         errorMessage() const { return error_message_; }
    ExecutionStatus executionStatus() const { return execution_status_; }

    // Setters
    void setNewName(const QString &newName);
    void setHasError(bool hasError);
    void setErrorMessage(const QString &message);
    void setExecutionStatus(ExecutionStatus status);

    // Reset to original state
    void reset();

    // Get complete new path
    QString getNewPath() const;

    // Check if modified
    bool isModified() const;

  signals:
    void newNameChanged();
    void hasErrorChanged();
    void errorMessageChanged();
    void executionStatusChanged();

  private:
    void parseFilePath(const QString &filePath);

  private:
    QString         original_path_;    // Original full path
    QString         file_name_;        // File name (without extension)
    QString         extension_;        // Extension (with dot)
    QString         new_name_;         // New file name (calculated by rules)
    qint64          size_;             // File size (bytes)
    QDateTime       created_;          // Creation time
    QDateTime       modified_;         // Modification time
    bool            has_error_;        // Whether has error
    QString         error_message_;    // Error message
    ExecutionStatus execution_status_; // Execution status
};
