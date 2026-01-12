import QtQuick
import QtQuick.Controls
import EUI

// EUI Accordion Component - Collapsible Panel
Column {
    id: root
    
    spacing: EUITheme.spacingSmall
    
    // Panel data
    property var items: []
    
    // Currently expanded indices
    property var expandedIndices: []
    
    // Allow multiple panels expanded simultaneously
    property bool allowMultiple: false
    
    Repeater {
        model: root.items
        
        delegate: Item {
            width: root.width
            height: headerRect.height + (isExpanded ? contentLoader.height + EUITheme.spacingSmall : 0)
            
            property bool isExpanded: root.expandedIndices.indexOf(index) !== -1
            
            Behavior on height {
                NumberAnimation { duration: EUITheme.animationNormal; easing.type: Easing.OutCubic }
            }
            
            // Header
            Rectangle {
                id: headerRect
                width: parent.width
                height: 48
                color: headerMouseArea.containsMouse ? EUITheme.colorMutedBg : EUITheme.colorCard
                border.width: 1
                border.color: EUITheme.colorBorder
                radius: EUITheme.radiusSmall
                
                Behavior on color {
                    ColorAnimation { duration: EUITheme.animationFast }
                }
                
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: EUITheme.spacingMedium
                    anchors.rightMargin: EUITheme.spacingMedium
                    spacing: EUITheme.spacingMedium
                    
                    // Arrow icon
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: isExpanded ? "▼" : "▶"
                        color: EUITheme.colorTextSubtle
                        font.pixelSize: 10
                        
                        Behavior on rotation {
                            NumberAnimation { duration: EUITheme.animationNormal }
                        }
                    }
                    
                    // Title
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 30
                        text: modelData.title || modelData
                        color: EUITheme.colorText
                        font.pixelSize: EUITheme.fontBody
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }
                
                MouseArea {
                    id: headerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.allowMultiple) {
                            let idx = root.expandedIndices.indexOf(index)
                            let newIndices = [...root.expandedIndices]
                            if (idx === -1) {
                                newIndices.push(index)
                            } else {
                                newIndices.splice(idx, 1)
                            }
                            root.expandedIndices = newIndices
                        } else {
                            root.expandedIndices = isExpanded ? [] : [index]
                        }
                    }
                }
            }
            
            // Content area
            Loader {
                id: contentLoader
                anchors.top: headerRect.bottom
                anchors.topMargin: isExpanded ? EUITheme.spacingSmall : 0
                width: parent.width
                active: isExpanded
                
                sourceComponent: Rectangle {
                    width: root.width
                    implicitHeight: contentText.implicitHeight + EUITheme.spacingMedium * 2
                    color: EUITheme.colorCard
                    border.width: 1
                    border.color: EUITheme.colorBorder
                    radius: EUITheme.radiusSmall
                    
                    Text {
                        id: contentText
                        anchors.fill: parent
                        anchors.margins: EUITheme.spacingMedium
                        text: modelData.content || "Content"
                        color: EUITheme.colorTextSubtle
                        font.pixelSize: EUITheme.fontBody
                        wrapMode: Text.WordWrap
                    }
                }
                
                Behavior on anchors.topMargin {
                    NumberAnimation { duration: EUITheme.animationNormal }
                }
            }
        }
    }
}
