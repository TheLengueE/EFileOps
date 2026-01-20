#include "FileListModel.h"
#include "../service/FileService.h"
#include "../util/FileSystemHelper.h"
#include <QFileInfo>
#include <QElapsedTimer>
#include <QDebug>

FileListModel::FileListModel(FileService *fileService, QObject *parent)
    : QAbstractListModel(parent), file_service_(fileService)
{
    // Connect FileService signals
    connect(file_service_, &FileService::fileCountChanged, this, &FileListModel::onFileCountChanged);
    connect(file_service_, &FileService::filesAdded, this, &FileListModel::onFilesAdded);
    connect(file_service_, &FileService::filesRemoved, this, &FileListModel::onFilesRemoved);
    connect(file_service_, &FileService::filesRemovedWithIndices, this, &FileListModel::onFilesRemovedWithIndices);
    connect(file_service_, &FileService::allFilesCleared, this, &FileListModel::onAllFilesCleared);
    connect(file_service_, &FileService::filesRestored, this, &FileListModel::onFilesRestored);
    connect(file_service_, &FileService::fileUpdated, this, &FileListModel::onFileUpdated);
    connect(file_service_, &FileService::filesSorted, this, &FileListModel::onFilesSorted);
}

int FileListModel::count() const
{
    // Return file count of current page
    int total = totalCount();
    if (total == 0)
        return 0;

    int start_idx = getStartIndex();
    int end_idx   = getEndIndex();
    return end_idx - start_idx;
}

int FileListModel::totalCount() const { return file_service_ ? file_service_->fileCount() : 0; }

int FileListModel::totalPages() const
{
    int total = totalCount();
    if (total == 0 || page_size_ <= 0)
        return 1;
    return (total + page_size_ - 1) / page_size_; // Round up
}

void FileListModel::setPageSize(int size)
{
    if (size <= 0 || size == page_size_)
        return;

    beginResetModel();
    page_size_    = size;
    current_page_ = 1; // Reset to first page
    endResetModel();

    emit pageSizeChanged();
    emit currentPageChanged();
    emit totalPagesChanged();
    emit countChanged();
}

int FileListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return count(); // Only return count of current page
}

QVariant FileListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= count())
        return QVariant();

    // Convert display index to global index
    int global_index = getGlobalIndex(index.row());
    if (global_index >= file_service_->fileCount())
        return QVariant();

    FileItem *item = file_service_->getFile(global_index);
    if (!item)
        return QVariant();

    switch (role)
    {
    case IndexRole:
        return global_index + 1; // Global index starting from 1

    case OriginalNameRole:
        return item->fileName() + item->extension();

    case NewNameRole:
    {
        QString new_name = item->newName();
        return new_name.isEmpty() ? (item->fileName() + item->extension()) : new_name;
    }

    case OriginalPathRole:
        return item->originalPath();

    case FileSizeRole:
        return item->size();

    case FileSizeTextRole:
        return FileSystemHelper::formatFileSize(item->size());

    case HasErrorRole:
        return item->hasError();

    case ErrorMessageRole:
        return item->errorMessage();

    case IsSelectedRole:
        return selected_indices_.contains(global_index);

    case ExecutionStatusRole:
        return QVariant::fromValue(item->executionStatus());

    case ExecutionStatusTextRole:
    {
        switch (item->executionStatus())
        {
        case FileItem::ExecutionStatus::Pending:
            return tr("Pending");
        case FileItem::ExecutionStatus::Success:
            return tr("Success");
        case FileItem::ExecutionStatus::Failed:
            return item->errorMessage().isEmpty() ? tr("Failed") : item->errorMessage();
        case FileItem::ExecutionStatus::RolledBack:
            return item->errorMessage().isEmpty() ? tr("Rolled back") : item->errorMessage();
        }
        return tr("Unknown");
    }

    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FileListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IndexRole]               = "fileIndex";
    roles[OriginalNameRole]        = "originalName";
    roles[NewNameRole]             = "newName";
    roles[OriginalPathRole]        = "originalPath";
    roles[FileSizeRole]            = "fileSize";
    roles[FileSizeTextRole]        = "fileSizeText";
    roles[HasErrorRole]            = "hasError";
    roles[ErrorMessageRole]        = "errorMessage";
    roles[IsSelectedRole]          = "isSelected";
    roles[ExecutionStatusRole]     = "executionStatus";
    roles[ExecutionStatusTextRole] = "executionStatusText";
    return roles;
}

void FileListModel::toggleSelection(int displayIndex)
{
    if (displayIndex < 0 || displayIndex >= count())
        return;

    // Convert to global index
    int global_index = getGlobalIndex(displayIndex);
    if (global_index >= file_service_->fileCount())
        return;

    if (selected_indices_.contains(global_index))
    {
        selected_indices_.remove(global_index);
    }
    else
    {
        selected_indices_.insert(global_index);
    }

    // Notify row data change
    QModelIndex modelIndex = createIndex(displayIndex, 0);
    emit        dataChanged(modelIndex, modelIndex, {IsSelectedRole});
    emit        selectedCountChanged();
    emit        selectionChanged();
}

void FileListModel::selectAll()
{
    int total = totalCount();
    for (int i = 0; i < total; ++i)
    {
        selected_indices_.insert(i);
    }

    int page_count = count();
    if (page_count > 0)
    {
        emit dataChanged(createIndex(0, 0), createIndex(page_count - 1, 0), {IsSelectedRole});
    }
    emit selectedCountChanged();
    emit selectionChanged();
}

void FileListModel::clearSelection()
{
    if (selected_indices_.isEmpty())
        return;

    selected_indices_.clear();

    int page_count = count();
    if (page_count > 0)
    {
        emit dataChanged(createIndex(0, 0), createIndex(page_count - 1, 0), {IsSelectedRole});
    }
    emit selectedCountChanged();
    emit selectionChanged();
}

void FileListModel::selectRange(int startIndex, int endIndex)
{
    if (startIndex < 0 || endIndex > totalCount() || startIndex >= endIndex)
        return;

    for (int i = startIndex; i < endIndex; ++i)
    {
        selected_indices_.insert(i);
    }

    // If the range is on current page, notify UI update
    int page_start = getStartIndex();
    int page_end = getEndIndex();
    
    if (current_page_ == 1 && startIndex < page_end)
    {
        int display_start = qMax(0, startIndex - page_start);
        int display_end = qMin(count(), endIndex - page_start);
        if (display_start < display_end)
        {
            emit dataChanged(createIndex(display_start, 0), createIndex(display_end - 1, 0), {IsSelectedRole});
        }
    }
    
    emit selectedCountChanged();
    emit selectionChanged();
}

QList<int> FileListModel::getSelectedIndices() const
{
    QList<int> indices = selected_indices_.values();
    std::sort(indices.begin(), indices.end());
    return indices;
}

void FileListModel::onFileCountChanged()
{
    updatePagination();
    emit countChanged();
    emit totalCountChanged();
}

void FileListModel::onFilesAdded(int addedCount)
{
    QElapsedTimer timer;
    timer.start();

    qDebug() << "[FileListModel::onFilesAdded] Start processing" << addedCount << "files";

    // Synchronous add, will only trigger once, just update directly
    updatePagination();
    emit totalCountChanged();

    qint64 beforeReset = timer.elapsed();
    qDebug() << "  [Pagination update] Time:" << beforeReset << "ms";

    // Note: Auto-selection is now handled by MainController::addFiles/addFolder
    // after sorting is complete, to ensure correct indices

    // If on first page, refresh display
    if (current_page_ == 1)
    {
        qDebug() << "  [UI refresh] Start beginResetModel/endResetModel...";
        qint64 resetStart = timer.nsecsElapsed();
        beginResetModel();
        endResetModel();
        qint64 resetEnd = timer.nsecsElapsed();
        qDebug() << "  [UI refresh] Complete, time:" << (resetEnd - resetStart) / 1000000.0 << "ms";
    }

    qint64 total = timer.elapsed();
    qDebug() << "[FileListModel::onFilesAdded] Complete, total time:" << total << "ms";
}

void FileListModel::onFilesRemoved(int count)
{
    // This slot is kept for backward compatibility
    // Actual selection adjustment is done in onFilesRemovedWithIndices
    // Only update UI if filesRemovedWithIndices was not triggered
    
    qDebug() << "[FileListModel::onFilesRemoved] Removed" << count << "file(s) (fallback handler)";
    
    // Note: We don't adjust selection here because we don't know which indices were removed
    // If only this signal is triggered (old code path), we clear selection as a safe fallback
    // But the new signal filesRemovedWithIndices should be triggered instead
}

void FileListModel::onFilesRemovedWithIndices(const QList<int> &removedIndices)
{
    qDebug() << "[FileListModel::onFilesRemovedWithIndices] ========== START ==========";
    qDebug() << "  Removed indices:" << removedIndices;
    qDebug() << "  Before - Selected indices:" << selected_indices_;
    qDebug() << "  Before - Total file count:" << file_service_->fileCount() + removedIndices.size();
    
    // Adjust selection indices after removal
    // For each removed index, decrease all indices greater than it by 1
    
    QSet<int> adjusted_selection;
    
    for (int selectedIdx : selected_indices_)
    {
        qDebug() << "  Processing selected index:" << selectedIdx;
        
        // Check if this index was removed
        if (removedIndices.contains(selectedIdx))
        {
            qDebug() << "    -> This index was removed, skipping";
            // This file was removed, don't keep it in selection
            continue;
        }
        
        // Count how many removed indices are less than this selected index
        int offset = 0;
        for (int removedIdx : removedIndices)
        {
            if (removedIdx < selectedIdx)
            {
                offset++;
                qDebug() << "    -> Removed index" << removedIdx << "< selected index" << selectedIdx << ", offset now =" << offset;
            }
        }
        
        // Adjust the index by subtracting the offset
        int new_index = selectedIdx - offset;
        qDebug() << "    -> New index:" << new_index << "(offset was" << offset << ")";
        adjusted_selection.insert(new_index);
    }
    
    selected_indices_ = adjusted_selection;
    
    qDebug() << "  After - Selected indices:" << selected_indices_;
    qDebug() << "  After - Total file count:" << file_service_->fileCount();
    qDebug() << "[FileListModel::onFilesRemovedWithIndices] ========== END ==========";
    
    beginResetModel();
    endResetModel();

    updatePagination();
    emit selectedCountChanged();
    emit selectionChanged();  // Notify selection state changed
    emit totalCountChanged();
}

void FileListModel::onAllFilesCleared()
{
    beginResetModel();
    selected_indices_.clear();
    current_page_ = 1;
    endResetModel();

    emit selectedCountChanged();
    emit currentPageChanged();
    emit totalPagesChanged();
    emit countChanged();
    emit totalCountChanged();
}

void FileListModel::onFilesRestored()
{
    // Restore file list after undo/redo, refresh UI but keep selection state
    beginResetModel();
    // Note: Do not clear selected_indices_, keep user's selection state
    endResetModel();

    updatePagination();
    emit countChanged();
    emit totalCountChanged();
}

void FileListModel::onFileUpdated(int index)
{
    // Check if updated file is on current page
    int start_idx = getStartIndex();
    int end_idx   = getEndIndex();

    if (index >= start_idx && index < end_idx)
    {
        int         display_index = index - start_idx;
        QModelIndex model_index   = createIndex(display_index, 0);
        emit        dataChanged(model_index, model_index,
                                {NewNameRole, HasErrorRole, ErrorMessageRole, ExecutionStatusRole, ExecutionStatusTextRole});
    }
}

void FileListModel::onFilesSorted()
{
    qDebug() << "[FileListModel] Files sorted, preserving selection state";

    // Before sorting: save selected file pointers
    QSet<FileItem*> selected_files;
    for (int index : selected_indices_)
    {
        if (index < file_service_->fileCount())
        {
            FileItem* item = file_service_->getFile(index);
            if (item)
            {
                selected_files.insert(item);
            }
        }
    }

    // Clear old index-based selection
    selected_indices_.clear();

    // After sorting: rebuild selection based on file pointers
    for (int i = 0; i < file_service_->fileCount(); ++i)
    {
        FileItem* item = file_service_->getFile(i);
        if (item && selected_files.contains(item))
        {
            selected_indices_.insert(i);
        }
    }

    qDebug() << "  [Selection preserved]" << selected_indices_.size() << "files remain selected after sorting";

    // Reset model to refresh entire list
    beginResetModel();
    endResetModel();

    emit countChanged();
    emit selectedCountChanged();
}

// ========== 分页方法实现 ==========

void FileListModel::goToPage(int page)
{
    int total_pages_count = totalPages();
    if (page < 1 || page > total_pages_count || page == current_page_)
        return;

    beginResetModel();
    current_page_ = page;
    endResetModel();

    emit currentPageChanged();
    emit countChanged();
}

void FileListModel::nextPage()
{
    if (current_page_ < totalPages())
    {
        goToPage(current_page_ + 1);
    }
}

void FileListModel::previousPage()
{
    if (current_page_ > 1)
    {
        goToPage(current_page_ - 1);
    }
}

void FileListModel::firstPage() { goToPage(1); }

void FileListModel::lastPage() { goToPage(totalPages()); }

// ========== 私有辅助方法 ==========

int FileListModel::getGlobalIndex(int displayIndex) const { return getStartIndex() + displayIndex; }

int FileListModel::getStartIndex() const { return (current_page_ - 1) * page_size_; }

int FileListModel::getEndIndex() const
{
    int total = totalCount();
    int end   = current_page_ * page_size_;
    return qMin(end, total);
}

void FileListModel::updatePagination()
{
    int old_total_pages = totalPages();

    // If current page exceeds range, auto jump to last page
    if (current_page_ > old_total_pages && old_total_pages > 0)
    {
        current_page_ = old_total_pages;
        emit currentPageChanged();
    }

    emit totalPagesChanged();
}
