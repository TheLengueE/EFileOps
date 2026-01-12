import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Replace Rule Configuration Dialog ==========
Popup {
    id: root
    
    property string findText: ""
    property string replaceText: ""
    property bool caseSensitive: false
    
    signal ruleConfigured(var ruleConfig)
    signal backToSelector()
    
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 520
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
        width: parent.width
        spacing: EUITheme.spacingL
        
        // Title
        Text {
            text: I18n.tr("ReplaceRuleConfig", "Replace Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }
        
        // Find text input
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("ReplaceRuleConfig", "Find Text") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            TextField {
                id: findTextField
                width: parent.width
                placeholderText: I18n.tr("ReplaceRuleConfig", "Enter text to find")
                text: root.findText
                font.pixelSize: EUITheme.fontBody
                
                onTextChanged: {
                    root.findText = text
                    updatePreview()
                }
                
                background: Rectangle {
                    color: findTextField.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: findTextField.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: EUITheme.radiusMedium
                }
                
                leftPadding: EUITheme.spacingM
                rightPadding: EUITheme.spacingM
                topPadding: EUITheme.spacingS
                bottomPadding: EUITheme.spacingS
            }
        }
        
        // Replace text input
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("ReplaceRuleConfig", "Replace With")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            TextField {
                id: replaceTextField
                width: parent.width
                placeholderText: I18n.tr("ReplaceRuleConfig", "Enter replacement text (leave empty to remove)")
                text: root.replaceText
                font.pixelSize: EUITheme.fontBody
                
                onTextChanged: {
                    root.replaceText = text
                    updatePreview()
                }
                
                background: Rectangle {
                    color: replaceTextField.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: replaceTextField.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: EUITheme.radiusMedium
                }
                
                leftPadding: EUITheme.spacingM
                rightPadding: EUITheme.spacingM
                topPadding: EUITheme.spacingS
                bottomPadding: EUITheme.spacingS
            }
            
            Text {
                text: I18n.tr("ReplaceRuleConfig", "Example: 'test' → 'demo' will change 'test.txt' to 'demo.txt'")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
        
        // Case sensitive switch
        Row {
            width: parent.width
            spacing: EUITheme.spacingM
            
            ESwitch {
                id: caseSensitiveSwitch
                checked: root.caseSensitive
                onCheckedChanged: {
                    root.caseSensitive = checked
                    updatePreview()
                }
            }
            
            Column {
                width: parent.width - caseSensitiveSwitch.width - parent.spacing
                spacing: 4
                
                Text {
                    text: I18n.tr("ReplaceRuleConfig", "Case Sensitive")
                    font.pixelSize: EUITheme.fontBody
                    font.weight: Font.Medium
                    color: EUITheme.colorText
                }
                
                Text {
                    text: I18n.tr("ReplaceRuleConfig", "When enabled, 'Test' and 'test' will be treated as different")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
        
        // Preview section
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("ReplaceRuleConfig", "Preview")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            Rectangle {
                width: parent.width
                height: previewColumn.height + EUITheme.spacingM * 2
                color: EUITheme.colorMutedBg
                border.width: 1
                border.color: EUITheme.colorBorder
                radius: EUITheme.radiusMedium
                
                Column {
                    id: previewColumn
                    anchors.centerIn: parent
                    width: parent.width - EUITheme.spacingM * 2
                    spacing: EUITheme.spacingS
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: I18n.tr("ReplaceRuleConfig", "Before:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: beforePreview
                            text: "example_test_file.jpg"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorText
                            font.family: "monospace"
                        }
                    }
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: I18n.tr("ReplaceRuleConfig", "After:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: afterPreview
                            text: "example_test_file.jpg"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorPrimary
                            font.family: "monospace"
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
        
        // Bottom buttons
        Row {
            width: parent.width
            spacing: EUITheme.spacingM
            
            EButton {
                buttonType: EButton.ButtonType.Secondary
                text: I18n.tr("Common", "Back")
                implicitWidth: (parent.width - parent.spacing) / 2
                onClicked: root.backToSelector()
            }
            
            EButton {
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("Common", "Add Rule")
                implicitWidth: (parent.width - parent.spacing) / 2
                enabled: root.findText.trim() !== ""
                onClicked: {
                    var config = {
                        "ruleType": "replace",
                        "name": I18n.tr("ReplaceRuleConfig", "Replace: %1 → %2")
                                .replace("%1", root.findText)
                                .replace("%2", root.replaceText || "(empty)"),
                        "findText": root.findText,
                        "replaceText": root.replaceText,
                        "caseSensitive": root.caseSensitive
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }
    
    // Update preview
    function updatePreview() {
        var findText = root.findText;
        var replaceText = root.replaceText;
        var exampleText = "example_test_file.jpg";
        
        beforePreview.text = exampleText;
        
        if (findText.length === 0) {
            afterPreview.text = exampleText;
            return;
        }
        
        // Simple text replacement
        if (root.caseSensitive) {
            afterPreview.text = exampleText.split(findText).join(replaceText);
        } else {
            var regex = new RegExp(findText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
            afterPreview.text = exampleText.replace(regex, replaceText);
        }
    }
    
    // Reset when opened
    onOpened: {
        findText = "";
        replaceText = "";
        caseSensitive = false;
        updatePreview();
        findTextField.forceActiveFocus();
    }
}
