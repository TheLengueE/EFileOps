#include "FileSystemHelper.h"
#include <QDir>
#include <QDirIterator>
#include <QRegularExpression>

QStringList FileSystemHelper::getFilesInDirectory(const QString &dir_path, bool recursive, int max_count)
{
    QStringList files;

    QDir::Filters               filters = QDir::Files | QDir::NoDotAndDotDot | QDir::Hidden;
    QDirIterator::IteratorFlags flags   = recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

    QDirIterator it(dir_path, filters, flags);

    while (it.hasNext())
    {
        // If max count is set and reached, stop scanning
        if (max_count > 0 && files.size() >= max_count)
        {
            break;
        }

        QString   file_path = it.next();
        QFileInfo file_info(file_path);

        // Filter hidden files and files with empty names
        if (file_info.isHidden())
        {
            continue;
        }

        QString file_name = file_info.fileName();
        if (file_name.isEmpty() || file_name.startsWith('.'))
        {
            continue;
        }

        files.append(file_path);
    }

    return files;
}

bool FileSystemHelper::isValidFileName(const QString &file_name)
{
    // Windows invalid characters: < > : " / \ | ? *
    static const QString kInvalidChars = "<>:\"/\\|?*";

    for (const QChar &ch : file_name)
    {
        if (kInvalidChars.contains(ch) || ch.unicode() < 32)
        {
            return false;
        }
    }

    return !file_name.isEmpty();
}

QString FileSystemHelper::getInvalidChars() { return "<>:\"/\\|?*"; }

QString FileSystemHelper::sanitizeFileName(const QString &file_name)
{
    QString result        = file_name;
    QString invalid_chars = getInvalidChars();

    for (const QChar &ch : invalid_chars)
    {
        result.replace(ch, '_');
    }

    // Remove control characters
    result.remove(QRegularExpression("[\\x00-\\x1F]"));

    return result;
}

bool FileSystemHelper::hasConflict(const QString &original_path, const QString &new_path)
{
    if (original_path == new_path)
    {
        return false;
    }

    return QFileInfo::exists(new_path);
}

QString FileSystemHelper::generateUniqueName(const QString &base_path, const QString &file_name)
{
    QFileInfo file_info(base_path, file_name);

    if (!file_info.exists())
    {
        return file_name;
    }

    QString name      = file_info.completeBaseName();
    QString extension = file_info.suffix().isEmpty() ? QString() : "." + file_info.suffix();

    int     counter = 1;
    QString new_file_name;

    do
    {
        new_file_name = QString("%1 (%2)%3").arg(name).arg(counter).arg(extension);
        counter++;
    } while (QFileInfo(base_path, new_file_name).exists());

    return new_file_name;
}

QString FileSystemHelper::formatFileSize(qint64 bytes)
{
    const qint64 kKB = 1024;
    const qint64 kMB = 1024 * kKB;
    const qint64 kGB = 1024 * kMB;

    if (bytes >= kGB)
    {
        return QString::number(bytes / (double) kGB, 'f', 2) + " GB";
    }
    else if (bytes >= kMB)
    {
        return QString::number(bytes / (double) kMB, 'f', 2) + " MB";
    }
    else if (bytes >= kKB)
    {
        return QString::number(bytes / (double) kKB, 'f', 2) + " KB";
    }
    else
    {
        return QString::number(bytes) + " B";
    }
}

bool FileSystemHelper::batchRename(const QStringList &old_paths, const QStringList &new_paths, QString *error_message)
{
    // TODO: Implement atomic batch rename
    if (error_message)
    {
        *error_message = "Feature not implemented";
    }
    return false;
}

bool FileSystemHelper::safeRename(const QString &old_path, const QString &new_path, QString *error_message)
{
    QFileInfo old_file(old_path);

    if (!old_file.exists())
    {
        if (error_message)
        {
            *error_message = "Source file does not exist";
        }
        return false;
    }

    if (QFileInfo::exists(new_path))
    {
        if (error_message)
        {
            *error_message = "Target file already exists";
        }
        return false;
    }

    QDir dir;
    if (!dir.rename(old_path, new_path))
    {
        if (error_message)
        {
            *error_message = "Rename failed";
        }
        return false;
    }

    return true;
}

bool FileSystemHelper::isHiddenFile(const QString &file_path)
{
    QFileInfo file_info(file_path);
    return file_info.isHidden();
}

bool FileSystemHelper::isSystemFile(const QString &file_path)
{
// Windows system file detection
#ifdef Q_OS_WIN
    QFileInfo file_info(file_path);
    // Can be determined by file attributes
    return false; // Simplified implementation
#else
    return false;
#endif
}
