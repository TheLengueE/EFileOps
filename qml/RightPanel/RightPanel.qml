import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import EUI
import ".."
import "../rules"

// ========== Right Rule Pipeline Editor ==========
Rectangle {
    id: root
    color: EUITheme.colorCard

    // Left divider line
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: EUITheme.colorDivider
    }

    // Three-section structure
    Column {
        anchors.fill: parent
        anchors.leftMargin: 1  // Leave space for divider line
        spacing: 0

        // ========== Section 1: Add Rule Entry (Light) ==========
        RightAddRuleButton {
            id: addRuleButton
            onAddRuleClicked: ruleTypeSelector.open()
        }

        // ========== Section 2: Rule List (Core, Draggable) ==========
        RightRuleList {
            width: parent.width
            height: parent.height - addRuleButton.height - configButtons.height
            model: rulesModel
            
            onRuleDeleted: (index) => {
                var response = mainController.removeRule(index)
                if (response.success) {
                    rulesModel.remove(index)
                } else {
                    console.error("Failed to delete rule:", response.message)
                }
            }
            
            onRuleClicked: (index, config) => {
                editingRuleIndex = index
                openEditDialog(config)
            }
            
            onRuleMoveUp: (index) => {
                if (index > 0) {
                    var response = mainController.moveRule(index, index - 1)
                    if (response.success) {
                        rulesModel.move(index, index - 1, 1)
                    } else {
                        console.error("Failed to move rule up:", response.message)
                    }
                }
            }
            
            onRuleMoveDown: (index) => {
                if (index < rulesModel.count - 1) {
                    var response = mainController.moveRule(index, index + 1)
                    if (response.success) {
                        rulesModel.move(index, index + 1, 1)
                    } else {
                        console.error("Failed to move rule down:", response.message)
                    }
                }
            }
        }

        // ========== Section 3: Configuration Management (Secondary) ==========
        RightConfigButtons {
            id: configButtons
            onSaveClicked: {
                if (rulesModel.count === 0) {
                    console.warn("No rules to save")
                    return
                }
                saveFileDialog.open()
            }
            
            onImportClicked: {
                loadFileDialog.open()
            }
        }
    }


    // Rule list model
    ListModel {
        id: rulesModel
    }

    // Track which rule is being edited (-1 = adding new rule)
    property int editingRuleIndex: -1

    // ========== Rule Type Selector ==========
    RuleTypeSelector {
        id: ruleTypeSelector
        
        onRuleTypeSelected: function(ruleType) {
            // Open corresponding config dialog based on rule type
            switch(ruleType) {
                case "replace":
                    replaceRuleConfig.open()
                    break
                case "remove":
                    removeRuleConfig.open()
                    break
                case "format":
                    formatRuleConfig.open()
                    break
                case "add":
                    addRuleConfig.open()
                    break
                case "numbering":
                    numberingRuleConfig.open()
                    break
                case "dateTime":
                    dateTimeRuleConfig.open()
                    break
            }
        }
    }
    
    // ========== Various Rule Configuration Dialogs ==========
    ReplaceRuleConfig {
        id: replaceRuleConfig
        
        onRuleConfigured: function(config) { applyRuleConfig(config) }
        
        onBackToSelector: {
            editingRuleIndex = -1
            replaceRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    RemoveRuleConfig {
        id: removeRuleConfig
        onRuleConfigured: function(config) { applyRuleConfig(config) }
        
        onBackToSelector: {
            editingRuleIndex = -1
            removeRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    FormatRuleConfig {
        id: formatRuleConfig
        onRuleConfigured: function(config) { applyRuleConfig(config) }
        
        onBackToSelector: {
            editingRuleIndex = -1
            formatRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    AddRuleConfig {
        id: addRuleConfig
        onRuleConfigured: function(config) { applyRuleConfig(config) }
        
        onBackToSelector: {
            editingRuleIndex = -1
            addRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    NumberingRuleConfig {
        id: numberingRuleConfig
        onRuleConfigured: function(config) { applyRuleConfig(config) }
        
        onBackToSelector: {
            editingRuleIndex = -1
            numberingRuleConfig.close()
            ruleTypeSelector.open()
        }
    }

    DateTimeRuleConfig {
        id: dateTimeRuleConfig
        onRuleConfigured: function(config) { applyRuleConfig(config) }

        onBackToSelector: {
            editingRuleIndex = -1
            dateTimeRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    // Open the corresponding edit dialog pre-filled with existing config
    function openEditDialog(config) {
        switch (config.ruleType) {
            case "replace":
                replaceRuleConfig.findText      = config.findText || ""
                replaceRuleConfig.replaceText   = config.replaceText || ""
                replaceRuleConfig.caseSensitive = config.caseSensitive || false
                replaceRuleConfig.open()
                break
            case "remove":
                removeRuleConfig.keyword        = config.keyword || ""
                removeRuleConfig.caseSensitive  = config.caseSensitive || false
                removeRuleConfig.open()
                break
            case "format":
                formatRuleConfig.selectedFormat = config.caseType || 0
                formatRuleConfig.open()
                break
            case "add":
            case "addPrefix":
            case "addSuffix":
                addRuleConfig.textToAdd = config.text || ""
                addRuleConfig.isPrefix  = (config.ruleType === "addPrefix" || config.isPrefix === true)
                addRuleConfig.open()
                break
            case "numbering":
                numberingRuleConfig.position      = config.position || 0
                numberingRuleConfig.startNumber   = config.startNumber || 1
                numberingRuleConfig.paddingLength = config.paddingLength || 3
                numberingRuleConfig.separator     = config.separator || "_"
                numberingRuleConfig.open()
                break
            case "DateTime":
                dateTimeRuleConfig.position      = config.isPrefix ? 0 : 1
                dateTimeRuleConfig.formatPreset  = ["YYYY-MM-DD","YYYYMMDD","MM-DD-YYYY","DD.MM.YYYY","YYYY-MM-DD_HH-mm"].indexOf(config.format)
                if (dateTimeRuleConfig.formatPreset < 0) {
                    dateTimeRuleConfig.formatPreset = 5
                    dateTimeRuleConfig.customFormat = config.format || ""
                }
                dateTimeRuleConfig.timeSource    = config.useModifiedTime ? 0 : 1
                dateTimeRuleConfig.separator     = config.separator || "_"
                dateTimeRuleConfig.skipReset     = true
                dateTimeRuleConfig.open()
                break
        }
    }

    // Apply a rule config: update existing rule if editing, otherwise add new
    function applyRuleConfig(config) {
        var idx = editingRuleIndex
        editingRuleIndex = -1
        if (idx >= 0) {
            // Edit mode: update rule in engine and model
            var response = mainController.updateRule(idx, config)
            if (response.success) {
                rulesModel.set(idx, {
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to update rule:", response.message)
            }
        } else {
            // Add mode
            var resp = mainController.addRule(config.ruleType, config)
            if (resp.success) {
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", resp.message)
            }
        }
    }

    // Generate rule description
    function generateDescription(config) {
        switch(config.ruleType) {
            case "replace":
                var desc = I18n.tr("RightPanel", "Find: \"%1\" → Replace: \"%2\"")
                    .replace("%1", config.findText)
                    .replace("%2", config.replaceText || "(empty)")
                if (config.caseSensitive) desc += " " + I18n.tr("RightPanel", "[Case Sensitive]")
                return desc
            case "remove":
                var removeDesc = I18n.tr("RightPanel", "Remove containing keyword: \"%1\"").replace("%1", config.keyword)
                if (config.caseSensitive) removeDesc += " " + I18n.tr("RightPanel", "[Case Sensitive]")
                return removeDesc
            case "addPrefix":
                return I18n.tr("RightPanel", "Add prefix: \"%1\"").replace("%1", config.text)
            case "addSuffix":
                return I18n.tr("RightPanel", "Add suffix: \"%1\"").replace("%1", config.text)
            case "format":
                var formatNames = [
                    I18n.tr("RightPanel", "All Uppercase"),
                    I18n.tr("RightPanel", "All Lowercase"),
                    I18n.tr("RightPanel", "Capitalize First"),
                    I18n.tr("RightPanel", "Capitalize Words")
                ]
                return I18n.tr("RightPanel", "Format: %1").replace("%1", formatNames[config.caseType] || I18n.tr("RightPanel", "Unknown Format"))
            case "numbering":
                var posText = config.position === 0 ? I18n.tr("RightPanel", "Prefix") : I18n.tr("RightPanel", "Suffix")
                var paddingText = config.paddingLength > 0 ? 
                    I18n.tr("RightPanel", "%1 Digits").replace("%1", config.paddingLength) :
                    I18n.tr("RightPanel", "No Padding")
                return I18n.tr("RightPanel", "Numbering (%1, Start: %2, %3)")
                    .replace("%1", posText)
                    .replace("%2", config.startNumber)
                    .replace("%3", paddingText)
            case "DateTime":
                var dtPos = config.isPrefix ? I18n.tr("RightPanel", "Prefix") : I18n.tr("RightPanel", "Suffix")
                var dtSrc = config.useModifiedTime ? I18n.tr("RightPanel", "Modified") : I18n.tr("RightPanel", "Created")
                return I18n.tr("RightPanel", "Date/Time %1 (%2): \"%3\"")
                    .replace("%1", dtPos)
                    .replace("%2", dtSrc)
                    .replace("%3", config.format)
            default:
                return config.description || ""
        }
    }
    
    // Rebuild UI model from RuleEngine
    function refreshRulesFromEngine() {
        rulesModel.clear()
        
        var ruleCount = mainController.ruleEngine.ruleCount
        for (var i = 0; i < ruleCount; i++) {
            var rule = mainController.ruleEngine.getRule(i)
            if (rule) {
                var config = {
                    ruleType: rule.ruleType,
                    name: rule.ruleName,
                    enabled: rule.enabled
                }
                
                // Add rule-specific fields based on type
                if (rule.ruleType === "replace") {
                    config.findText = rule.findText || ""
                    config.replaceText = rule.replaceText || ""
                    config.caseSensitive = rule.caseSensitive || false
                } else if (rule.ruleType === "remove") {
                    config.keyword = rule.keyword || ""
                    config.caseSensitive = rule.caseSensitive || false
                } else if (rule.ruleType === "addPrefix") {
                    config.text = rule.prefix || ""
                } else if (rule.ruleType === "addSuffix") {
                    config.text = rule.suffix || ""
                } else if (rule.ruleType === "format") {
                    config.caseType = rule.caseType || 0
                } else if (rule.ruleType === "numbering") {
                    config.position = rule.position || 0
                    config.startNumber = rule.startNumber || 1
                    config.paddingLength = rule.paddingLength || 3
                }
                
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            }
        }
    }
    
    // ========== File Dialogs ==========
    
    // Save configuration dialog
    FileDialog {
        id: saveFileDialog
        title: I18n.tr("RightPanel", "Save Rules Configuration")
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        defaultSuffix: "json"
        
        onAccepted: {
            var filePath = selectedFile.toString().replace("file:///", "")
            var response = mainController.saveRulesConfig(filePath)
            
            if (response.success) {
                console.log("Configuration saved:", response.message)
            } else {
                console.error("Failed to save configuration:", response.message)
            }
        }
    }
    
    // Load configuration dialog
    FileDialog {
        id: loadFileDialog
        title: I18n.tr("RightPanel", "Load Rules Configuration")
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON files (*.json)", "All files (*)"]
        
        onAccepted: {
            var filePath = selectedFile.toString().replace("file:///", "")
            var response = mainController.loadRulesConfig(filePath)
            
            if (response.success) {
                console.log("Configuration loaded:", response.message)
                // Refresh UI from loaded rules
                refreshRulesFromEngine()
            } else {
                console.error("Failed to load configuration:", response.message)
            }
        }
    }
}


