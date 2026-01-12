#include "FileItem.h"
#include <QFileInfo>
#include <QDir>

FileItem::FileItem(QObject *parent)
    : QObject(parent), size_(0), has_error_(false), execution_status_(ExecutionStatus::Pending)
{
}

FileItem::FileItem(const QString &filePath, QObject *parent)
    : QObject(parent), size_(0), has_error_(false), execution_status_(ExecutionStatus::Pending)
{

    parseFilePath(filePath);
}

void FileItem::setNewName(const QString &newName)
{
    if (new_name_ != newName)
    {
        new_name_ = newName;
        emit newNameChanged();
    }
}

void FileItem::setHasError(bool hasError)
{
    if (has_error_ != hasError)
    {
        has_error_ = hasError;
        emit hasErrorChanged();
    }
}

void FileItem::setErrorMessage(const QString &message)
{
    if (error_message_ != message)
    {
        error_message_ = message;
        emit errorMessageChanged();
    }
}

void FileItem::setExecutionStatus(ExecutionStatus status)
{
    if (execution_status_ != status)
    {
        execution_status_ = status;
        emit executionStatusChanged();
    }
}

void FileItem::reset()
{
    setNewName(file_name_ + extension_); // Restore to complete original file name
    setHasError(false);
    setErrorMessage(QString());
    setExecutionStatus(ExecutionStatus::Pending);
}

QString FileItem::getNewPath() const
{
    QFileInfo file_info(original_path_);
    QString   dir_path = file_info.absolutePath();
    // new_name_ should already contain the complete file name (with extension)
    return QDir(dir_path).filePath(new_name_);
}

bool FileItem::isModified() const
{
    // Compare complete file name (with extension)
    QString original_full_name = file_name_ + extension_;
    return original_full_name != new_name_;
}

void FileItem::parseFilePath(const QString &filePath)
{
    QFileInfo file_info(filePath);

    // Save original path
    original_path_ = file_info.absoluteFilePath();

    // Filter hidden files and files starting with dot
    QString full_file_name = file_info.fileName();
    if (full_file_name.isEmpty() || full_file_name.startsWith('.'))
    {
        file_name_ = "";
        extension_ = "";
        new_name_  = "";
        return;
    }

    // Extract file name and extension
    QString complete_base_name = file_info.completeBaseName();
    QString suffix             = file_info.suffix();

    file_name_ = complete_base_name;
    extension_ = suffix.isEmpty() ? QString() : "." + suffix;

    // Initialize new file name to original file name (complete, with extension)
    new_name_ = file_name_ + extension_;

    // Get file information
    size_     = file_info.size();
    created_  = file_info.birthTime();
    modified_ = file_info.lastModified();
}
