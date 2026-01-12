pragma Singleton
import QtQuick

QtObject {
    // ========== Theme Mode Toggle ==========
    property bool isDarkMode: false

    // ========== Color System ==========

    // Brand / Semantic (Global constants)
    readonly property color colorPrimary: "#3155F5"
    readonly property color colorPrimarySoft: isDarkMode ? Qt.rgba(49 / 255, 85 / 255, 245 / 255, 0.15) : Qt.rgba(49 / 255, 85 / 255, 245 / 255, 0.08)
    readonly property color colorDanger: "#E54545"
    readonly property color colorSuccess: "#10B981"
    readonly property color colorWarning: "#F59E0B"

    // Neutrals (Theme-dependent)
    readonly property color colorBg: isDarkMode ? "#0F1419" : "#F3F4F6"
    readonly property color colorCard: isDarkMode ? "#1A1F26" : "#FFFFFF"
    readonly property color colorMutedBg: isDarkMode ? "#131820" : "#F9FAFB"
    readonly property color colorBorder: isDarkMode ? "#2D333D" : "#D4D4D8"
    readonly property color colorDivider: isDarkMode ? "#242931" : "#E5E7EB"

    // Text (Theme-dependent)
    readonly property color colorText: isDarkMode ? "#E5E7EB" : "#111827"
    readonly property color colorTextSubtle: isDarkMode ? "#9CA3AF" : "#6B7280"
    readonly property color colorTextDisabled: isDarkMode ? "#4B5563" : "#9CA3AF"

    // ========== Font System ==========
    readonly property int fontH1: 28
    readonly property int fontH2: 20
    readonly property int fontH3: 16
    readonly property int fontBody: 14
    readonly property int fontCaption: 12

    readonly property int fontWeightRegular: Font.Normal      // 400
    readonly property int fontWeightMedium: Font.Medium       // 500
    readonly property int fontWeightSemiBold: Font.DemiBold   // 600

    // ========== Spacing System (8px system) ==========
    readonly property int spacingXSmall: 4
    readonly property int spacingXS: 4
    readonly property int spacingSmall: 8
    readonly property int spacingS: 8
    readonly property int spacingMedium: 12
    readonly property int spacingM: 12
    readonly property int spacingLarge: 16
    readonly property int spacingL: 16
    readonly property int spacingXL: 24
    readonly property int spacingXXL: 32

    // ========== Border Radius ==========
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 12
    readonly property int radiusPill: 999

    // ========== Shadow ==========
    readonly property int shadowRadius: 8
    readonly property color shadowColor: Qt.rgba(15 / 255, 23 / 255, 42 / 255, 0.08)
    readonly property int shadowOffsetY: 2

    readonly property int shadowRadiusHover: 10
    readonly property color shadowColorHover: Qt.rgba(15 / 255, 23 / 255, 42 / 255, 0.12)
    readonly property int shadowOffsetYHover: 4

    // ========== Sizes ==========
    readonly property int buttonHeight: 38
    readonly property int inputHeight: 38
    readonly property int iconSize: 20
    readonly property int iconSizeSmall: 16
    readonly property int iconSizeLarge: 24

    // ========== Animation Duration ==========
    readonly property int animationFast: 150
    readonly property int animationNormal: 200
    readonly property int animationSlow: 300
}
