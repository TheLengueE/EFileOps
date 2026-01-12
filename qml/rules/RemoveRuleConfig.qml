import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Remove Files Rule Configuration Dialog ==========
Popup {
    id: root
    
    property string keyword: ""
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
            text: I18n.tr("RemoveRuleConfig", "Remove Files Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }
        
        // Info text
        Rectangle {
            width: parent.width
            height: infoText.height + EUITheme.spacingM * 2
            color: EUITheme.colorPrimarySoft
            radius: EUITheme.radiusMedium
            
            Text {
                id: infoText
                anchors.centerIn: parent
                width: parent.width - EUITheme.spacingM * 2
                text: I18n.tr("RemoveRuleConfig", "This rule will remove files from the list (not delete from disk) if their names contain the specified keyword.")
                font.pixelSize: EUITheme.fontBody
                color: EUITheme.colorPrimary
                wrapMode: Text.WordWrap
            }
        }
        
        // Keyword input
        Column {
            width: parent.width
            spacing: EUITheme.spacingS
            
            Text {
                text: I18n.tr("RemoveRuleConfig", "Keyword") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }
            
            TextField {
                id: keywordInput
                width: parent.width
                placeholderText: I18n.tr("RemoveRuleConfig", "Enter keyword to match files")
                text: root.keyword
                font.pixelSize: EUITheme.fontBody
                
                onTextChanged: root.keyword = text
                
                background: Rectangle {
                    color: keywordInput.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: keywordInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: EUITheme.radiusMedium
                }
                
                leftPadding: EUITheme.spacingM
                rightPadding: EUITheme.spacingM
                topPadding: EUITheme.spacingS
                bottomPadding: EUITheme.spacingS
            }
            
            Text {
                text: I18n.tr("RemoveRuleConfig", "Example: 'test' will match 'test.txt', 'my_test_file.jpg'")
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
                onCheckedChanged: root.caseSensitive = checked
            }
            
            Column {
                width: parent.width - caseSensitiveSwitch.width - parent.spacing
                spacing: 4
                
                Text {
                    text: I18n.tr("RemoveRuleConfig", "Case Sensitive")
                    font.pixelSize: EUITheme.fontBody
                    font.weight: Font.Medium
                    color: EUITheme.colorText
                }
                
                Text {
                    text: I18n.tr("RemoveRuleConfig", "When enabled, 'Test' and 'test' will be treated as different")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    wrapMode: Text.WordWrap
                    width: parent.width
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
                enabled: root.keyword.trim() !== ""
                onClicked: {
                    var config = {
                        "ruleType": "remove",
                        "name": I18n.tr("RemoveRuleConfig", "Remove: %1").replace("%1", root.keyword),
                        "keyword": root.keyword,
                        "caseSensitive": root.caseSensitive
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }
    
    // Reset when opened
    onOpened: {
        keyword = "";
        caseSensitive = false;
        keywordInput.forceActiveFocus();
    }
}
