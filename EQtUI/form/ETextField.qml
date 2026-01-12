import QtQuick
import QtQuick.Controls
import EUI

// EUI TextField Component
TextField {
    id: root
    
    // Error state
    property bool hasError: false
    property string errorMessage: ""
    
    // Size
    implicitWidth: 200
    implicitHeight: EUITheme.inputHeight
    
    padding: EUITheme.spacingM
    leftPadding: EUITheme.spacingM
    rightPadding: EUITheme.spacingM
    
    // Font
    font.pixelSize: EUITheme.fontBody
    color: enabled ? EUITheme.colorText : EUITheme.colorTextDisabled
    
    placeholderTextColor: EUITheme.colorTextSubtle
    
    // Background
    background: Rectangle {
        id: bg
        radius: EUITheme.radiusSmall
        color: root.enabled ? EUITheme.colorCard : EUITheme.colorMutedBg
        
        border.width: 1
        border.color: {
            if (root.hasError) {
                return EUITheme.colorDanger
            }
            if (root.activeFocus) {
                return EUITheme.colorPrimary
            }
            return EUITheme.colorBorder
        }
        
        Behavior on border.color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
        
        // Focus ring effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: parent.radius + 3
            color: "transparent"
            border.width: root.activeFocus ? 3 : 0
            border.color: root.hasError 
                ? Qt.rgba(229/255, 69/255, 69/255, 0.2)
                : Qt.rgba(49/255, 85/255, 245/255, 0.2)
            visible: root.activeFocus
            
            Behavior on border.width {
                NumberAnimation { duration: EUITheme.animationFast }
            }
        }
    }
    
    // Error message
    Column {
        anchors.top: parent.bottom
        anchors.topMargin: EUITheme.spacingXS
        anchors.left: parent.left
        anchors.right: parent.right
        visible: root.hasError && root.errorMessage !== ""
        
        Text {
            text: root.errorMessage
            font.pixelSize: EUITheme.fontCaption
            color: EUITheme.colorDanger
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
    
    selectByMouse: true
}
