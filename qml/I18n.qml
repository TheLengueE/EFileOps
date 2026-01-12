pragma Singleton
import QtQuick

/**
 * @brief Global translation helper singleton
 *
 * Design principles:
 * - Singleton pattern: Global unique instance
 * - Auto refresh: Monitor translationManager signals
 * - Simple API: tr(context, text) unified interface
 *
 * Usage:
 * import "." // Ensure singleton access
 *
 * Label {
 *     text: I18n.tr("Main", "Hello World")
 * }
 */
QtObject {
    id: root

    // Language version number - auto-increments on language switch, triggers all bindings to update
    property int version: 0

    // Current language code (for external access)
    property string currentLanguage: "en_US"

    // Status message (optional: for status bar display)
    property string statusMessage: ""

    /**
     * @brief Translation function
     * @param context Context (usually QML filename, like "Main")
     * @param sourceText Source text (English original)
     * @return Translated text
     *
     * Core technique: Establish dependency by reading version property
     * When version changes, all bindings calling tr() will automatically re-evaluate
     */
    function tr(context, sourceText) {
        // **CRITICAL**: Must read version property to establish binding dependency
        // When version changes, QML will automatically re-call this function
        var v = version;
        
        // Call qsTranslate to get the translated text
        var translated = qsTranslate(context, sourceText);
        
        // Return translated text, or source text if translation is empty
        return translated || sourceText;
    }

    // Monitor translation manager's language change signal
    Component.onCompleted: {
        // Connect signal
        if (typeof translationManager !== "undefined") {
            translationManager.languageChanged.connect(onLanguageChanged);

            // Initialize current language
            var state = translationManager.handleRequest("translation", "getState", {});
            if (state.success) {
                currentLanguage = state.data.currentLocale;
            }
            console.log("✓ I18n singleton initialized, current language:", currentLanguage);
        } else {
            console.warn("⚠️  translationManager not found");
        }
    }

    /**
     * @brief Language switch callback
     */
    function onLanguageChanged(response) {
        console.log("[I18n] Language changed, incrementing version:", version, "→", version + 1);
        version++; // Trigger all tr() binding updates

        if (response.success) {
            currentLanguage = response.data.currentLocale; // Update current language
            statusMessage = response.message;
            console.log("[I18n] New language:", response.data.currentLocale);
        } else {
            console.error("[I18n] Language change failed:", response.message);
        }
    }

    /**
     * @brief Convenience method: Switch language
     * @param locale Language code (e.g. "zh_CN", "en_US")
     */
    function switchLanguage(locale) {
        if (typeof translationManager === "undefined") {
            console.error("[I18n] translationManager not available");
            return null;
        }
        console.log("[I18n] Requesting language switch:", locale);
        var response = translationManager.handleRequest("translation", "switch", {
            locale: locale
        });
        if (!response.success) {
            console.error("[I18n] Switch failed:", response.message);
        }
        return response;
    }

    /**
     * @brief Get current language
     */
    function getCurrentLocale() {
        if (typeof translationManager === "undefined") {
            return "unknown";
        }
        var state = translationManager.handleRequest("translation", "getState", {});
        return state.success ? state.data.currentLocale : "unknown";
    }

    /**
     * @brief Get available language list
     */
    function getAvailableLocales() {
        if (typeof translationManager === "undefined") {
            return [];
        }
        var response = translationManager.handleRequest("translation", "getAvailable", {});
        return response.success ? response.data.availableLocales : [];
    }
}
