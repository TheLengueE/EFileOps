import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Date/Time Stamp Rule Configuration Dialog ==========
Popup {
    id: root

    // 0=prefix, 1=suffix
    property int    position:        0
    // 0=ISO  1=Compact  2=US  3=EU  4=DateTime  5=Custom
    property int    formatPreset:    0
    property string customFormat:    ""
    // 0=Modified time, 1=Created time
    property int    timeSource:      0
    property string separator:       "_"

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
            text: I18n.tr("DateTimeRuleConfig", "Date/Time Stamp Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }

        // ── Position ──────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("DateTimeRuleConfig", "Position") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            Row {
                width: parent.width
                spacing: EUITheme.spacingM

                // Prefix button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 52
                    radius: EUITheme.radiusMedium
                    color: root.position === 0 ? Qt.rgba(59, 130, 246, 0.1) : EUITheme.colorInput
                    border.width: root.position === 0 ? 2 : 1
                    border.color: root.position === 0 ? EUITheme.colorPrimary : EUITheme.colorBorder

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Image {
                            source: "../../icons/arrow-left.svg"
                            width: 20; height: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: I18n.tr("DateTimeRuleConfig", "Prefix")
                            font.pixelSize: EUITheme.fontCaption
                            color: root.position === 0 ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.position === 0 ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.position = 0; updatePreview() }
                    }
                }

                // Suffix button
                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: 52
                    radius: EUITheme.radiusMedium
                    color: root.position === 1 ? Qt.rgba(59, 130, 246, 0.1) : EUITheme.colorInput
                    border.width: root.position === 1 ? 2 : 1
                    border.color: root.position === 1 ? EUITheme.colorPrimary : EUITheme.colorBorder

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Image {
                            source: "../../icons/arrow-right.svg"
                            width: 20; height: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: I18n.tr("DateTimeRuleConfig", "Suffix")
                            font.pixelSize: EUITheme.fontCaption
                            color: root.position === 1 ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.position === 1 ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.position = 1; updatePreview() }
                    }
                }
            }
        }

        // ── Date Format ───────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("DateTimeRuleConfig", "Date Format") + " *"
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            // Preset grid  (2 columns × 3 rows)
            Grid {
                width: parent.width
                columns: 2
                columnSpacing: EUITheme.spacingM
                rowSpacing: EUITheme.spacingS

                Repeater {
                    model: [
                        { label: I18n.tr("DateTimeRuleConfig", "ISO (YYYY-MM-DD)"),       fmt: "YYYY-MM-DD" },
                        { label: I18n.tr("DateTimeRuleConfig", "Compact (YYYYMMDD)"),      fmt: "YYYYMMDD" },
                        { label: I18n.tr("DateTimeRuleConfig", "US (MM-DD-YYYY)"),         fmt: "MM-DD-YYYY" },
                        { label: I18n.tr("DateTimeRuleConfig", "EU (DD.MM.YYYY)"),         fmt: "DD.MM.YYYY" },
                        { label: I18n.tr("DateTimeRuleConfig", "Date+Time (YYYY-MM-DD_HH-mm)"), fmt: "YYYY-MM-DD_HH-mm" },
                        { label: I18n.tr("DateTimeRuleConfig", "Custom"),                  fmt: "" }
                    ]

                    delegate: Rectangle {
                        width: (parent.width - EUITheme.spacingM) / 2
                        height: 36
                        radius: EUITheme.radiusMedium
                        color: root.formatPreset === index ? Qt.rgba(59, 130, 246, 0.1) : EUITheme.colorInput
                        border.width: root.formatPreset === index ? 2 : 1
                        border.color: root.formatPreset === index ? EUITheme.colorPrimary : EUITheme.colorBorder

                        Text {
                            anchors.centerIn: parent
                            anchors.leftMargin: EUITheme.spacingS
                            anchors.rightMargin: EUITheme.spacingS
                            width: parent.width - EUITheme.spacingS * 2
                            text: modelData.label
                            font.pixelSize: EUITheme.fontCaption
                            color: root.formatPreset === index ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.formatPreset === index ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.formatPreset = index
                                if (index < 5) {
                                    root.customFormat = modelData.fmt
                                }
                                updatePreview()
                            }
                        }
                    }
                }
            }

            // Custom format input (visible only when "Custom" is selected)
            Column {
                width: parent.width
                spacing: EUITheme.spacingXS
                visible: root.formatPreset === 5

                Text {
                    text: I18n.tr("DateTimeRuleConfig", "Custom Format")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextMuted
                }

                ETextField {
                    id: customFormatField
                    width: parent.width
                    height: 40
                    placeholderText: "YYYY-MM-DD_{HH}-{mm}"
                    text: root.customFormat
                    onTextChanged: {
                        root.customFormat = text
                        updatePreview()
                    }
                }

                Text {
                    width: parent.width
                    text: I18n.tr("DateTimeRuleConfig", "Tokens: YYYY MM DD HH mm SS  or  {YYYY} {MM} {DD} {HH} {mm} {SS}")
                    font.pixelSize: 10
                    color: EUITheme.colorTextMuted
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ── Time Source ───────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("DateTimeRuleConfig", "Time Source")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            Row {
                width: parent.width
                spacing: EUITheme.spacingM

                Repeater {
                    model: [
                        I18n.tr("DateTimeRuleConfig", "Modified Time"),
                        I18n.tr("DateTimeRuleConfig", "Created Time")
                    ]

                    delegate: Rectangle {
                        width: (parent.width - EUITheme.spacingM) / 2
                        height: 36
                        radius: EUITheme.radiusMedium
                        color: root.timeSource === index ? Qt.rgba(59, 130, 246, 0.1) : EUITheme.colorInput
                        border.width: root.timeSource === index ? 2 : 1
                        border.color: root.timeSource === index ? EUITheme.colorPrimary : EUITheme.colorBorder

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: EUITheme.fontCaption
                            color: root.timeSource === index ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.timeSource === index ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.timeSource = index; updatePreview() }
                        }
                    }
                }
            }
        }

        // ── Separator ─────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("DateTimeRuleConfig", "Separator")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            Row {
                width: parent.width
                spacing: EUITheme.spacingM

                Repeater {
                    model: ["_", "-", ".", " "]

                    delegate: Rectangle {
                        width: 48
                        height: 36
                        radius: EUITheme.radiusMedium
                        color: root.separator === modelData ? Qt.rgba(59, 130, 246, 0.1) : EUITheme.colorInput
                        border.width: root.separator === modelData ? 2 : 1
                        border.color: root.separator === modelData ? EUITheme.colorPrimary : EUITheme.colorBorder

                        Text {
                            anchors.centerIn: parent
                            text: modelData === " " ? I18n.tr("DateTimeRuleConfig", "Space") : modelData
                            font.pixelSize: EUITheme.fontBody
                            color: root.separator === modelData ? EUITheme.colorPrimary : EUITheme.colorText
                            font.weight: root.separator === modelData ? Font.DemiBold : Font.Normal
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.separator = modelData; updatePreview() }
                        }
                    }
                }
            }
        }

        // ── Preview ───────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("DateTimeRuleConfig", "Preview")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            Rectangle {
                width: parent.width
                height: 52
                color: EUITheme.colorMutedBg
                radius: EUITheme.radiusMedium
                border.width: 1
                border.color: EUITheme.colorBorder

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        id: beforePreview
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "example_file.jpg"
                        font.pixelSize: EUITheme.fontCaption
                        color: EUITheme.colorTextMuted
                    }

                    Text {
                        id: afterPreview
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        font.pixelSize: EUITheme.fontBody
                        font.weight: Font.Medium
                        color: EUITheme.colorPrimary
                    }
                }
            }
        }

        // ── Buttons ───────────────────────────────────────────────────────
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
                enabled: activeFormat().length > 0
                onClicked: {
                    var config = {
                        "ruleType":        "DateTime",
                        "name":            buildName(),
                        "isPrefix":        root.position === 0,
                        "format":          activeFormat(),
                        "useModifiedTime": root.timeSource === 0,
                        "separator":       root.separator
                    }
                    root.ruleConfigured(config)
                    root.close()
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    function activeFormat() {
        if (root.formatPreset === 5) return root.customFormat.trim()
        var presets = ["YYYY-MM-DD", "YYYYMMDD", "MM-DD-YYYY", "DD.MM.YYYY", "YYYY-MM-DD_HH-mm"]
        return presets[root.formatPreset]
    }

    function buildName() {
        var pos = root.position === 0
            ? I18n.tr("DateTimeRuleConfig", "Prefix")
            : I18n.tr("DateTimeRuleConfig", "Suffix")
        return I18n.tr("DateTimeRuleConfig", "Date/Time") + " " + pos + ": " + activeFormat()
    }

    function updatePreview() {
        var fmt    = activeFormat()
        if (fmt.length === 0) {
            afterPreview.text = "example_file.jpg"
            return
        }

        // Use a fixed sample date for preview: 2025-03-08 14:30:05
        var stamp = fmt
        stamp = stamp.replace("YYYY", "2025")
        stamp = stamp.replace("MM",   "03")
        stamp = stamp.replace("DD",   "08")
        stamp = stamp.replace("HH",   "14")
        stamp = stamp.replace("mm",   "30")
        stamp = stamp.replace("SS",   "05")
        // brace-style tokens
        stamp = stamp.replace("{YYYY}", "2025")
        stamp = stamp.replace("{MM}",   "03")
        stamp = stamp.replace("{DD}",   "08")
        stamp = stamp.replace("{HH}",   "14")
        stamp = stamp.replace("{mm}",   "30")
        stamp = stamp.replace("{SS}",   "05")

        var sep = root.separator
        if (root.position === 0) {
            afterPreview.text = stamp + sep + "example_file.jpg"
        } else {
            afterPreview.text = "example_file" + sep + stamp + ".jpg"
        }
    }

    // When true, skip the onOpened reset (used for edit mode)
    property bool skipReset: false

    onOpened: {
        if (skipReset) {
            skipReset = false
            updatePreview()
            return
        }
        root.position     = 0
        root.formatPreset = 0
        root.customFormat = ""
        root.timeSource   = 0
        root.separator    = "_"
        updatePreview()
    }

    // Open/close animation
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: EUITheme.animationNormal }
        NumberAnimation { property: "scale";   from: 0.9; to: 1.0; duration: EUITheme.animationNormal; easing.type: Easing.OutQuad }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: EUITheme.animationFast }
    }
}
