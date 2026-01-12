#pragma once

#include <QString>
#include <QStringList>
#include <QFileInfo>

/**
 * @brief File system helper utility class
 *
 * Provides static utility methods related to file system
 */
class FileSystemHelper
{
  public:
    // Recursively get all files in folder (supports limiting max count)
    static QStringList getFilesInDirectory(const QString &dirPath, bool recursive = false, int maxCount = -1);

    // Check if file name is valid (does not contain illegal characters)
    static bool isValidFileName(const QString &fileName);

    // Get illegal character list
    static QString getInvalidChars();

    // Clean illegal characters from file name
    static QString sanitizeFileName(const QString &fileName);

    // Check if target path has conflicting file
    static bool hasConflict(const QString &originalPath, const QString &newPath);

    // Generate unique file name (if conflict, add (1), (2) suffix)
    static QString generateUniqueName(const QString &basePath, const QString &fileName);

    // Format file size
    static QString formatFileSize(qint64 bytes);

    // Batch rename (atomic operation, either all succeed or all rollback)
    static bool batchRename(const QStringList &oldPaths, const QStringList &newPaths, QString *errorMessage = nullptr);

    // Safe rename single file
    static bool safeRename(const QString &oldPath, const QString &newPath, QString *errorMessage = nullptr);

    // File filters
    static bool isHiddenFile(const QString &filePath);
    static bool isSystemFile(const QString &filePath);

  private:
    FileSystemHelper() = delete; // Prohibit instantiation
};
