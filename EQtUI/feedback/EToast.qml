import QtQuick
import QtQuick.Controls
import EUI

// EUI Toast Component - Temporary Notification
Popup {
    id: root
    
    // Position and size
    x: (parent.width - width) / 2
    y: parent.height - height - 80
    width: Math.min(contentText.implicitWidth + EUITheme.spacingLarge * 2, parent.width - 40)
    height: 48
    
    // Display duration
    property int duration: 3000
    
    // Message text
    property string message: "Toast Message"
    
    // Type (success, error, info)
    property string toastType: "info"
    
    // Auto close
    modal: false
    focus: false
    closePolicy: Popup.NoAutoClose
    
    // Start timer when opened
    onOpened: closeTimer.start()
    
    Timer {
        id: closeTimer
        interval: root.duration
        onTriggered: root.close()
    }
    
    // Background
    background: Rectangle {
        color: root.toastType === "error" ? EUITheme.colorDanger :
               root.toastType === "success" ? "#10B981" :
               EUITheme.colorText
        radius: EUITheme.radiusSmall
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            z: -1
            radius: parent.radius + 4
            color: Qt.rgba(0, 0, 0, 0.15)
        }
    }
    
    // Content
    contentItem: Row {
        spacing: EUITheme.spacingMedium
        
        // Icon
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.toastType === "success" ? "✓" :
                  root.toastType === "error" ? "✕" :
                  "ⓘ"
            color: EUITheme.colorCard
            font.pixelSize: 16
            font.weight: Font.Medium
        }
        
        // Text
        Text {
            id: contentText
            anchors.verticalCenter: parent.verticalCenter
            text: root.message
            color: EUITheme.colorCard
            font.pixelSize: EUITheme.fontBody
        }
    }
    
    // Enter/exit animation
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: EUITheme.animationNormal }
        NumberAnimation { property: "y"; from: root.parent.height; to: root.parent.height - root.height - 80; duration: EUITheme.animationNormal; easing.type: Easing.OutCubic }
    }
    
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: EUITheme.animationFast }
    }
    
    // Static show method
    function show(msg, type) {
        root.message = msg || "Toast Message"
        root.toastType = type || "info"
        root.open()
    }
}
