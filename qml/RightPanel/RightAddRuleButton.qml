import QtQuick
import QtQuick.Controls
import EUI
import ".."

// Right panel add rule button component
Rectangle {
    id: root
    width: parent.width
    height: 64
    color: EUITheme.colorMutedBg

    signal addRuleClicked()

    // Bottom divider line
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: EUITheme.colorDivider
    }

    // Add rule button (Icon button)
    Rectangle {
        anchors.centerIn: parent
        width: 64
        height: 64
        color: addRuleMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.15) : "transparent"
        radius: EUITheme.radiusMedium

        IconImage {
            source: "../../icons/plus.svg"
            width: 56
            height: 56
            sourceSize: Qt.size(56, 56)
            color: "#1E40AF"
            anchors.centerIn: parent
            opacity: addRuleMouseArea.containsMouse ? 1.0 : 0.8
        }

        MouseArea {
            id: addRuleMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.addRuleClicked()
        }
        
        ToolTip {
            visible: addRuleMouseArea.containsMouse
            text: I18n.tr("RightPanel", "Add Rule")
            delay: 500
        }
    }
}
