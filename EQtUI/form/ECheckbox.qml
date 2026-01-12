import QtQuick
import QtQuick.Controls
import EUI

// EUI Checkbox Component
CheckBox {
    id: root
    
    implicitWidth: Math.max(indicator.width + leftPadding + rightPadding,
                           contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(indicator.height, contentItem.implicitHeight) + topPadding + bottomPadding
    
    padding: EUITheme.spacingXS
    spacing: EUITheme.spacingS
    
    hoverEnabled: true
    
    indicator: Rectangle {
        id: checkRect
        implicitWidth: 18
        implicitHeight: 18
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        
        border.width: 2
        border.color: root.checked ? EUITheme.colorPrimary : EUITheme.colorBorder
        color: root.checked ? EUITheme.colorPrimary : "transparent"
        
        Behavior on border.color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
        Behavior on color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
        
        // Check mark
        Canvas {
            id: checkMark
            anchors.fill: parent
            visible: root.checked
            opacity: root.checked ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: EUITheme.animationFast }
            }
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                
                // Draw check mark
                ctx.beginPath()
                ctx.moveTo(width * 0.25, height * 0.5)
                ctx.lineTo(width * 0.45, height * 0.7)
                ctx.lineTo(width * 0.75, height * 0.3)
                ctx.stroke()
            }
            
            Connections {
                target: root
                function onCheckedChanged() {
                    checkMark.requestPaint()
                }
            }
        }
    }
    
    contentItem: Text {
        text: root.text
        font.pixelSize: EUITheme.fontBody
        color: root.enabled ? EUITheme.colorText : EUITheme.colorTextDisabled
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + root.spacing
    }
    
    // Mouse cursor style
    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        acceptedButtons: Qt.NoButton
    }
}
