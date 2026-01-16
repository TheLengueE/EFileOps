import QtQuick
import QtQuick.Controls
import EUI
import ".."

// Right panel rule list component
Rectangle {
    id: root
    color: EUITheme.colorCard

    signal ruleDeleted(int index)
    signal ruleDoubleClicked(int index)
    signal ruleMoveUp(int index)
    signal ruleMoveDown(int index)

    property alias model: ruleListView.model
    property alias count: ruleListView.count

    // Empty state hint
    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width - EUITheme.spacingXL * 2, 300)
        spacing: EUITheme.spacingS
        visible: ruleListView.count === 0

        Image {
            source: "../../icons/clipboard-filled.svg"
            width: 96
            height: 96
            sourceSize: Qt.size(64, 64)
            opacity: 0.5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: I18n.tr("RightPanel", "No rules yet")
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: I18n.tr("RightPanel", "Click 'Add Rule' to start")
            font.pixelSize: EUITheme.fontCaption
            color: EUITheme.colorTextSubtle
            opacity: 0.6
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }

    // Rule list
    ListView {
        id: ruleListView
        anchors.fill: parent
        anchors.margins: EUITheme.spacingM
        spacing: EUITheme.spacingS
        clip: true

        delegate: Rectangle {
            width: ruleListView.width
            height: 70
            color: ruleMouseArea.containsMouse ? "#EEF3FF" : "#F7F9FC"
            border.width: 1
            border.color: EUITheme.colorBorder
            radius: EUITheme.radiusSmall

            Row {
                anchors.fill: parent
                anchors.margins: EUITheme.spacingM
                spacing: EUITheme.spacingM

                // Up/Down buttons column
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    width: 28

                    // Move up button
                    Rectangle {
                        width: 28
                        height: 20
                        color: upMouseArea.containsMouse ? EUITheme.colorMutedBg : "transparent"
                        radius: 4
                        visible: index > 0
                        
                        Text {
                            text: "▲"
                            font.pixelSize: 12
                            color: EUITheme.colorTextSubtle
                            anchors.centerIn: parent
                            opacity: upMouseArea.containsMouse ? 1.0 : 0.6
                        }

                        MouseArea {
                            id: upMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                mouse.accepted = true
                                root.ruleMoveUp(index)
                            }
                        }
                    }

                    // Move down button
                    Rectangle {
                        width: 28
                        height: 20
                        color: downMouseArea.containsMouse ? EUITheme.colorMutedBg : "transparent"
                        radius: 4
                        visible: index < ruleListView.count - 1
                        
                        Text {
                            text: "▼"
                            font.pixelSize: 12
                            color: EUITheme.colorTextSubtle
                            anchors.centerIn: parent
                            opacity: downMouseArea.containsMouse ? 1.0 : 0.6
                        }

                        MouseArea {
                            id: downMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                mouse.accepted = true
                                root.ruleMoveDown(index)
                            }
                        }
                    }
                }
                
                // Rule type and description
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    width: parent.width - 40

                    // First line: Rule type
                    Text {
                        text: getRuleTypeName(model.config ? model.config.ruleType : "")
                        font.pixelSize: EUITheme.fontBody
                        font.weight: EUITheme.fontWeightMedium
                        color: EUITheme.colorText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    // Second line: Rule description
                    Text {
                        text: model.description || ""
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextSubtle
                        elide: Text.ElideRight
                        width: parent.width
                        visible: text.length > 0
                    }
                }
            }

            // Delete button (top-right corner)
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: EUITheme.spacingS
                width: 28
                height: 28
                color: deleteMouseArea.containsMouse ? Qt.rgba(59, 130, 246, 0.1) : "transparent"
                radius: EUITheme.radiusSmall
                
                Text {
                    text: "\u2715"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: EUITheme.colorPrimary
                    anchors.centerIn: parent
                    opacity: deleteMouseArea.containsMouse ? 1.0 : 0.7
                }

                MouseArea {
                    id: deleteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mouse.accepted = true
                        root.ruleDeleted(index)
                    }
                    
                    ToolTip.visible: containsMouse
                    ToolTip.text: I18n.tr("RightPanel", "Remove")
                    ToolTip.delay: 500
                }
            }

            MouseArea {
                id: ruleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: -1
                onDoubleClicked: root.ruleDoubleClicked(index)
            }
        }
    }

    // Get rule type icon path
    function getRuleIconPath(ruleType) {
        switch(ruleType) {
            case "replace":
                return "../../icons/refresh.svg"
            case "remove":
                return "../../icons/trash.svg"
            case "format":
                return "../../icons/text.svg"
            case "add":
            case "addPrefix":
            case "addSuffix":
                return "../../icons/plus.svg"
            case "numbering":
                return "../../icons/hash.svg"
            default:
                return "../../icons/clipboard.svg"
        }
    }
    
    // Get rule type name for display
    function getRuleTypeName(ruleType) {
        switch(ruleType) {
            case "replace":
                return I18n.tr("RuleTypeSelector", "Replace")
            case "remove":
                return I18n.tr("RuleTypeSelector", "Remove")
            case "format":
                return I18n.tr("RuleTypeSelector", "Format")
            case "add":
            case "addPrefix":
            case "addSuffix":
                return I18n.tr("RuleTypeSelector", "Add")
            case "numbering":
                return I18n.tr("RuleTypeSelector", "Numbering")
            default:
                return I18n.tr("RightPanel", "Unnamed Rule")
        }
    }
    
    // Get rule type icon (deprecated, kept for compatibility)
    function getRuleIcon(ruleType) {
        switch(ruleType) {
            case "replace":
                return "🔄"
            case "remove":
                return "🗑️"
            case "format":
                return "🔤"
            case "add":
            case "addPrefix":
            case "addSuffix":
                return "➕"
            case "numbering":
                return "🔢"
            default:
                return "📋"
        }
    }
}
