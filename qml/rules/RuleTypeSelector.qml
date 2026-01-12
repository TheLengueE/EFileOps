import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Rule Type Selector Dialog ==========
Popup {
    id: root
    
    // Signal: rule type selected
    signal ruleTypeSelected(string ruleType)
    
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 480
    height: Math.min(contentColumn.implicitHeight + EUITheme.spacingXL * 2 + 60, 720)
    padding: EUITheme.spacingXL
    
    background: Rectangle {
        color: EUITheme.colorCard
        radius: EUITheme.radiusLarge
        border.width: 1
        border.color: EUITheme.colorBorder
        
        // Top-right close button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: EUITheme.spacingM
            width: 32
            height: 32
            color: closeMouseArea.containsMouse ? EUITheme.colorDanger : "transparent"
            radius: EUITheme.radiusSmall
            
            Image {
                source: "../../icons/close-x.svg"
                width: 20
                height: 20
                anchors.centerIn: parent
            }
            
            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.close()
            }
        }
    }
    
    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    
    Column {
        id: contentColumn
        width: parent.width
        spacing: EUITheme.spacingL
        
        // Title
        Text {
            text: I18n.tr("RuleTypeSelector", "Select Rule Type")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
            width: parent.width
        }
        
        Text {
            text: I18n.tr("RuleTypeSelector", "Please select the type of rule to configure")
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            width: parent.width
        }
        
        // Rule type list (vertical layout)
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            // Replace rule
            RuleTypeCard {
                width: parent.width
                title: I18n.tr("RuleTypeSelector", "Replace")
                description: I18n.tr("RuleTypeSelector", "Find and replace text in file names")
                onClicked: {
                    root.ruleTypeSelected("replace")
                    root.close()
                }
            }
            
            // Remove rule
            RuleTypeCard {
                width: parent.width
                title: I18n.tr("RuleTypeSelector", "Remove")
                description: I18n.tr("RuleTypeSelector", "Remove files from list by keyword matching")
                onClicked: {
                    root.ruleTypeSelected("remove")
                    root.close()
                }
            }
            
            // Format rule
            RuleTypeCard {
                width: parent.width
                title: I18n.tr("RuleTypeSelector", "Format")
                description: I18n.tr("RuleTypeSelector", "Change case and format of file names")
                onClicked: {
                    root.ruleTypeSelected("format")
                    root.close()
                }
            }
            
            // Add rule
            RuleTypeCard {
                width: parent.width
                title: I18n.tr("RuleTypeSelector", "Add")
                description: I18n.tr("RuleTypeSelector", "Add prefix or suffix to file names")
                onClicked: {
                    root.ruleTypeSelected("add")
                    root.close()
                }
            }
            
            // Numbering rule
            RuleTypeCard {
                width: parent.width
                title: I18n.tr("RuleTypeSelector", "Numbering")
                description: I18n.tr("RuleTypeSelector", "Add sequential numbers to files")
                onClicked: {
                    root.ruleTypeSelected("numbering")
                    root.close()
                }
            }
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
