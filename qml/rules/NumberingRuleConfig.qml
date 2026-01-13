import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Numbering Rule Configuration Dialog ==========
Popup {
    id: root
    
    property int position: 0  // 0=prefix, 1=suffix
    property int startNumber: 1
    property int paddingLength: 3
    property string separator: "_"
    
    signal ruleConfigured(var ruleConfig)
    signal backToSelector()
    
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 560
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
            text: I18n.tr("NumberingRuleConfig", "Numbering Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }
        
        // Position selection
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Position") + " *"
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
                    color: root.position === 0 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.position === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder
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
                            text: I18n.tr("NumberingRuleConfig", "Prefix (001_name)")
                            font.pixelSize: EUITheme.fontCaption
                            color: root.position === 0 ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.position === 0 ? Font.DemiBold : Font.Normal
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.position = 0
                            updatePreview()
                        }
                    }
                }
                
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 60
                    color: root.position === 1 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.position === 1 ? EUITheme.colorPrimary : EUITheme.colorBorder
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
                            text: I18n.tr("NumberingRuleConfig", "Suffix (name_001)")
                            font.pixelSize: EUITheme.fontCaption
                            color: root.position === 1 ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.position === 1 ? Font.DemiBold : Font.Normal
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.position = 1
                            updatePreview()
                        }
                    }
                }
            }
        }
        
        // Start number
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Start Number") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            TextField {
                id: startNumberField
                width: parent.width
                text: root.startNumber.toString()
                placeholderText: "1"
                font.pixelSize: EUITheme.fontBody
                validator: IntValidator { bottom: 0; top: 9999 }
                
                onTextChanged: {
                    var num = parseInt(text)
                    if (!isNaN(num) && num >= 0) {
                        root.startNumber = num
                        updatePreview()
                    }
                }
                
                background: Rectangle {
                    color: startNumberField.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: startNumberField.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: EUITheme.radiusMedium
                }
                
                leftPadding: EUITheme.spacingM
                rightPadding: EUITheme.spacingM
                topPadding: EUITheme.spacingS
                bottomPadding: EUITheme.spacingS
            }
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "The starting number for file numbering")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
            }
        }
        
        // Padding length
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Padding Digits") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            Row {
                width: parent.width
                spacing: EUITheme.spacingM
                
                // 0 (No padding)
                Rectangle {
                    width: 70
                    height: 50
                    color: root.paddingLength === 0 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.paddingLength === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "1"
                            font.pixelSize: 16
                            font.family: "monospace"
                            font.weight: Font.Bold
                            color: root.paddingLength === 0 ? EUITheme.colorPrimary : EUITheme.colorText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("NumberingRuleConfig", "None")
                            font.pixelSize: 10
                            color: root.paddingLength === 0 ? EUITheme.colorPrimary : EUITheme.colorTextSubtle
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paddingLength = 0
                            updatePreview()
                        }
                    }
                }
                
                // 2 digits
                Rectangle {
                    width: 70
                    height: 50
                    color: root.paddingLength === 2 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.paddingLength === 2 ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "01"
                            font.pixelSize: 16
                            font.family: "monospace"
                            font.weight: Font.Bold
                            color: root.paddingLength === 2 ? EUITheme.colorPrimary : EUITheme.colorText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("NumberingRuleConfig", "2 Digits")
                            font.pixelSize: 10
                            color: root.paddingLength === 2 ? EUITheme.colorPrimary : EUITheme.colorTextSubtle
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paddingLength = 2
                            updatePreview()
                        }
                    }
                }
                
                // 3 digits (default)
                Rectangle {
                    width: 70
                    height: 50
                    color: root.paddingLength === 3 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.paddingLength === 3 ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "001"
                            font.pixelSize: 16
                            font.family: "monospace"
                            font.weight: Font.Bold
                            color: root.paddingLength === 3 ? EUITheme.colorPrimary : EUITheme.colorText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("NumberingRuleConfig", "3 Digits")
                            font.pixelSize: 10
                            color: root.paddingLength === 3 ? EUITheme.colorPrimary : EUITheme.colorTextSubtle
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paddingLength = 3
                            updatePreview()
                        }
                    }
                }
                
                // 4 digits
                Rectangle {
                    width: 70
                    height: 50
                    color: root.paddingLength === 4 ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.paddingLength === 4 ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusMedium
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: "0001"
                            font.pixelSize: 16
                            font.family: "monospace"
                            font.weight: Font.Bold
                            color: root.paddingLength === 4 ? EUITheme.colorPrimary : EUITheme.colorText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: I18n.tr("NumberingRuleConfig", "4 Digits")
                            font.pixelSize: 10
                            color: root.paddingLength === 4 ? EUITheme.colorPrimary : EUITheme.colorTextSubtle
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.paddingLength = 4
                            updatePreview()
                        }
                    }
                }
            }
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Choose the number of leading zeros")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
            }
            
            // Tip about numbering order
            Rectangle {
                width: parent.width
                height: orderTipText.height + EUITheme.spacingM * 1.5
                color: "#FFF8E1"
                border.width: 1
                border.color: "#FFD54F"
                radius: EUITheme.radiusSmall
                
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: EUITheme.spacingM
                    spacing: EUITheme.spacingS
                    
                    Image {
                        source: "../../icons/info.svg"
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        id: orderTipText
                        text: I18n.tr("NumberingRuleConfig", "Numbering follows list order. Sort by name or time in Settings")
                        font.pixelSize: EUITheme.fontCaption
                        color: "#F57C00"
                        wrapMode: Text.WordWrap
                        width: parent.width - 16 - parent.spacing - EUITheme.spacingS
                    }
                }
            }
        }
        
        // Separator
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Separator") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            Row {
                spacing: EUITheme.spacingM
                
                // Preset separator buttons
                Rectangle {
                    width: 50
                    height: 40
                    color: root.separator === "_" ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.separator === "_" ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusSmall
                    
                    Text {
                        text: "_"
                        font.pixelSize: 18
                        font.family: "monospace"
                        font.weight: Font.Bold
                        color: root.separator === "_" ? EUITheme.colorPrimary : EUITheme.colorText
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.separator = "_"
                            separatorField.text = "_"
                            updatePreview()
                        }
                    }
                }
                
                Rectangle {
                    width: 50
                    height: 40
                    color: root.separator === "-" ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.separator === "-" ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusSmall
                    
                    Text {
                        text: "-"
                        font.pixelSize: 18
                        font.family: "monospace"
                        font.weight: Font.Bold
                        color: root.separator === "-" ? EUITheme.colorPrimary : EUITheme.colorText
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.separator = "-"
                            separatorField.text = "-"
                            updatePreview()
                        }
                    }
                }
                
                Rectangle {
                    width: 50
                    height: 40
                    color: root.separator === " " ? EUITheme.colorPrimarySoft : "white"
                    border.color: root.separator === " " ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusSmall
                    
                    Text {
                        text: "space"
                        font.pixelSize: 10
                        color: root.separator === " " ? EUITheme.colorPrimary : EUITheme.colorText
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.separator = " "
                            separatorField.text = " "
                            updatePreview()
                        }
                    }
                }
                
                // Custom separator input field
                TextField {
                    id: separatorField
                    width: 80
                    height: 40
                    text: root.separator
                    placeholderText: "_"
                    font.pixelSize: EUITheme.fontBody
                    horizontalAlignment: Text.AlignHCenter
                    maximumLength: 3
                    
                    onTextChanged: {
                        if (text.length > 0) {
                            root.separator = text
                            updatePreview()
                        }
                    }
                    
                    background: Rectangle {
                        color: separatorField.enabled ? "white" : EUITheme.colorMutedBg
                        border.color: separatorField.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: 1
                        radius: EUITheme.radiusMedium
                    }
                }
            }
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Character between number and filename")
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorTextSubtle
            }
        }
        
        // Preview section
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("NumberingRuleConfig", "Preview Example")
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
                    spacing: EUITheme.spacingXS
                    
                    // First file
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: "file1.jpg →"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 120
                            font.family: "monospace"
                        }
                        
                        Text {
                            id: preview1
                            text: "001_file1.jpg"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorPrimary
                            font.family: "monospace"
                            font.weight: Font.Medium
                        }
                    }
                    
                    // Second file
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: "file2.jpg →"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 120
                            font.family: "monospace"
                        }
                        
                        Text {
                            id: preview2
                            text: "002_file2.jpg"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorPrimary
                            font.family: "monospace"
                            font.weight: Font.Medium
                        }
                    }
                    
                    // Third file
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS
                        
                        Text {
                            text: "file3.jpg →"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 120
                            font.family: "monospace"
                        }
                        
                        Text {
                            id: preview3
                            text: "003_file3.jpg"
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
                enabled: root.separator.trim() !== ""
                onClicked: {
                    var posText = root.position === 0 ? 
                        I18n.tr("NumberingRuleConfig", "Prefix") : 
                        I18n.tr("NumberingRuleConfig", "Suffix")
                    var paddingText = root.paddingLength > 0 ? 
                        I18n.tr("NumberingRuleConfig", "%1 Digits").replace("%1", root.paddingLength) :
                        I18n.tr("NumberingRuleConfig", "No Padding")
                    
                    var config = {
                        "ruleType": "numbering",
                        "name": I18n.tr("NumberingRuleConfig", "Numbering (%1, Start %2, %3)")
                            .replace("%1", posText)
                            .replace("%2", root.startNumber)
                            .replace("%3", paddingText),
                        "position": root.position,
                        "startNumber": root.startNumber,
                        "paddingLength": root.paddingLength,
                        "separator": root.separator
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }
    
    // Update preview
    function updatePreview() {
        var nums = [root.startNumber, root.startNumber + 1, root.startNumber + 2]
        var fileNames = ["file1.jpg", "file2.jpg", "file3.jpg"]
        var previews = [preview1, preview2, preview3]
        
        for (var i = 0; i < 3; i++) {
            var num = nums[i]
            var numStr = root.paddingLength > 0 ? 
                num.toString().padStart(root.paddingLength, '0') : 
                num.toString()
            
            var fileName = fileNames[i].replace(".jpg", "")
            var ext = ".jpg"
            
            if (root.position === 0) {
                // Prefix
                previews[i].text = numStr + root.separator + fileName + ext
            } else {
                // Suffix
                previews[i].text = fileName + root.separator + numStr + ext
            }
        }
    }
    
    // Reset when opened
    onOpened: {
        position = 0
        startNumber = 1
        paddingLength = 3
        separator = "_"
        separatorField.text = "_"
        updatePreview()
        startNumberField.forceActiveFocus()
    }
}
