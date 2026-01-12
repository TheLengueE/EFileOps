import QtQuick
import QtQuick.Controls
import EUI
import "."

// ========== Settings Dialog ==========
Popup {
    id: root
    
    // Center display
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 640
    height: 620
    padding: EUITheme.spacingXL * 1.5
    
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
    Item {
        width: parent.width
        height: parent.height
        
        // Main content area (scrollable)
        Column {
            id: contentColumn
            width: parent.width
            height: parent.height - 80  // Reserve space for bottom buttons
            spacing: EUITheme.spacingXL * 1.5
            
            // Title
            Text {
                text: I18n.tr("SettingsDialog", "Settings")
                font.pixelSize: EUITheme.fontH1
                font.weight: EUITheme.fontWeightSemiBold
                color: EUITheme.colorText
                width: parent.width
            }
            
            // Settings items area
            Column {
                width: parent.width
                spacing: EUITheme.spacingXL * 1.2
                
                // ========== Language Settings ==========
                Column {
                    width: parent.width
                    spacing: EUITheme.spacingM * 1.2
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "Language")
                        font.pixelSize: EUITheme.fontH3
                        font.weight: EUITheme.fontWeightMedium
                        color: EUITheme.colorText
                    }
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "Choose the display language for the application")
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextSubtle
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    ComboBox {
                        id: languageCombo
                        width: parent.width
                        implicitHeight: 48
                        
                        property bool initialized: false
                        
                        model: [
                            { text: "简体中文", value: "zh_CN" },
                            { text: "English", value: "en_US" }
                        ]
                        
                        textRole: "text"
                        
                        Component.onCompleted: {
                            // Initialize to current language
                            var currentLang = I18n.currentLanguage;
                            for (var i = 0; i < model.length; i++) {
                                if (model[i].value === currentLang) {
                                    currentIndex = i;
                                    break;
                                }
                            }
                            initialized = true;
                        }
                        
                        onCurrentIndexChanged: {
                            // Only trigger language switch after initialization
                            // and when index is valid
                            if (initialized && currentIndex >= 0) {
                                var selectedLang = model[currentIndex].value;
                                console.log("[SettingsDialog] Language selection changed to:", selectedLang);
                                I18n.switchLanguage(selectedLang);
                            }
                        }
                        
                        // Update ComboBox when language changes externally
                        Connections {
                            target: I18n
                            function onCurrentLanguageChanged() {
                                console.log("[SettingsDialog] I18n language changed to:", I18n.currentLanguage);
                                // Update ComboBox selection
                                for (var i = 0; i < languageCombo.model.length; i++) {
                                    if (languageCombo.model[i].value === I18n.currentLanguage) {
                                        languageCombo.initialized = false; // Prevent triggering switch
                                        languageCombo.currentIndex = i;
                                        languageCombo.initialized = true;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        background: Rectangle {
                            color: languageCombo.hovered ? EUITheme.colorMutedBg : "transparent"
                            border.color: EUITheme.colorBorder
                            border.width: 2
                            radius: EUITheme.radiusSmall
                        }
                        
                        contentItem: Text {
                            text: languageCombo.displayText
                            font.pixelSize: EUITheme.fontBody
                            color: EUITheme.colorText
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: EUITheme.spacingM
                        }
                    }
                }
                
                // Divider line
                Rectangle {
                    width: parent.width
                    height: 1
                    color: EUITheme.colorDivider
                    opacity: 0.5
                }
                
                // ========== Default Sort Mode Settings ==========
                Column {
                    width: parent.width
                    spacing: EUITheme.spacingM * 1.2
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "Default Sort Mode")
                        font.pixelSize: EUITheme.fontH3
                        font.weight: EUITheme.fontWeightMedium
                        color: EUITheme.colorText
                    }
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "Choose how files are sorted when added to the list")
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextSubtle
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingM
                        
                        // Sort by Name button
                        Rectangle {
                            width: (parent.width - parent.spacing) / 2
                            height: 60
                            color: mainController.settings.defaultSortMode === 0 ? EUITheme.colorPrimarySoft : EUITheme.colorMutedBg
                            border.color: mainController.settings.defaultSortMode === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder
                            border.width: 2
                            radius: EUITheme.radiusMedium
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                IconImage {
                                    source: "../icons/text.svg"
                                    width: 24
                                    height: 24
                                    color: "#2563EB"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Text {
                                    text: I18n.tr("SettingsDialog", "By Name")
                                    font.pixelSize: EUITheme.fontCaption
                                    font.weight: Font.Medium
                                    color: mainController.settings.defaultSortMode === 0 ? EUITheme.colorPrimary : EUITheme.colorText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mainController.settings.defaultSortMode = 0
                                }
                            }
                        }
                        
                        // Sort by Time button
                        Rectangle {
                            width: (parent.width - parent.spacing) / 2
                            height: 60
                            color: mainController.settings.defaultSortMode === 1 ? EUITheme.colorPrimarySoft : EUITheme.colorMutedBg
                            border.color: mainController.settings.defaultSortMode === 1 ? EUITheme.colorPrimary : EUITheme.colorBorder
                            border.width: 2
                            radius: EUITheme.radiusMedium
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                IconImage {
                                    source: "../icons/clock.svg"
                                    width: 24
                                    height: 24
                                    color: "#2563EB"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Text {
                                    text: I18n.tr("SettingsDialog", "By Time")
                                    font.pixelSize: EUITheme.fontCaption
                                    font.weight: Font.Medium
                                    color: mainController.settings.defaultSortMode === 1 ? EUITheme.colorPrimary : EUITheme.colorText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mainController.settings.defaultSortMode = 1
                                }
                            }
                        }
                    }
                }
                
                // Divider line
                Rectangle {
                    width: parent.width
                    height: 1
                    color: EUITheme.colorDivider
                    opacity: 0.5
                }
                
                // ========== File Extension Settings ==========
                Column {
                    width: parent.width
                    spacing: EUITheme.spacingM * 1.2
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "File Extension Handling")
                        font.pixelSize: EUITheme.fontH3
                        font.weight: EUITheme.fontWeightMedium
                        color: EUITheme.colorText
                    }
                    
                    Text {
                        text: I18n.tr("SettingsDialog", "Control whether file extensions are preserved during renaming")
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextSubtle
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    
                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingM
                        
                        Rectangle {
                            width: 48
                            height: 48
                            color: "transparent"
                            border.color: ignoreExtensionSwitch.checked ? EUITheme.colorPrimary : EUITheme.colorBorder
                            border.width: 2
                            radius: 24
                            
                            Rectangle {
                                width: 24
                                height: 24
                                anchors.centerIn: parent
                                color: ignoreExtensionSwitch.checked ? EUITheme.colorPrimary : "transparent"
                                radius: 12
                                
                                Behavior on color {
                                    ColorAnimation { duration: EUITheme.animationFast }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ignoreExtensionSwitch.checked = !ignoreExtensionSwitch.checked
                            }
                        }
                        
                        Column {
                            width: parent.width - 48 - parent.spacing
                            spacing: EUITheme.spacingXS
                            
                            Text {
                                text: I18n.tr("SettingsDialog", "Ignore File Extensions")
                                font.pixelSize: EUITheme.fontBody
                                font.weight: EUITheme.fontWeightMedium
                                color: EUITheme.colorText
                            }
                            
                            Text {
                                text: ignoreExtensionSwitch.checked 
                                    ? I18n.tr("SettingsDialog", "Enabled - File extensions will be removed during renaming")
                                    : I18n.tr("SettingsDialog", "Disabled - File extensions will be preserved (recommended)")
                                font.pixelSize: EUITheme.fontCaption
                                color: EUITheme.colorTextSubtle
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                        
                        Switch {
                            id: ignoreExtensionSwitch
                            visible: false
                            checked: mainController.settings.ignoreExtension
                            
                            onCheckedChanged: {
                                mainController.settings.ignoreExtension = checked
                            }
                        }
                    }
                }
            }
        }
        
        // Bottom buttons (fixed at bottom)
        Row {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width
            spacing: EUITheme.spacingM
            layoutDirection: Qt.RightToLeft
            
            EButton {
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("SettingsDialog", "Close")
                implicitWidth: 120
                
                onClicked: {
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
