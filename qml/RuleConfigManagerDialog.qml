import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import EUI
import "."

// ========== Rule Configuration Manager Dialog ==========
Popup {
    id: root
    
    // Properties
    property string mode: "save"  // "save" or "load"
    property string selectedConfigName: ""
    
    signal configSaved(string configName)
    signal configLoaded(string configName)
    signal configDeleted(string configName)
    
    // Center display
    anchors.centerIn: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape
    
    width: 500
    height: root.mode === "save" ? 520 : 480
    padding: 0
    
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
    
    // Refresh config list when opened
    onOpened: {
        refreshConfigList()
        configNameInput.text = ""
        configNameInput.forceActiveFocus()
    }
    
    // Close button (top-right corner)
    Rectangle {
        width: 40
        height: 40
        color: closeMouseArea.containsMouse ? EUITheme.colorPrimarySoft : "transparent"
        radius: EUITheme.radiusSmall
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 8
        anchors.topMargin: 8
        z: 100
        
        IconImage {
            source: "../icons/close-x.svg"
            width: 22
            height: 22
            anchors.centerIn: parent
            color: EUITheme.colorPrimary
        }
        
        MouseArea {
            id: closeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.close()
        }
        
        ToolTip.visible: closeMouseArea.containsMouse
        ToolTip.text: I18n.tr("RuleConfigManagerDialog", "Close")
        ToolTip.delay: 500
    }
    
    // Content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: EUITheme.spacingXL * 1.5
        spacing: EUITheme.spacingL
        
        // Title
        Row {
            Layout.fillWidth: true
            spacing: EUITheme.spacingM
            
            IconImage {
                source: root.mode === "save" ? "../icons/save.svg" : "../icons/download.svg"
                width: 28
                height: 28
                color: EUITheme.colorPrimary
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: root.mode === "save" 
                    ? I18n.tr("RuleConfigManagerDialog", "Save Rule Configuration")
                    : I18n.tr("RuleConfigManagerDialog", "Load Rule Configuration")
                font.pixelSize: EUITheme.fontH2
                font.weight: EUITheme.fontWeightSemiBold
                color: EUITheme.colorText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Configuration name input (for save mode)
        Column {
            Layout.fillWidth: true
            spacing: EUITheme.spacingS
            visible: root.mode === "save"
            
            Text {
                text: I18n.tr("RuleConfigManagerDialog", "Configuration Name")
                font.pixelSize: EUITheme.fontBody
                font.weight: EUITheme.fontWeightMedium
                color: EUITheme.colorText
            }
            
            TextField {
                id: configNameInput
                width: parent.width
                placeholderText: I18n.tr("RuleConfigManagerDialog", "Enter configuration name")
                font.pixelSize: EUITheme.fontBody
                
                background: Rectangle {
                    color: configNameInput.activeFocus ? EUITheme.colorBg : EUITheme.colorMutedBg
                    border.color: configNameInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 2
                    radius: EUITheme.radiusSmall
                }
                
                onAccepted: {
                    if (text.trim().length > 0) {
                        saveButton.clicked()
                    }
                }
            }
        }
        
        // Saved configurations list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: EUITheme.spacingS
            
            Column {
                Layout.fillWidth: true
                spacing: EUITheme.spacingXS
                
                Row {
                    width: parent.width
                    spacing: EUITheme.spacingM
                    
                    Text {
                        text: I18n.tr("RuleConfigManagerDialog", "Saved Configurations")
                        font.pixelSize: EUITheme.fontBody
                        font.weight: EUITheme.fontWeightMedium
                        color: EUITheme.colorText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "(" + configListModel.count + ")"
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextSubtle
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Config directory path display
                Text {
                    width: parent.width
                    text: AppSettings.getRuleConfigDirectory()
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    elide: Text.ElideMiddle
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mainController.openFileInExplorer(parent.text)
                        }
                        
                        ToolTip.visible: containsMouse
                        ToolTip.text: I18n.tr("RuleConfigManagerDialog", "Click to open in file explorer")
                        ToolTip.delay: 500
                    }
                }
            }
            
            // Config list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: EUITheme.colorBg
                border.color: EUITheme.colorBorder
                border.width: 1
                radius: EUITheme.radiusSmall
                
                ListView {
                    id: configListView
                    anchors.fill: parent
                    anchors.margins: EUITheme.spacingS
                    clip: true
                    spacing: EUITheme.spacingS
                    
                    model: ListModel {
                        id: configListModel
                    }
                    
                    delegate: Rectangle {
                        width: configListView.width
                        height: 56
                        color: (root.mode === "load" && model.isSelected) ? EUITheme.colorPrimarySoft : 
                               (root.mode === "load" && itemMouseArea.containsMouse ? EUITheme.colorMutedBg : "transparent")
                        border.color: (root.mode === "load" && model.isSelected) ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: (root.mode === "load" && model.isSelected) ? 2 : 1
                        radius: EUITheme.radiusSmall
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: EUITheme.spacingM
                            spacing: EUITheme.spacingM
                            
                            // Config icon
                            Rectangle {
                                width: 32
                                height: 32
                                color: EUITheme.colorPrimarySoft
                                radius: EUITheme.radiusSmall
                                anchors.verticalCenter: parent.verticalCenter
                                
                                IconImage {
                                    source: "../icons/clipboard.svg"
                                    width: 20
                                    height: 20
                                    anchors.centerIn: parent
                                    color: EUITheme.colorPrimary
                                }
                            }
                            
                            // Config name
                            Text {
                                text: model.name
                                font.pixelSize: EUITheme.fontBody
                                font.weight: model.isSelected ? EUITheme.fontWeightMedium : Font.Normal
                                color: EUITheme.colorText
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 110
                                elide: Text.ElideRight
                            }
                            
                            Item { width: 1; height: 1 }
                            
                            // Delete button
                            Rectangle {
                                width: 32
                                height: 32
                                color: deleteMouseArea.containsMouse ? Qt.rgba(239, 68, 68, 0.1) : "transparent"
                                radius: EUITheme.radiusSmall
                                anchors.verticalCenter: parent.verticalCenter
                                
                                IconImage {
                                    source: "../icons/trash.svg"
                                    width: 18
                                    height: 18
                                    anchors.centerIn: parent
                                    color: deleteMouseArea.containsMouse ? "#EF4444" : EUITheme.colorTextSubtle
                                }
                                
                                MouseArea {
                                    id: deleteMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        mouse.accepted = true
                                        deleteConfirmDialog.configName = model.name
                                        deleteConfirmDialog.open()
                                    }
                                }
                                
                                ToolTip.visible: deleteMouseArea.containsMouse
                                ToolTip.text: I18n.tr("RuleConfigManagerDialog", "Delete")
                                ToolTip.delay: 500
                            }
                        }
                        
                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: root.mode === "load"  // Only enable hover in load mode
                            cursorShape: root.mode === "load" ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: root.mode === "load"  // Only enable clicks in load mode
                            z: -1
                            onClicked: {
                                // Clear all selections
                                for (var i = 0; i < configListModel.count; i++) {
                                    configListModel.setProperty(i, "isSelected", false)
                                }
                                // Set current selection
                                configListModel.setProperty(index, "isSelected", true)
                                root.selectedConfigName = model.name
                            }
                            onDoubleClicked: {
                                if (root.mode === "load") {
                                    loadButton.clicked()
                                }
                            }
                        }
                    }
                    
                    // Empty state
                    Text {
                        visible: configListModel.count === 0
                        anchors.centerIn: parent
                        text: I18n.tr("RuleConfigManagerDialog", "No saved configurations")
                        font.pixelSize: EUITheme.fontBody
                        color: EUITheme.colorTextSubtle
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
        
        // Bottom buttons
        Row {
            Layout.fillWidth: true
            spacing: 0
            layoutDirection: Qt.RightToLeft
            
            EButton {
                id: saveButton
                visible: root.mode === "save"
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("RuleConfigManagerDialog", "Save")
                implicitWidth: 100
                enabled: configNameInput.text.trim().length > 0
                
                onClicked: {
                    var configName = configNameInput.text.trim()
                    if (configName.length > 0) {
                        var response = mainController.saveRulesConfigByName(configName)
                        if (response.success) {
                            root.configSaved(configName)
                            refreshConfigList()
                            configNameInput.text = ""
                        }
                    }
                }
            }
            
            EButton {
                id: loadButton
                visible: root.mode === "load"
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("RuleConfigManagerDialog", "Load")
                implicitWidth: 100
                enabled: root.selectedConfigName.length > 0
                
                onClicked: {
                    if (root.selectedConfigName.length > 0) {
                        var response = mainController.loadRulesConfigByName(root.selectedConfigName)
                        if (response.success) {
                            root.configLoaded(root.selectedConfigName)
                            root.close()
                        }
                    }
                }
            }
        }
    }
    
    // Delete confirmation dialog
    EDialog {
        id: deleteConfirmDialog
        
        property string configName: ""
        
        title: I18n.tr("RuleConfigManagerDialog", "Confirm Delete")
        message: I18n.tr("RuleConfigManagerDialog", "Are you sure you want to delete configuration '%1'? This action cannot be undone.").arg(configName)
        confirmText: I18n.tr("RuleConfigManagerDialog", "Delete")
        cancelText: I18n.tr("RuleConfigManagerDialog", "Cancel")
        showCancel: true
        isDanger: true  // Red delete button
        
        onConfirmed: {
            var response = mainController.deleteRulesConfigByName(configName)
            if (response.success) {
                root.configDeleted(configName)
                refreshConfigList()
                root.selectedConfigName = ""
            }
        }
    }
    
    // Functions
    function refreshConfigList() {
        configListModel.clear()
        var configs = mainController.getSavedRuleConfigNames()
        for (var i = 0; i < configs.length; i++) {
            configListModel.append({
                name: configs[i],
                isSelected: false
            })
        }
    }
    
    // Animation
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: EUITheme.animationNormal
        }
        NumberAnimation {
            property: "scale"
            from: 0.95
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
