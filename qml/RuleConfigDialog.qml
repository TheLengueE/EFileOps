import QtQuick
import QtQuick.Controls
import EUI
import "."

// ========== Rule Configuration Dialog (Modal) ==========
Popup {
    id: root
    
    // Signal: Rule creation completed
    signal ruleCreated(string ruleName, string ruleDescription)
    
    // Center display
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 480
    padding: EUITheme.spacingXL
    
    // Background
    background: Rectangle {
        color: EUITheme.colorCard
        radius: EUITheme.radiusLarge
        border.width: 1
        border.color: EUITheme.colorBorder
    }
    
    // Overlay mask
    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    
    // Content
    Column {
        width: parent.width
        spacing: EUITheme.spacingL
        
        // Title
        Text {
            text: I18n.tr("RuleConfigDialog", "Add Rename Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
            width: parent.width
        }
        
        // Rule name
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("RuleConfigDialog", "Rule Name")
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
            }
            
            ETextField {
                id: ruleNameField
                width: parent.width
                placeholderText: I18n.tr("RuleConfigDialog", "e.g., Add Prefix")
            }
        }
        
        // Rule type
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("RuleConfigDialog", "Rule Type")
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
            }
            
            EDropdown {
                id: ruleTypeCombo
                width: parent.width
                
                model: [
                    I18n.tr("RuleConfigDialog", "Add Prefix"),
                    I18n.tr("RuleConfigDialog", "Add Suffix"),
                    I18n.tr("RuleConfigDialog", "Replace Text"),
                    I18n.tr("RuleConfigDialog", "Add Counter")
                ]
            }
        }
        
        // Rule parameters
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("RuleConfigDialog", "Parameter")
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
            }
            
            ETextField {
                id: ruleParamField
                width: parent.width
                placeholderText: I18n.tr("RuleConfigDialog", "e.g., IMG_")
            }
        }
        
        // Preview
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("RuleConfigDialog", "Preview")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
            }
            
            Rectangle {
                width: parent.width
                height: 40
                color: EUITheme.colorMutedBg
                border.width: 1
                border.color: EUITheme.colorBorder
                radius: EUITheme.radiusSmall
                
                Text {
                    anchors.centerIn: parent
                    text: root.generatePreview()
                    font.pixelSize: EUITheme.fontBody
                    color: EUITheme.colorText
                    font.family: "monospace"
                }
            }
        }
        
        // Bottom buttons
        Row {
            width: parent.width
            spacing: EUITheme.spacingM
            layoutDirection: Qt.RightToLeft
            
            EButton {
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("RuleConfigDialog", "Add")
                
                onClicked: {
                    // Create rule
                    var ruleName = ruleNameField.text || ruleTypeCombo.currentText
                    var ruleDesc = ruleTypeCombo.currentText + ": " + ruleParamField.text
                    
                    root.ruleCreated(ruleName, ruleDesc)
                    
                    // Clear form
                    ruleNameField.text = ""
                    ruleParamField.text = ""
                    ruleTypeCombo.currentIndex = 0
                    
                    root.close()
                }
            }
            
            EButton {
                buttonType: EButton.ButtonType.Secondary
                text: I18n.tr("RuleConfigDialog", "Cancel")
                
                onClicked: {
                    root.close()
                }
            }
        }
    }
    
    // Generate preview text
    function generatePreview() {
        var param = ruleParamField.text || "..."
        var type = ruleTypeCombo.currentIndex
        
        switch(type) {
            case 0: return param + "example.jpg"  // Add prefix
            case 1: return "example" + param + ".jpg"  // Add suffix
            case 2: return "example.jpg → " + param  // Replace text
            case 3: return param + "001.jpg"  // Add counter
            default: return "example.jpg"
        }
    }
    
    // Open/close animation
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: EUITheme.animationNormal
        }
        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1.0
            duration: EUITheme.animationNormal
            easing.type: Easing.OutQuad
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: EUITheme.animationFast
        }
    }
}
