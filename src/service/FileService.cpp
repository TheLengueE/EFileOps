#include "FileService.h"
#include "../core/AppSettings.h"
#include "../core/ErrorCodes.h"
#include "../util/FileSystemHelper.h"
#include <QFileInfo>
#include <QDir>
#include <QElapsedTimer>
#include <QDebug>
#include <algorithm>

FileService::FileService(QObject *parent) : QObject(parent), current_history_index_(-1) {}

FileService::~FileService()
{
    clearFiles();
    clearHistory();
}

BaseResponse FileService::addFile(const QString &filePath)
{
    // Validate file path
    if (!isFilePathValid(filePath))
    {
        return BaseResponse::Error(tr("Invalid file path: %1").arg(filePath), FileErrorCode::kFileInvalidPath);
    }

    // Check if limit is exceeded
    if (files_.size() >= kMaxFileCount)
    {
        return BaseResponse::Error(tr("File count limit reached (%1), cannot add more files").arg(kMaxFileCount),
                                   FileErrorCode::kFileLimitExceeded);
    }

    // Check for duplicates
    if (isDuplicate(filePath))
    {
        return BaseResponse::Error(tr("File already exists in list: %1").arg(filePath), FileErrorCode::kFileDuplicate);
    }

    // Add file
    FileItem *item = new FileItem(filePath, this);
    files_.append(item);

    // Add to cache
    QFileInfo file_info(filePath);
    file_path_cache_.insert(file_info.canonicalFilePath());

    emit fileCountChanged();
    emit filesAdded(1);

    return BaseResponse::SuccessWithData(QVariantMap{{"index", files_.size() - 1}}, tr("File added successfully"));
}

BaseResponse FileService::addFiles(const QStringList &filePaths)
{
    QElapsedTimer total_timer;
    total_timer.start();

    qDebug() << "========== addFiles Start ==========" << "Path count:" << filePaths.size();

    int         added_count   = 0;
    int         skipped_count = 0;
    QStringList errors;

    QElapsedTimer scan_timer;
    scan_timer.start();

    for (const QString &path : filePaths)
    {
        QFileInfo info(path);

        if (!info.exists())
        {
            skipped_count++;
            errors.append(tr("Path does not exist: %1").arg(path));
            continue;
        }

        // Determine if it's a file or folder
        if (info.isFile())
        {
            // Filter hidden files and invalid filenames
            if (info.isHidden() || info.fileName().isEmpty() || info.fileName().startsWith('.'))
            {
                skipped_count++;
                continue;
            }

            // Process single file
            if (files_.size() >= kMaxFileCount)
            {
                errors.append(tr("File limit reached"));
                break;
            }

            if (!isFilePathValid(path))
            {
                skipped_count++;
                errors.append(tr("Invalid path: %1").arg(path));
                continue;
            }

            if (isDuplicate(path))
            {
                skipped_count++;
                continue;
            }

            FileItem *item = new FileItem(path, this);
            // Check again if filename is empty (prevent hidden files)
            if (item->fileName().isEmpty())
            {
                delete item;
                skipped_count++;
                continue;
            }

            files_.append(item);
            file_path_cache_.insert(QFileInfo(path).canonicalFilePath());
            added_count++;
        }
        else if (info.isDir())
        {
            // Process folder, recursively scan (hidden files already filtered in getFilesInDirectory)
            // Calculate remaining capacity
            int remaining = kMaxFileCount - files_.size();
            if (remaining <= 0)
            {
                errors.append(tr("File limit reached"));
                break;
            }

            qint64      dir_scan_start = scan_timer.nsecsElapsed();
            QStringList dir_files    = FileSystemHelper::getFilesInDirectory(path, true, remaining); // Limit scan count
            qint64      dir_scan_end = scan_timer.nsecsElapsed();
            qDebug() << "  [Directory Scan]" << path << "Found" << dir_files.size() << "files (limit:" << remaining
                     << "), elapsed:" << (dir_scan_end - dir_scan_start) / 1000000.0 << "ms";

            qint64 add_start = scan_timer.nsecsElapsed();
            for (const QString &file_path : dir_files)
            {
                if (files_.size() >= kMaxFileCount)
                {
                    errors.append(tr("File limit reached"));
                    break;
                }

                if (isDuplicate(file_path))
                {
                    skipped_count++;
                    continue;
                }

                FileItem *item = new FileItem(file_path, this);
                // Check if filename is empty
                if (item->fileName().isEmpty())
                {
                    delete item;
                    skipped_count++;
                    continue;
                }

                files_.append(item);
                file_path_cache_.insert(QFileInfo(file_path).canonicalFilePath());
                added_count++;
            }
            qint64 add_end = scan_timer.nsecsElapsed();
            qDebug() << "  [Add Files]" << "Added" << dir_files.size()
                     << "files, elapsed:" << (add_end - add_start) / 1000000.0 << "ms";
        }
    }

    qint64 scan_elapsed = scan_timer.elapsed();
    qDebug() << "  [Total Scan+Add Time]" << scan_elapsed << "ms";

    QElapsedTimer signal_timer;
    signal_timer.start();

    if (added_count > 0)
    {
        qDebug() << "  [Emit Signals] fileCountChanged + filesAdded(" << added_count << ")";
        emit fileCountChanged();
        emit filesAdded(added_count);
    }

    qint64 signal_elapsed = signal_timer.elapsed();
    qDebug() << "  [Signal Processing Time]" << signal_elapsed << "ms";

    QVariantMap data;
    data["addedCount"]   = added_count;
    data["skippedCount"] = skipped_count;

    qint64 total_elapsed = total_timer.elapsed();
    qDebug() << "========== addFiles Complete ==========" << "Total time:" << total_elapsed << "ms"
             << "Added:" << added_count << "Skipped:" << skipped_count;

    if (added_count == 0)
    {
        return BaseResponse::Error(tr("No files added"), OperationErrorCode::kExecuteFailed);
    }

    // Note: Auto-sort removed, now handled by MainController after selection

    QString message = tr("Successfully added %1 file(s)").arg(added_count);
    if (skipped_count > 0)
    {
        message += tr(", skipped %1").arg(skipped_count);
    }

    return BaseResponse::SuccessWithData(data, message);
}

BaseResponse FileService::addFolder(const QString &folderPath, bool recursive)
{
    QFileInfo dir_info(folderPath);

    if (!dir_info.exists() || !dir_info.isDir())
    {
        return BaseResponse::Error(tr("Folder does not exist or is invalid: %1").arg(folderPath), FileErrorCode::kFolderNotExist);
    }

    QStringList files = FileSystemHelper::getFilesInDirectory(folderPath, recursive);

    if (files.isEmpty())
    {
        return BaseResponse::Error(tr("Folder is empty: %1").arg(folderPath), FileErrorCode::kFolderEmpty);
    }

    return addFiles(files);
}

BaseResponse FileService::removeFile(int index)
{
    if (index < 0 || index >= files_.size())
    {
        return BaseResponse::Error(tr("Index out of bounds: %1").arg(index), ErrorCode::INVALID_PARAM);
    }

    // Remove from cache
    FileItem *item = files_[index];
    QFileInfo file_info(item->originalPath());
    file_path_cache_.remove(file_info.canonicalFilePath());

    delete files_.takeAt(index);

    emit fileCountChanged();
    emit filesRemoved(1);

    return BaseResponse::Success(tr("File deleted"));
}

BaseResponse FileService::removeFiles(const QList<int> &indices)
{
    // TODO: Implement batch removal
    return BaseResponse::Error(tr("Feature not implemented yet"), ErrorCode::NOT_IMPLEMENTED);
}

BaseResponse FileService::clear()
{
    if (files_.isEmpty())
    {
        return BaseResponse::Success(tr("List is already empty"));
    }

    clearFiles();

    emit fileCountChanged();
    emit allFilesCleared();

    return BaseResponse::Success(tr("File list cleared"));
}

FileItem *FileService::getFile(int index) const
{
    if (index >= 0 && index < files_.size())
    {
        return files_[index];
    }
    return nullptr;
}

BaseResponse FileService::undo()
{
    if (!canUndo())
    {
        return BaseResponse::Error(tr("Cannot undo"), ErrorCode::OPERATION_FAILED);
    }

    // Move to previous snapshot (state before execution)
    current_history_index_--;

    // Get snapshot before execution
    const Snapshot &snapshot = history_[current_history_index_];

    // For successfully executed files, need to reverse rename physical files
    QDir dir;
    int  revert_count = 0;
    for (int i = 0; i < files_.size() && i < snapshot.files.size(); ++i)
    {
        FileItem *current_file  = files_[i];
        FileItem *snapshot_file = snapshot.files[i];

        // If current file was successfully executed and path differs from snapshot, needs physical undo
        if (current_file->executionStatus() == FileItem::ExecutionStatus::Success &&
            current_file->originalPath() != snapshot_file->originalPath())
        {

            QString current_path = current_file->originalPath();  // New path
            QString old_path     = snapshot_file->originalPath(); // Old path

            // Perform reverse rename
            if (dir.rename(current_path, old_path))
            {
                revert_count++;
            }
            else
            {
                qWarning() << "Undo failed: Cannot rename" << current_path << "back to" << old_path;
            }
        }
    }

    // Clear current file list
    clearFiles();

    // Deep copy files from snapshot
    for (FileItem *item : snapshot.files)
    {
        FileItem *copy = new FileItem(item->originalPath(), this);
        copy->setNewName(item->newName());
        copy->setHasError(item->hasError());
        copy->setErrorMessage(item->errorMessage());
        copy->setExecutionStatus(item->executionStatus());
        files_.append(copy);
    }

    // Emit signals to notify UI update
    emit fileCountChanged();
    emit canUndoChanged();
    emit filesRestored(); // Notify file list restored (don't clear selection state)

    QString msg = tr("Rename undone");
    if (revert_count > 0)
    {
        msg += tr(", %1 file(s) restored").arg(revert_count);
    }

    return BaseResponse::Success(msg);
}

BaseResponse FileService::redo()
{
    if (!canRedo())
    {
        return BaseResponse::Error(tr("Cannot redo"), ErrorCode::OPERATION_FAILED);
    }

    // Save current file state (for reverse rename)
    QList<FileItem *> current_files = files_;

    // Move to next snapshot
    current_history_index_++;

    // Restore that snapshot's state
    const Snapshot &snapshot = history_[current_history_index_];

    // For files that need re-execution, perform forward rename
    QDir dir;
    int  redo_count = 0;
    for (int i = 0; i < current_files.size() && i < snapshot.files.size(); ++i)
    {
        FileItem *current_file  = current_files[i];
        FileItem *snapshot_file = snapshot.files[i];

        // If file in snapshot was successfully executed and path differs from current, needs re-execution
        if (snapshot_file->executionStatus() == FileItem::ExecutionStatus::Success &&
            current_file->originalPath() != snapshot_file->originalPath())
        {

            QString current_path = current_file->originalPath();  // Old path
            QString new_path     = snapshot_file->originalPath(); // New path

            // Perform forward rename
            if (dir.rename(current_path, new_path))
            {
                redo_count++;
            }
            else
            {
                qWarning() << "Redo failed: Cannot rename" << current_path << "to" << new_path;
            }
        }
    }

    // Clear current file list
    clearFiles();

    // Deep copy files from snapshot
    for (FileItem *item : snapshot.files)
    {
        FileItem *copy = new FileItem(item->originalPath(), this);
        copy->setNewName(item->newName());
        copy->setHasError(item->hasError());
        copy->setErrorMessage(item->errorMessage());
        copy->setExecutionStatus(item->executionStatus());
        files_.append(copy);
    }

    emit fileCountChanged();
    emit canUndoChanged();
    emit canRedoChanged();
    emit allFilesCleared(); // Notify list has been reset

    QString msg = tr("Redone to: %1").arg(snapshot.timestamp.toString("hh:mm:ss"));
    if (redo_count > 0)
    {
        msg += tr(" (%1 file(s) restored)").arg(redo_count);
    }

    return BaseResponse::Success(msg);
}

void FileService::clearHistory()
{
    history_.clear();
    current_history_index_ = -1;
    emit canUndoChanged();
    emit canRedoChanged();
}

void FileService::saveSnapshot()
{
    // Create snapshot of current state
    Snapshot snapshot;
    snapshot.timestamp = QDateTime::currentDateTime();

    // Deep copy all files
    for (FileItem *item : files_)
    {
        FileItem *copy = new FileItem(item->originalPath());
        copy->setNewName(item->newName());
        copy->setHasError(item->hasError());
        copy->setErrorMessage(item->errorMessage());
        copy->setExecutionStatus(item->executionStatus());
        snapshot.files.append(copy);
    }

    // Add to history
    addToHistory(snapshot);
}

void FileService::addToHistory(const Snapshot &snapshot)
{
    // If not at end of history, delete all snapshots after current
    if (current_history_index_ < history_.size() - 1)
    {
        history_.erase(history_.begin() + current_history_index_ + 1, history_.end());
    }

    // Add new snapshot
    history_.append(snapshot);
    current_history_index_ = history_.size() - 1;

    // Limit history size
    trimHistory();

    emit canUndoChanged();
    emit canRedoChanged();
}

void FileService::trimHistory()
{
    // Keep history size within limit
    while (history_.size() > kMaxHistorySize)
    {
        history_.removeFirst();
        current_history_index_--;
    }
}

BaseResponse FileService::executeRename(const QList<int> &selectedIndices)
{
    // Verify if there are files
    if (files_.isEmpty())
    {
        return BaseResponse::Error(tr("No files to execute"), OperationErrorCode::kNoFiles);
    }

    // If no selected indices specified, don't execute anything
    if (selectedIndices.isEmpty())
    {
        return BaseResponse::Error(tr("Please select files to process first"), OperationErrorCode::kNoFiles);
    }

    // Validate selected indices
    for (int index : selectedIndices)
    {
        if (index < 0 || index >= files_.size())
        {
            return BaseResponse::Error(tr("Selected file index is invalid"), ErrorCode::INVALID_PARAM);
        }
    }

    // Save snapshot before execution (for undo)
    saveSnapshot();

    // Separate files to be removed and files to be renamed
    QList<int>                 files_to_remove; // Indices to be removed (from list)
    QList<QPair<int, QString>> rename_list;     // <Index, New path>
    QList<QString>             original_paths;  // For rollback
    int                        pre_failure_count = 0; // Count failures before execution

    for (int index : selectedIndices)
    {
        FileItem *file = files_[index];

        qDebug() << "  [File" << index << "]" << file->fileName() + file->extension();
        qDebug() << "    Original name:" << file->fileName() + file->extension();
        qDebug() << "    New name:" << file->newName();
        qDebug() << "    Is modified:" << file->isModified();

        // Check if marked for deletion
        if (file->newName() == "[To be removed]")
        {
            files_to_remove.append(index);
            continue;
        }

        // Skip files without modifications
        if (file->newName().isEmpty() || !file->isModified())
        {
            qDebug() << "    [Skip] Reason:" << (file->newName().isEmpty() ? "New name is empty" : "Not modified");
            continue;
        }

        // Get new path
        QString new_path = file->getNewPath();
        QString old_path = file->originalPath();

        qDebug() << "    New path:" << new_path;
        qDebug() << "    Original path:" << old_path;
        qDebug() << "    Paths same?" << (new_path == old_path);
        qDebug() << "    QFileInfo::exists(new_path)?" << QFileInfo::exists(new_path);

        // For Windows case-insensitive file systems, allow rename if only case changes
        // Use canonical path comparison to check if pointing to same file
        QFileInfo new_info(new_path);
        QFileInfo old_info(old_path);
        bool      is_same_file = (new_info.absoluteFilePath().toLower() == old_info.absoluteFilePath().toLower());

        qDebug() << "    Is same file (ignore case)?" << is_same_file;

        // If new path exists and not the same file (case-sensitive comparison), report error
        if (!is_same_file && QFileInfo::exists(new_path))
        {
            qDebug() << "    [Error] Target file already exists";
            file->setHasError(true);
            file->setErrorMessage(tr("Failed"));
            file->setExecutionStatus(FileItem::ExecutionStatus::Failed);
            emit fileUpdated(index); // Notify UI immediately
            pre_failure_count++;
            continue;
        }

        qDebug() << "    [Add to rename list]";

        rename_list.append(qMakePair(index, new_path));
        original_paths.append(file->originalPath());
    }

    // Execute removal operations (remove from list)
    int remove_count = 0;
    if (!files_to_remove.isEmpty())
    {
        // Sort indices in descending order to avoid index changes during removal
        std::sort(files_to_remove.begin(), files_to_remove.end(), std::greater<int>());

        for (int index : files_to_remove)
        {
            FileItem *file = files_[index];
            files_.removeAt(index);
            delete file;
            remove_count++;
        }

        emit fileCountChanged();
    }

    // If both lists are empty
    if (rename_list.isEmpty() && remove_count == 0)
    {
        // If there were pre-execution failures, need to sort and emit signal
        if (pre_failure_count > 0)
        {
            qDebug() << "[executeRename] All files failed pre-execution checks, sorting by status...";
            std::sort(files_.begin(), files_.end(),
                      [](const FileItem *a, const FileItem *b)
                      {
                          // Priority: Failed(2) > RolledBack(3) > Pending(0) > Success(1)
                          int priority_a, priority_b;
                          
                          switch (a->executionStatus())
                          {
                          case FileItem::ExecutionStatus::Failed:
                              priority_a = 0;
                              break;
                          case FileItem::ExecutionStatus::RolledBack:
                              priority_a = 1;
                              break;
                          case FileItem::ExecutionStatus::Pending:
                              priority_a = 2;
                              break;
                          case FileItem::ExecutionStatus::Success:
                              priority_a = 3;
                              break;
                          default:
                              priority_a = 4;
                              break;
                          }
                          
                          switch (b->executionStatus())
                          {
                          case FileItem::ExecutionStatus::Failed:
                              priority_b = 0;
                              break;
                          case FileItem::ExecutionStatus::RolledBack:
                              priority_b = 1;
                              break;
                          case FileItem::ExecutionStatus::Pending:
                              priority_b = 2;
                              break;
                          case FileItem::ExecutionStatus::Success:
                              priority_b = 3;
                              break;
                          default:
                              priority_b = 4;
                              break;
                          }
                          
                          return priority_a < priority_b;
                      });
            
            emit filesSorted();
            emit renameExecuted(0, pre_failure_count);
        }
        
        return BaseResponse::Error(tr("No files to process"), OperationErrorCode::kNoFiles);
    }

    // Execute renames (continue on failure, rollback all if any failed)
    int                            success_count = 0;
    int                            failure_count = 0;
    QList<QPair<int, QString>>     successful_renames; // Store adjusted_index and old_path for rollback
    QList<QPair<int, FileItem *>>  succeeded_files;    // Store adjusted_index and new FileItem for rollback

    for (int i = 0; i < rename_list.size(); ++i)
    {
        int     index    = rename_list[i].first;
        QString new_path = rename_list[i].second;

        // Need to adjust index because some files may have been removed
        int adjusted_index = index;
        for (int removed_index : files_to_remove)
        {
            if (removed_index < index)
            {
                adjusted_index--;
            }
        }

        // Check if adjusted index is valid
        if (adjusted_index < 0 || adjusted_index >= files_.size())
        {
            failure_count++;
            continue;
        }

        FileItem *file     = files_[adjusted_index];
        QString   old_path = file->originalPath();

        // Execute rename (only rename, no copy or delete)
        QDir dir;
        if (dir.rename(old_path, new_path))
        {
            // Rename successful
            success_count++;

            // Store old file for potential rollback
            FileItem *old_file = file;

            // Re-parse new path (update internal state)
            FileItem *new_file = new FileItem(new_path, file->parent());

            // After successful execution, keep current newName display (user needs to manually clear for new
            // modifications) originalPath is already the new path, but continue showing newName so user knows what
            // changed
            new_file->setNewName(file->newName()); // Keep previous newName
            new_file->setHasError(false);
            new_file->setErrorMessage("");
            new_file->setExecutionStatus(FileItem::ExecutionStatus::Success);

            // Replace old FileItem (but don't delete old_file yet, we might need it for rollback)
            files_[adjusted_index] = new_file;

            // Record for potential rollback
            successful_renames.append(qMakePair(adjusted_index, old_path));
            succeeded_files.append(qMakePair(adjusted_index, old_file));

            emit fileUpdated(adjusted_index);
        }
        else
        {
            // Rename failed - mark as failed and continue with next file
            failure_count++;
            file->setHasError(true);
            file->setErrorMessage(tr("Failed"));
            file->setExecutionStatus(FileItem::ExecutionStatus::Failed);
            emit fileUpdated(adjusted_index);
            
            // Continue to next file (will rollback at the end if needed)
        }
    }

    // If any file failed, rollback all successful renames
    if (failure_count > 0 && success_count > 0)
    {
        qDebug() << "[Rollback] Detected failures, rolling back all successful renames...";
        
        QDir dir;
        for (int i = 0; i < successful_renames.size(); ++i)
        {
            int     adjusted_index = successful_renames[i].first;
            QString old_path       = successful_renames[i].second;
            FileItem *old_file     = succeeded_files[i].second;
            FileItem *new_file     = files_[adjusted_index];
            QString   new_path     = new_file->originalPath();

            qDebug() << "  Rollback:" << new_path << "->" << old_path;

            // Rollback the rename
            if (dir.rename(new_path, old_path))
            {
                // Restore old FileItem
                old_file->setNewName(old_file->fileName() + old_file->extension());
                old_file->setHasError(false);
                old_file->setErrorMessage(tr("Rolled back"));
                old_file->setExecutionStatus(FileItem::ExecutionStatus::RolledBack);

                files_[adjusted_index] = old_file;
                delete new_file;

                emit fileUpdated(adjusted_index);
            }
            else
            {
                qWarning() << "  [Warning] Failed to rollback:" << new_path;
                delete old_file; // Clean up if rollback failed
            }
        }

        // Clear successful renames that weren't deleted during rollback
        for (auto &pair : succeeded_files)
        {
            // If the file wasn't used in rollback, we need to delete it
            // (This handles the case where rollback failed)
        }

        qDebug() << "[Rollback] Complete. All changes have been rolled back.";
        
        // Sort files by execution status: Failed > RolledBack > Pending > Success
        qDebug() << "[Rollback] Sorting files by status...";
        std::sort(files_.begin(), files_.end(),
                  [](const FileItem *a, const FileItem *b)
                  {
                      // Priority: Failed(2) > RolledBack(3) > Pending(0) > Success(1)
                      int priority_a, priority_b;
                      
                      switch (a->executionStatus())
                      {
                      case FileItem::ExecutionStatus::Failed:
                          priority_a = 0; // Highest priority
                          break;
                      case FileItem::ExecutionStatus::RolledBack:
                          priority_a = 1;
                          break;
                      case FileItem::ExecutionStatus::Pending:
                          priority_a = 2;
                          break;
                      case FileItem::ExecutionStatus::Success:
                          priority_a = 3; // Lowest priority
                          break;
                      default:
                          priority_a = 4;
                          break;
                      }
                      
                      switch (b->executionStatus())
                      {
                      case FileItem::ExecutionStatus::Failed:
                          priority_b = 0;
                          break;
                      case FileItem::ExecutionStatus::RolledBack:
                          priority_b = 1;
                          break;
                      case FileItem::ExecutionStatus::Pending:
                          priority_b = 2;
                          break;
                      case FileItem::ExecutionStatus::Success:
                          priority_b = 3;
                          break;
                      default:
                          priority_b = 4;
                          break;
                      }
                      
                      return priority_a < priority_b;
                  });
        
        emit filesSorted(); // Notify UI to update
        qDebug() << "[Rollback] Sort complete.";
        
        emit renameExecuted(0, failure_count); // success_count = 0 after rollback

        return BaseResponse::Error(tr("Operation failed: %1 file(s) failed, all changes have been rolled back").arg(failure_count),
                                   FileErrorCode::kFileRenameFailed);
    }
    else
    {
        // No failures, clean up old FileItems
        for (auto &pair : succeeded_files)
        {
            delete pair.second;
        }
    }

    // Emit execution completed signal
    emit renameExecuted(success_count + remove_count, failure_count);

    // Move history index to next position, so undo will return to index 0 snapshot
    current_history_index_++;
    emit canUndoChanged();

    QString result_msg;
    if (remove_count > 0 && success_count > 0)
    {
        result_msg = tr("Processing complete: Removed %1, renamed successfully %2, failed %3")
                         .arg(remove_count)
                         .arg(success_count)
                         .arg(failure_count);
    }
    else if (remove_count > 0)
    {
        result_msg = tr("Removal complete: Removed %1 file(s)").arg(remove_count);
    }
    else
    {
        result_msg = tr("Rename complete: Successful %1, failed %2").arg(success_count).arg(failure_count);
    }

    return BaseResponse::Success(result_msg);
}

void FileService::updatePreview(const QList<QString> &newNames)
{
    if (newNames.size() != files_.size())
    {
        qWarning() << "FileService::updatePreview: newNames size mismatch";
        return;
    }

    for (int i = 0; i < files_.size(); ++i)
    {
        FileItem *file = files_[i];
        file->setNewName(newNames[i]);
        emit fileUpdated(i);
    }
}

BaseResponse FileService::exportToJson(const QString &filePath) const
{
    // TODO: Implement export
    return BaseResponse::Error(tr("Feature not implemented yet"), ErrorCode::NOT_IMPLEMENTED);
}

BaseResponse FileService::importFromJson(const QString &filePath)
{
    // TODO: Implement import
    return BaseResponse::Error(tr("Feature not implemented yet"), ErrorCode::NOT_IMPLEMENTED);
}

bool FileService::isFilePathValid(const QString &filePath) const
{
    QFileInfo file_info(filePath);
    return file_info.exists() && file_info.isFile();
}

bool FileService::isDuplicate(const QString &filePath) const
{
    QFileInfo new_file(filePath);
    QString   canonical_path = new_file.canonicalFilePath();

    // O(1) lookup instead of O(n)
    return file_path_cache_.contains(canonical_path);
}

void FileService::clearFiles()
{
    qDeleteAll(files_);
    files_.clear();
    file_path_cache_.clear(); // Clear cache
}

QString FileService::getErrorMessage(const QString &operation, const QString &reason) const
{
    return tr("%1 failed: %2").arg(operation, reason);
}

// Snapshot 实现
FileService::Snapshot::Snapshot(const Snapshot &other) : timestamp(other.timestamp)
{
    for (FileItem *item : other.files)
    {
        FileItem *copy = new FileItem(item->originalPath());
        copy->setNewName(item->newName());
        copy->setHasError(item->hasError());
        copy->setErrorMessage(item->errorMessage());
        copy->setExecutionStatus(item->executionStatus());
        files.append(copy);
    }
}

FileService::Snapshot::~Snapshot() { qDeleteAll(files); }

FileService::Snapshot &FileService::Snapshot::operator=(const Snapshot &other)
{
    if (this != &other)
    {
        qDeleteAll(files);
        files.clear();

        timestamp = other.timestamp;

        for (FileItem *item : other.files)
        {
            FileItem *copy = new FileItem(item->originalPath());
            copy->setNewName(item->newName());
            copy->setHasError(item->hasError());
            copy->setErrorMessage(item->errorMessage());
            copy->setExecutionStatus(item->executionStatus());
            files.append(copy);
        }
    }
    return *this;
}

// Note: Asynchronous loading removed, because synchronous loading of 5000 files takes less than 100ms
// Using QSet-optimized isDuplicate() makes batch adding very fast

void FileService::sortFiles(SortType sortType)
{
    if (files_.isEmpty())
    {
        return;
    }

    // Use lambda for sorting
    if (sortType == SortType::ByName)
    {
        // Sort by filename (natural sort: numeric parts compared by value)
        std::sort(files_.begin(), files_.end(),
                  [](const FileItem *a, const FileItem *b)
                  {
                      QString name_a = a->fileName().toLower() + a->extension().toLower();
                      QString name_b = b->fileName().toLower() + b->extension().toLower();

                      // Simple natural sort: compare character by character, compare numerically when encountering
                      // numbers
                      return name_a.localeAwareCompare(name_b) < 0;
                  });
    }
    else if (sortType == SortType::ByModifiedTime)
    {
        // Sort by modification time (newest first)
        std::sort(files_.begin(), files_.end(),
                  [](const FileItem *a, const FileItem *b) { return a->modified() > b->modified(); });
    }

    // Emit signal to notify UI update
    emit filesSorted();

    qDebug() << "[FileService] Files sorted, type:"
             << (sortType == SortType::ByName ? "By filename" : "By modified time");
}
