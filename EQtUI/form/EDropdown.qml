import QtQuick
import QtQuick.Controls
import EUI

// EUI Dropdown Component - Dropdown Selection
ComboBox {
    id: root
    
    // Size
    implicitWidth: 200
    implicitHeight: 40
    
    // Model
    model: ["Option 1", "Option 2", "Option 3"]
    
    // Font
    font.pixelSize: EUITheme.fontBody
    font.weight: Font.Normal
    
    // Background
    background: Rectangle {
        color: root.enabled ? EUITheme.colorCard : EUITheme.colorMutedBg
        border.width: 1
        border.color: root.down ? EUITheme.colorPrimary :
                     root.hovered ? EUITheme.colorTextSubtle :
                     EUITheme.colorBorder
        radius: EUITheme.radiusSmall
        
        Behavior on border.color {
            ColorAnimation { duration: EUITheme.animationFast }
        }
    }
    
    // Display item
    contentItem: Text {
        leftPadding: EUITheme.spacingMedium
        rightPadding: root.indicator.width + EUITheme.spacingMedium
        
        text: root.displayText
        font: root.font
        color: root.enabled ? EUITheme.colorText : EUITheme.colorTextDisabled
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    // Dropdown arrow
    indicator: Canvas {
        id: canvas
        x: root.width - width - EUITheme.spacingMedium
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"
        
        Connections {
            target: root
            function onPressedChanged() { canvas.requestPaint(); }
        }
        
        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = root.enabled ? EUITheme.colorTextSubtle : EUITheme.colorTextDisabled;
            context.fill();
        }
    }
    
    // Dropdown popup panel
    popup: Popup {
        y: root.height + 4
        width: root.width
        implicitHeight: contentItem.implicitHeight
        padding: 4
        
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        background: Rectangle {
            color: EUITheme.colorCard
            border.color: EUITheme.colorBorder
            border.width: 1
            radius: EUITheme.radiusSmall
            
            // Simple shadow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                z: -1
                radius: parent.radius + 4
                color: Qt.rgba(0, 0, 0, 0.08)
            }
        }
    }
    
    // Option delegate
    delegate: ItemDelegate {
        width: root.width - 8
        height: 36
        
        contentItem: Text {
            text: modelData
            color: highlighted ? EUITheme.colorPrimary : EUITheme.colorText
            font: root.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: EUITheme.spacingMedium
        }
        
        background: Rectangle {
            color: highlighted ? EUITheme.colorPrimarySoft : 
                   parent.hovered ? EUITheme.colorMutedBg : 
                   "transparent"
            radius: EUITheme.radiusSmall
            
            Behavior on color {
                ColorAnimation { duration: EUITheme.animationFast }
            }
        }
        
        highlighted: root.highlightedIndex === index
    }
}
