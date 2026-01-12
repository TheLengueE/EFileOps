import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Format Rule Configuration Dialog ==========
Popup {
    id: root
    
    property int selectedFormat: 0  // 0=All Uppercase, 1=All Lowercase, 2=First Letter Uppercase, 3=Word Title Case
    
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
            text: I18n.tr("FormatRuleConfig", "Format Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }
        
        Text {
            text: I18n.tr("FormatRuleConfig", "Select the formatting style for file names")
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
            width: parent.width
        }
        
        // Format options
        Column {
            width: parent.width
            spacing: EUITheme.spacingM
            
            Text {
                text: I18n.tr("FormatRuleConfig", "Format Type") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            // All Uppercase
            Rectangle {
                width: parent.width
                height: 70
                color: root.selectedFormat === 0 ? EUITheme.colorPrimarySoft : "white"
                border.color: root.selectedFormat === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: EUITheme.radiusMedium
                
                Row {
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingM
                    spacing: EUITheme.spacingM
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        border.width: 2
                        border.color: root.selectedFormat === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: EUITheme.colorPrimary
                            anchors.centerIn: parent
                            visible: root.selectedFormat === 0
                        }
                    }
                    
                    Column {
                        width: parent.width - 24 - parent.spacing * 2
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: I18n.tr("FormatRuleConfig", "All Uppercase")
                            font.pixelSize: EUITheme.fontBody
                            font.weight: Font.Medium
                            color: root.selectedFormat === 0 ? EUITheme.colorPrimary : EUITheme.colorText
                        }
                        
                        Text {
                            text: "file.txt → FILE.TXT"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            font.family: "monospace"
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedFormat = 0
                        updatePreview()
                    }
                }
            }
            
            // All Lowercase
            Rectangle {
                width: parent.width
                height: 70
                color: root.selectedFormat === 1 ? EUITheme.colorPrimarySoft : "white"
                border.color: root.selectedFormat === 1 ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: EUITheme.radiusMedium
                
                Row {
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingM
                    spacing: EUITheme.spacingM
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        border.width: 2
                        border.color: root.selectedFormat === 1 ? EUITheme.colorPrimary : EUITheme.colorBorder
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: EUITheme.colorPrimary
                            anchors.centerIn: parent
                            visible: root.selectedFormat === 1
                        }
                    }
                    
                    Column {
                        width: parent.width - 24 - parent.spacing * 2
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: I18n.tr("FormatRuleConfig", "All Lowercase")
                            font.pixelSize: EUITheme.fontBody
                            font.weight: Font.Medium
                            color: root.selectedFormat === 1 ? EUITheme.colorPrimary : EUITheme.colorText
                        }
                        
                        Text {
                            text: "File.TXT → file.txt"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            font.family: "monospace"
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedFormat = 1
                        updatePreview()
                    }
                }
            }
            
            // First Letter Uppercase
            Rectangle {
                width: parent.width
                height: 70
                color: root.selectedFormat === 2 ? EUITheme.colorPrimarySoft : "white"
                border.color: root.selectedFormat === 2 ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: EUITheme.radiusMedium
                
                Row {
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingM
                    spacing: EUITheme.spacingM
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        border.width: 2
                        border.color: root.selectedFormat === 2 ? EUITheme.colorPrimary : EUITheme.colorBorder
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: EUITheme.colorPrimary
                            anchors.centerIn: parent
                            visible: root.selectedFormat === 2
                        }
                    }
                    
                    Column {
                        width: parent.width - 24 - parent.spacing * 2
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: I18n.tr("FormatRuleConfig", "First Letter Uppercase")
                            font.pixelSize: EUITheme.fontBody
                            font.weight: Font.Medium
                            color: root.selectedFormat === 2 ? EUITheme.colorPrimary : EUITheme.colorText
                        }
                        
                        Text {
                            text: "hello_world → Hello_world"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            font.family: "monospace"
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedFormat = 2
                        updatePreview()
                    }
                }
            }
            
            // Word Title Case
            Rectangle {
                width: parent.width
                height: 70
                color: root.selectedFormat === 3 ? EUITheme.colorPrimarySoft : "white"
                border.color: root.selectedFormat === 3 ? EUITheme.colorPrimary : EUITheme.colorBorder
                border.width: 2
                radius: EUITheme.radiusMedium
                
                Row {
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingM
                    spacing: EUITheme.spacingM
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        border.width: 2
                        border.color: root.selectedFormat === 3 ? EUITheme.colorPrimary : EUITheme.colorBorder
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: EUITheme.colorPrimary
                            anchors.centerIn: parent
                            visible: root.selectedFormat === 3
                        }
                    }
                    
                    Column {
                        width: parent.width - 24 - parent.spacing * 2
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: I18n.tr("FormatRuleConfig", "Word Title Case")
                            font.pixelSize: EUITheme.fontBody
                            font.weight: Font.Medium
                            color: root.selectedFormat === 3 ? EUITheme.colorPrimary : EUITheme.colorText
                        }
                        
                        Text {
                            text: "hello_world → Hello_World"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            font.family: "monospace"
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedFormat = 3
                        updatePreview()
                    }
                }
            }
        }
        
        // Preview section
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("FormatRuleConfig", "Preview")
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
                            text: I18n.tr("FormatRuleConfig", "Before:") + " "
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: beforePreview
                            text: "Hello_World_File.txt"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorText
                            font.family: "monospace"
                        }
                    }
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: I18n.tr("FormatRuleConfig", "After:") + " "
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }
                        
                        Text {
                            id: afterPreview
                            text: "Hello_World_File.txt"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorPrimary
                            font.family: "monospace"
                            font.weight: Font.Medium
                        }
                    }
                }
            }
            
            Text {
                text: I18n.tr("FormatRuleConfig", "Tip: For 'Word Title Case', separators include space, underscore (_), dot (.), and hyphen (-)")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
                wrapMode: Text.WordWrap
                width: parent.width
                visible: root.selectedFormat === 3
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
                onClicked: {
                    var formatNames = [
                        I18n.tr("FormatRuleConfig", "All Uppercase"),
                        I18n.tr("FormatRuleConfig", "All Lowercase"),
                        I18n.tr("FormatRuleConfig", "First Letter Uppercase"),
                        I18n.tr("FormatRuleConfig", "Word Title Case")
                    ];
                    var caseTypes = [0, 1, 2, 3]; // UpperCase, LowerCase, TitleCase, WordTitleCase
                    
                    var config = {
                        "ruleType": "format",
                        "name": I18n.tr("FormatRuleConfig", "Format:") + " " + formatNames[root.selectedFormat],
                        "caseType": caseTypes[root.selectedFormat]
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }
    
    // Update preview
    function updatePreview() {
        var example = "Hello_World_File.txt";
        beforePreview.text = example;
        
        switch (root.selectedFormat) {
            case 0: // All Uppercase
                afterPreview.text = example.toUpperCase();
                break;
            case 1: // All Lowercase
                afterPreview.text = example.toLowerCase();
                break;
            case 2: // First Letter Uppercase
                afterPreview.text = example.charAt(0).toUpperCase() + example.slice(1).toLowerCase();
                break;
            case 3: // Word Title Case
                afterPreview.text = capitalizeWords(example);
                break;
        }
    }
    
    // Capitalize first letter of each word
    function capitalizeWords(str) {
        var result = "";
        var capitalizeNext = true;
        var delimiters = [' ', '_', '.', '-'];
        
        for (var i = 0; i < str.length; i++) {
            var c = str.charAt(i);
            
            if (delimiters.indexOf(c) !== -1) {
                result += c;
                capitalizeNext = true;
            } else {
                if (capitalizeNext && /[a-zA-Z]/.test(c)) {
                    result += c.toUpperCase();
                    capitalizeNext = false;
                } else {
                    result += c.toLowerCase();
                }
            }
        }
        
        return result;
    }
    
    // Reset when opened
    onOpened: {
        selectedFormat = 0;
        updatePreview();
    }
}
