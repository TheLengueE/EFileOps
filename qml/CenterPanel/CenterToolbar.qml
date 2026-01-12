import QtQuick
import QtQuick.Controls
import EUI
import ".."

// Center panel toolbar component
Rectangle {
    id: root
    height: 64
    color: EUITheme.colorMutedBg
    
    signal addFilesClicked()
    signal addFolderClicked()
    signal clearListClicked()
    signal undoClicked()
    
    property bool canUndo: false
    
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: EUITheme.colorDivider
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: EUITheme.spacingXL
        spacing: EUITheme.spacingM

        // Add files button
        Rectangle {
            width: 84
            height: 84
            color: addFilesMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusMedium

            IconImage {
                source: "../../icons/file-plus.svg"
                width: 72
                height: 72
                anchors.centerIn: parent
                color: "#2563EB"
                opacity: addFilesMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: addFilesMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.addFilesClicked()
            }
            
            ToolTip {
                visible: addFilesMouseArea.containsMouse
                text: I18n.tr("CenterToolbar", "Add Files")
                delay: 500
            }
        }

        // Add folder button
        Rectangle {
            width: 84
            height: 84
            color: addFolderMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusMedium

            IconImage {
                source: "../../icons/folder-plus.svg"
                width: 72
                height: 72
                anchors.centerIn: parent
                color: "#2563EB"
                opacity: addFolderMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: addFolderMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.addFolderClicked()
            }
            
            ToolTip {
                visible: addFolderMouseArea.containsMouse
                text: I18n.tr("CenterToolbar", "Add Folder (Recursive)")
                delay: 500
            }
        }

        // Clear list button
        Rectangle {
            width: 84
            height: 84
            color: clearListMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusMedium

            IconImage {
                source: "../../icons/trash.svg"
                width: 72
                height: 72
                anchors.centerIn: parent
                color: "#2563EB"
                opacity: clearListMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: clearListMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clearListClicked()
            }
            
            ToolTip {
                visible: clearListMouseArea.containsMouse
                text: I18n.tr("CenterToolbar", "Clear List")
                delay: 500
            }
        }
    }
    
    // Right-side undo button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: EUITheme.spacingXL
        width: 84
        height: 84
        color: undoMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
        radius: EUITheme.radiusMedium
        opacity: root.canUndo ? 1.0 : 0.3

        IconImage {
            source: "../../icons/undo.svg"
            width: 72
            height: 72
            anchors.centerIn: parent
            color: "#2563EB"
            opacity: undoMouseArea.containsMouse ? 1.0 : 0.8
        }

        MouseArea {
            id: undoMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.canUndo ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            enabled: root.canUndo
            onClicked: root.undoClicked()
        }
        
        ToolTip {
            visible: undoMouseArea.containsMouse
            text: root.canUndo ? I18n.tr("CenterToolbar", "Undo Rename") : I18n.tr("CenterToolbar", "No Changes to Undo")
            delay: 500
        }
    }
}
