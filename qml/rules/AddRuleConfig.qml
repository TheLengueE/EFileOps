import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Add Prefix/Suffix Rule Configuration Dialog ==========
Popup {
    id: root
    
    property string textToAdd: ""
    property bool isPrefix: true  // true=prefix, false=suffix
    
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
            text: I18n.tr("AddRuleConfig", "Add Prefix/Suffix Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }
        
        // Rule type selection
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("AddRuleConfig", "Rule Type") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60
                    color: root.isPrefix ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.isPrefix ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Image {
                            source: "../../icons/arrow-left.svg"
                            width: 24
                            height: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("AddRuleConfig", "Prefix")
                            font.pixelSize: EUITheme.fontCaption
                            color: root.isPrefix ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.isPrefix ? Font.DemiBold : Font.Normal
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isPrefix = true
                            updatePreview()
                        }
                    }
                }
                
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60
                    color: !root.isPrefix ? EUITheme.colorPrimarySoft : "white"
                    border.color: !root.isPrefix ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Image {
                            source: "../../icons/arrow-right.svg"
                            width: 24
                            height: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("AddRuleConfig", "Suffix")
                            font.pixelSize: EUITheme.fontCaption
                            color: !root.isPrefix ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: !root.isPrefix ? Font.DemiBold : Font.Normal
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isPrefix = false
                            updatePreview()
                        }
                    }
                }
            }
        }
        
        // Text input
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("AddRuleConfig", "Text to Add") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            TextField {
                id: textField
                width: parent.width
                placeholderText: root.isPrefix ? 
                    I18n.tr("AddRuleConfig", "e.g., 'IMG_' will become 'IMG_file.jpg'") :
                    I18n.tr("AddRuleConfig", "e.g., '_copy' will become 'file_copy.jpg'")
                text: root.textToAdd
                font.pixelSize: EUITheme.fontBody
                
                onTextChanged: {
                    root.textToAdd = text
                    updatePreview()
                }
                
                background: Rectangle {
                    color: textField.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: textField.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: EUITheme.radiusMedium
                }
                
                leftPadding: EUITheme.spacingM
                rightPadding: EUITheme.spacingM
                topPadding: EUITheme.spacingS
                bottomPadding: EUITheme.spacingS
            }
            
            Text {
                text: root.isPrefix ? 
                    I18n.tr("AddRuleConfig", "The text will be added at the beginning of file names") :
                    I18n.tr("AddRuleConfig", "The text will be added at the end of file names (before extension)")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
        
        // Preview section
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("AddRuleConfig", "Preview")
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
                            text: I18n.tr("AddRuleConfig", "Before:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: beforePreview
                            text: "example_file.jpg"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorText
                            font.family: "monospace"
                        }
                    }
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: I18n.tr("AddRuleConfig", "After:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: afterPreview
                            text: "example_file.jpg"
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
                enabled: root.textToAdd.trim() !== ""
                onClicked: {
                    var config = {
                        "ruleType": root.isPrefix ? "addPrefix" : "addSuffix",
                        "name": root.isPrefix ? 
                            I18n.tr("AddRuleConfig", "Add Prefix: %1").replace("%1", root.textToAdd) :
                            I18n.tr("AddRuleConfig", "Add Suffix: %1").replace("%1", root.textToAdd),
                        "text": root.textToAdd
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }
    
    // Update preview
    function updatePreview() {
        var text = root.textToAdd;
        var exampleText = "example_file";
        var extension = ".jpg";
        
        beforePreview.text = exampleText + extension;
        
        if (text.length === 0) {
            afterPreview.text = exampleText + extension;
            return;
        }
        
        if (root.isPrefix) {
            afterPreview.text = text + exampleText + extension;
        } else {
            afterPreview.text = exampleText + text + extension;
        }
    }
    
    // Reset when opened
    onOpened: {
        textToAdd = "";
        isPrefix = true;
        updatePreview();
        textField.forceActiveFocus();
    }
}
