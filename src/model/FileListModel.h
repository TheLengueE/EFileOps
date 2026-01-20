#pragma once

#include <QAbstractListModel>
#include <QSet>
#include "FileItem.h"

class FileService;

/**
 * @brief File list model
 *
 * Used for efficiently displaying large number of files in QML (up to 4096)
 * Uses pagination rendering, each page displays a specified number of files
 */
class FileListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int selectedCount READ selectedCount NOTIFY selectedCountChanged)
    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)

  public:
    enum FileRoles
    {
        IndexRole = Qt::UserRole + 1, // Index
        OriginalNameRole,             // Original file name
        NewNameRole,                  // New file name (preview)
        OriginalPathRole,             // Original full path
        FileSizeRole,                 // File size (bytes)
        FileSizeTextRole,             // File size (formatted text)
        HasErrorRole,                 // Whether has error
        ErrorMessageRole,             // Error message
        IsSelectedRole,               // Whether selected
        ExecutionStatusRole,          // Execution status
        ExecutionStatusTextRole       // Execution status text
    };
    Q_ENUM(FileRoles)

    explicit FileListModel(FileService *fileService, QObject *parent = nullptr);

    // Methods required by QAbstractListModel
    int                    rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant               data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Property accessors
    int count() const;      // Current page file count
    int totalCount() const; // Total file count
    int selectedCount() const { return selected_indices_.size(); }

    // Pagination related
    int  currentPage() const { return current_page_; }
    int  totalPages() const;
    int  pageSize() const { return page_size_; }
    void setPageSize(int size);

    Q_INVOKABLE void goToPage(int page);
    Q_INVOKABLE void nextPage();
    Q_INVOKABLE void previousPage();
    Q_INVOKABLE void firstPage();
    Q_INVOKABLE void lastPage();

    // Selection related
    Q_INVOKABLE void toggleSelection(int displayIndex); // displayIndex is the display index (0-based)
    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void clearSelection();
    Q_INVOKABLE void selectRange(int startIndex, int endIndex); // Select files in range [startIndex, endIndex)
    Q_INVOKABLE QList<int> getSelectedIndices() const;

  signals:
    void countChanged();
    void totalCountChanged();
    void selectedCountChanged();
    void selectionChanged();
    void currentPageChanged();
    void totalPagesChanged();
    void pageSizeChanged();

  private slots:
    void onFileCountChanged();
    void onFilesAdded(int count);
    void onFilesRemoved(int count);
    void onFilesRemovedWithIndices(const QList<int> &removedIndices);
    void onAllFilesCleared();
    void onFilesRestored();
    void onFileUpdated(int index);
    void onFilesSorted();

  private:
    int  getGlobalIndex(int displayIndex) const; // Convert display index to global index
    int  getStartIndex() const;                  // Get start index of current page
    int  getEndIndex() const;                    // Get end index of current page
    void updatePagination();                     // Update pagination information

  private:
    FileService *file_service_;
    QSet<int>    selected_indices_; // Selected file indices (global indices)

    // Pagination related
    int current_page_ = 1;   // Current page (starts from 1)
    int page_size_    = 100; // Number of items per page, default 100
};
