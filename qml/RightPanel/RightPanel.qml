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
            
            onRuleDoubleClicked: (index) => {
                // TODO: Open edit dialog
                console.log("Edit rule:", index)
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
            }
        }
    }
    
    // ========== Various Rule Configuration Dialogs ==========
    ReplaceRuleConfig {
        id: replaceRuleConfig
        
        onRuleConfigured: function(config) {
            // Call MainController to add rule
            var response = mainController.addRule("replace", config)
            
            if (response.success) {
                // Add to UI list
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", response.message)
            }
        }
        
        onBackToSelector: {
            replaceRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    RemoveRuleConfig {
        id: removeRuleConfig
        onRuleConfigured: function(config) {
            // Call MainController to add rule
            var response = mainController.addRule(config.ruleType, config)
            
            if (response.success) {
                // Add to UI list
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", response.message)
            }
        }
        
        onBackToSelector: {
            removeRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    FormatRuleConfig {
        id: formatRuleConfig
        onRuleConfigured: function(config) {
            // Call MainController to add rule
            var response = mainController.addRule(config.ruleType, config)
            
            if (response.success) {
                // Add to UI list
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", response.message)
            }
        }
        
        onBackToSelector: {
            formatRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    AddRuleConfig {
        id: addRuleConfig
        onRuleConfigured: function(config) {
            // Call MainController to add rule
            var response = mainController.addRule(config.ruleType, config)
            
            if (response.success) {
                // Add to UI list
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", response.message)
            }
        }
        
        onBackToSelector: {
            addRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    NumberingRuleConfig {
        id: numberingRuleConfig
        onRuleConfigured: function(config) {
            // Call MainController to add rule
            var response = mainController.addRule(config.ruleType, config)
            
            if (response.success) {
                // Add to UI list
                rulesModel.append({
                    name: config.name,
                    description: generateDescription(config),
                    config: config
                })
            } else {
                console.error("Failed to add rule:", response.message)
            }
        }
        
        onBackToSelector: {
            numberingRuleConfig.close()
            ruleTypeSelector.open()
        }
    }
    
    // Generate rule description
    function generateDescription(config) {
        switch(config.ruleType) {
            case "replace":
                var desc = "Find: \"" + config.findText + "\" → Replace: \"" + config.replaceText + "\""
                if (config.caseSensitive) desc += " [Case Sensitive]"
                return desc
            case "remove":
                return "Remove containing keyword: \"" + config.keyword + "\"" + (config.caseSensitive ? " [Case Sensitive]" : "")
            case "addPrefix":
                return "Add prefix: \"" + config.text + "\""
            case "addSuffix":
                return "Add suffix: \"" + config.text + "\""
            case "format":
                var formatNames = ["All Uppercase", "All Lowercase", "Capitalize First", "Capitalize Words"];
                return "Format: " + (formatNames[config.caseType] || "Unknown Format")
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


