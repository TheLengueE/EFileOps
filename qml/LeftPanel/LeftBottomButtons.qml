import QtQuick
import QtQuick.Controls
import EUI
import ".."

// Left panel bottom buttons component
Rectangle {
    id: root
    width: parent.width
    height: contentColumn.implicitHeight + EUITheme.spacingM * 2 + 1
    color: "transparent"

    signal settingsClicked()
    signal aboutClicked()

    // Top divider line
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: EUITheme.colorDivider
    }

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: EUITheme.spacingM + 1
        anchors.leftMargin: EUITheme.spacingL
        anchors.rightMargin: EUITheme.spacingL
        anchors.bottomMargin: EUITheme.spacingM
        spacing: EUITheme.spacingS

        // Settings button
        Rectangle {
            width: parent.width
            height: 40
            color: settingsMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusSmall

            IconImage {
                source: "../../icons/settings.svg"
                width: 24
                height: 24
                anchors.centerIn: parent
                color: "#3B82F6"
                opacity: settingsMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.settingsClicked()
            }
            
            ToolTip {
                visible: settingsMouseArea.containsMouse
                text: I18n.tr("LeftPanel", "Settings")
                delay: 500
            }
        }

        // About button
        Rectangle {
            width: parent.width
            height: 40
            color: aboutMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
            radius: EUITheme.radiusSmall

            IconImage {
                source: "../../icons/info.svg"
                width: 24
                height: 24
                anchors.centerIn: parent
                color: "#3B82F6"
                opacity: aboutMouseArea.containsMouse ? 1.0 : 0.8
            }

            MouseArea {
                id: aboutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.aboutClicked()
            }
            
            ToolTip {
                visible: aboutMouseArea.containsMouse
                text: I18n.tr("LeftPanel", "About")
                delay: 500
            }
        }
    }
}
