import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import EUI
import ".."

// ========== Center Content Area ==========
Rectangle {
    id: root
    color: EUITheme.colorBg

    // File drag and drop area
    FileDropArea {
        anchors.fill: parent
        onFilesDropped: (filePaths) => {
            var maxCount = 4096;
            var hasFolder = false;
            var totalFileCount = 0;
            
            // Check if any path is a folder and calculate total file count
            for (var i = 0; i < filePaths.length; i++) {
                var fileCount = mainController.getFolderFileCount(filePaths[i], true);
                if (fileCount > 0) {
                    // This is a folder
                    hasFolder = true;
                    totalFileCount += fileCount;
                } else {
                    // This is a file
                    totalFileCount++;
                }
            }
            
            // If total file count exceeds limit, show warning
            if (totalFileCount >= 4000) {
                limitWarningDialog.operationType = hasFolder ? "drop_folder" : "files";
                limitWarningDialog.totalCount = totalFileCount;
                limitWarningDialog.limitCount = maxCount;
                limitWarningDialog.pendingPaths = filePaths;
                limitWarningDialog.open();
            } else {
                mainController.addFiles(filePaths);
            }
        }
    }

    // Left divider
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: EUITheme.colorDivider
    }

    // Right divider
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: EUITheme.colorDivider
    }

    // File selection dialog
    FileDialog {
        id: fileDialog
        title: I18n.tr("CenterPanel", "Select Files")
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            // Note: Accessing selectedFiles property triggers QML to construct entire file array
            var paths = [];
            var maxCount = 4096;  // Matches C++'s MAX_FILE_COUNT
            var totalFiles = selectedFiles.length;
            var count = Math.min(totalFiles, maxCount);
            
            for (var i = 0; i < count; i++) {
                var path = selectedFiles[i].toString();
                if (path.startsWith("file:///")) {
                    path = path.substring(8);
                }
                paths.push(path);
            }
            
            // If exceeds limit, show warning dialog
            if (totalFiles >= 4000) {
                limitWarningDialog.operationType = "files";
                limitWarningDialog.totalCount = totalFiles;
                limitWarningDialog.limitCount = maxCount;
                limitWarningDialog.pendingPaths = paths;
                limitWarningDialog.open();
            } else {
                mainController.addFiles(paths);
            }
        }
    }
    
    // Unified file count limit warning dialog
    EDialog {
        id: limitWarningDialog
        
        property int totalCount: 0
        property int limitCount: 4096
        property string operationType: "files"  // "files", "folder", or "drop_folder"
        property var pendingPaths: []           // For files and drop_folder
        property string folderPath: ""          // For folder
        
        implicitWidth: 520
        
        // IMPORTANT: Add I18n.version dependency to re-evaluate on language change
        title: {
            var v = I18n.version; // Establish binding dependency
            return "⚠️ " + I18n.tr("CenterPanel", "File Count Limit Warning");
        }
        
        message: {
            var v = I18n.version; // Establish binding dependency
            if (operationType === "folder" || operationType === "drop_folder") {
                return I18n.tr("CenterPanel", "The selected folder contains %1 files, which exceeds the maximum limit.")
                    .arg(totalCount) + "\n\n" +
                    "• " + I18n.tr("CenterPanel", "Only the first %1 files will be added").arg(limitCount) + "\n" +
                    "• " + I18n.tr("CenterPanel", "The program may freeze for 1-2 seconds during processing") + "\n\n" +
                    I18n.tr("CenterPanel", "Do you want to continue?");
            } else {
                return I18n.tr("CenterPanel", "You have selected %1 files, which exceeds the maximum limit.")
                    .arg(totalCount) + "\n\n" +
                    "• " + I18n.tr("CenterPanel", "Only the first %1 files will be added").arg(limitCount) + "\n" +
                    "• " + I18n.tr("CenterPanel", "The program may freeze for 1-2 seconds during processing") + "\n\n" +
                    I18n.tr("CenterPanel", "Do you want to continue?");
            }
        }
        
        confirmText: I18n.tr("CenterPanel", "Continue Anyway")
        cancelText: I18n.tr("CenterPanel", "Cancel")
        showCancel: true
        
        onConfirmed: {
            if (operationType === "folder") {
                mainController.addFolder(folderPath, true);
            } else {
                // For "files" and "drop_folder" types, use addFiles
                mainController.addFiles(pendingPaths);
            }
        }
        
        onCancelled: {
            if (operationType === "files") {
                pendingPaths = [];
            }
        }
    }

    // Folder selection dialog
    FolderDialog {
        id: folderDialog
        title: I18n.tr("CenterPanel", "Select Folder (Recursive)")
        onAccepted: {
            var path = selectedFolder.toString();
            if (path.startsWith("file:///")) {
                path = path.substring(8);
            }
            console.log("[FolderDialog] Selected folder:", path);
            
            // Pre-scan folder to get file count
            var fileCount = mainController.getFolderFileCount(path, true);
            console.log("[FolderDialog] Folder contains file count:", fileCount);
            
            if (fileCount >= 4000) {
                limitWarningDialog.operationType = "folder";
                limitWarningDialog.folderPath = path;
                limitWarningDialog.totalCount = fileCount;
                limitWarningDialog.limitCount = 4096;
                limitWarningDialog.open();
            } else {
                mainController.addFolder(path, true);
            }
        }
    }

    // Main content area - fills entire space
    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        color: "transparent"

        Column {
            anchors.fill: parent
            spacing: 0

            // ========== Top Toolbar ==========
            CenterToolbar {
                width: parent.width
                canUndo: mainController.fileService.canUndo
                onAddFilesClicked: fileDialog.open()
                onAddFolderClicked: folderDialog.open()
                onClearListClicked: mainController.clearFiles()
                onUndoClicked: {
                    var response = mainController.undo();
                    if (!response.success) {
                        console.error("Undo failed:", response.message);
                    }
                }
            }

            // ========== File List Area ==========
            Rectangle {
                width: parent.width
                height: parent.height - 64 - 60
                color: EUITheme.colorCard
                
                // Empty state
                EmptyState {
                    visible: fileListModel.totalCount === 0
                }
                
                // File list - efficient rendering using ListView
                ListView {
                    id: fileListView
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingL
                    anchors.bottomMargin: 60  // Leave space for pagination controls
                    visible: fileListModel.totalCount > 0
                    
                    model: fileListModel
                    clip: true
                    
                    // Scrollbar
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    
                    // List header
                    header: FileListHeader {
                        width: fileListView.width
                        listWidth: fileListView.width
                        selectedCount: fileListModel.selectedCount
                        totalCount: fileListModel.totalCount
                        onSelectAllToggled: {
                            if (fileListModel.selectedCount === fileListModel.totalCount) {
                                fileListModel.clearSelection();
                            } else {
                                fileListModel.selectAll();
                            }
                        }
                    }
                    
                    // List item delegate
                    delegate: FileListItem {
                        width: fileListView.width
                        listWidth: fileListView.width
                        isSelected: model.isSelected
                        fileIndex: model.fileIndex
                        originalName: model.originalName
                        newName: model.newName
                        hasError: model.hasError
                        executionStatus: model.executionStatus
                        executionStatusText: model.executionStatusText
                        onItemClicked: fileListModel.toggleSelection(index)
                        onItemRightClicked: (mouseX, mouseY) => {
                            // Use global index (fileIndex is 1-based, convert to 0-based)
                            contextMenuWrapper.currentIndex = model.fileIndex - 1
                            contextMenu.popup()
                        }
                    }
                }
                
                // ========== Pagination Controls ==========
                FileListPagination {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: EUITheme.spacingL
                    visible: fileListModel.totalCount > 0
                    
                    totalCount: fileListModel.totalCount
                    currentPage: fileListModel.currentPage
                    totalPages: fileListModel.totalPages
                    
                    onPreviousPageClicked: fileListModel.previousPage()
                    onNextPageClicked: fileListModel.nextPage()
                    onGoToPageClicked: (page) => fileListModel.goToPage(page)
                }
            }

                // ========== Bottom Execution Area ==========
                Rectangle {
                    width: parent.width
                    height: 60
                    color: EUITheme.colorMutedBg
                    
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: EUITheme.colorDivider
                    }

                    // Wrapper to enable ToolTip even when button is disabled
                    Item {
                        id: executeButtonWrapper
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: EUITheme.spacingL
                        width: executeButton.implicitWidth
                        height: executeButton.implicitHeight

                        EButton {
                            id: executeButton
                            anchors.fill: parent

                            buttonType: EButton.ButtonType.Primary
                            text: I18n.tr("CenterPanel", "Execute")

                            implicitWidth: 120
                            enabled: fileListModel.totalCount > 0 &&
                                     fileListModel.selectedCount > 0 &&
                                     mainController.ruleEngine.ruleCount > 0

                            onClicked: {
                                mainController.execute();
                            }
                        }

                        // Hover layer: captures mouse when button is disabled to show ToolTip
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            visible: !executeButton.enabled

                            ToolTip.visible: containsMouse
                            ToolTip.delay: 400
                            ToolTip.text: {
                                var v = I18n.version
                                if (fileListModel.totalCount === 0)
                                    return I18n.tr("CenterPanel", "Please add at least one file first")
                                if (fileListModel.selectedCount === 0)
                                    return I18n.tr("CenterPanel", "Please select at least one file")
                                if (mainController.ruleEngine.ruleCount === 0)
                                    return I18n.tr("CenterPanel", "Please add at least one rule first")
                                return ""
                            }
                        }
                    }
                }
        }
    }
    
    // Context menu wrapper
    Item {
        id: contextMenuWrapper
        property int currentIndex: -1
        
        EPopupMenu {
            id: contextMenu
            
            menuItems: [
                {
                    icon: "",
                    text: I18n.tr("CenterPanel", "Open File Location"),
                    action: function() {
                        if (contextMenuWrapper.currentIndex >= 0) {
                            var response = mainController.openFileLocation(contextMenuWrapper.currentIndex)
                            if (!response.success) {
                                console.error("Failed to open file location:", response.message)
                            }
                        }
                    }
                },
                {
                    icon: "",
                    text: I18n.tr("CenterPanel", "Remove from List"),
                    action: function() {
                        if (contextMenuWrapper.currentIndex >= 0) {
                            console.log("[ContextMenu] Removing file at index:", contextMenuWrapper.currentIndex)
                            var response = mainController.removeFiles([contextMenuWrapper.currentIndex])
                            console.log("[ContextMenu] Remove response:", response.success, response.message)
                        }
                    }
                }
            ]
        }
    }
    
}
