import QtQuick
import QtQuick.Controls
import EUI
import ".."

// ========== Delete Characters Rule Configuration Dialog ==========
Popup {
    id: root

    property int removeFirstCount: 0
    property int removeLastCount: 0
    property int rangeStart: 0
    property int rangeEnd: 0
    property bool removeDigits: false

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

        Text {
            text: I18n.tr("RemoveRuleConfig", "Delete Characters Rule")
            font.pixelSize: EUITheme.fontH2
            font.weight: EUITheme.fontWeightSemiBold
            color: EUITheme.colorText
        }

        Row {
            width: parent.width
            spacing: EUITheme.spacingM

            Column {
                width: (parent.width - parent.spacing) / 2
                spacing: EUITheme.spacingS

                Text {
                    text: I18n.tr("RemoveRuleConfig", "Delete First N")
                    font.pixelSize: EUITheme.fontBody
                    font.weight: Font.Medium
                    color: EUITheme.colorText
                }

                TextField {
                    id: firstCountInput
                    width: parent.width
                    placeholderText: "0"
                    text: String(root.removeFirstCount)
                    font.pixelSize: EUITheme.fontBody
                    validator: IntValidator { bottom: 0 }

                    onTextChanged: {
                        root.removeFirstCount = parseSafeInt(text)
                        updatePreview()
                    }

                    background: Rectangle {
                        color: firstCountInput.enabled ? "white" : EUITheme.colorMutedBg
                        border.color: firstCountInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: 1
                        radius: EUITheme.radiusMedium
                    }

                    leftPadding: EUITheme.spacingM
                    rightPadding: EUITheme.spacingM
                    topPadding: EUITheme.spacingS
                    bottomPadding: EUITheme.spacingS
                }
            }

            Column {
                width: (parent.width - parent.spacing) / 2
                spacing: EUITheme.spacingS

                Text {
                    text: I18n.tr("RemoveRuleConfig", "Delete Last N")
                    font.pixelSize: EUITheme.fontBody
                    font.weight: Font.Medium
                    color: EUITheme.colorText
                }

                TextField {
                    id: lastCountInput
                    width: parent.width
                    placeholderText: "0"
                    text: String(root.removeLastCount)
                    font.pixelSize: EUITheme.fontBody
                    validator: IntValidator { bottom: 0 }

                    onTextChanged: {
                        root.removeLastCount = parseSafeInt(text)
                        updatePreview()
                    }

                    background: Rectangle {
                        color: lastCountInput.enabled ? "white" : EUITheme.colorMutedBg
                        border.color: lastCountInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: 1
                        radius: EUITheme.radiusMedium
                    }

                    leftPadding: EUITheme.spacingM
                    rightPadding: EUITheme.spacingM
                    topPadding: EUITheme.spacingS
                    bottomPadding: EUITheme.spacingS
                }
            }
        }

        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("RemoveRuleConfig", "Delete Range A-B (1-based, inclusive)")
                font.pixelSize: EUITheme.fontBody
                font.weight: Font.Medium
                color: EUITheme.colorText
            }

            Row {
                width: parent.width
                spacing: EUITheme.spacingM

                TextField {
                    id: rangeStartInput
                    width: (parent.width - parent.spacing) / 2
                    placeholderText: I18n.tr("RemoveRuleConfig", "A (start)")
                    text: String(root.rangeStart)
                    font.pixelSize: EUITheme.fontBody
                    validator: IntValidator { bottom: 0 }

                    onTextChanged: {
                        root.rangeStart = parseSafeInt(text)
                        updatePreview()
                    }

                    background: Rectangle {
                        color: rangeStartInput.enabled ? "white" : EUITheme.colorMutedBg
                        border.color: rangeStartInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: 1
                        radius: EUITheme.radiusMedium
                    }

                    leftPadding: EUITheme.spacingM
                    rightPadding: EUITheme.spacingM
                    topPadding: EUITheme.spacingS
                    bottomPadding: EUITheme.spacingS
                }

                TextField {
                    id: rangeEndInput
                    width: (parent.width - parent.spacing) / 2
                    placeholderText: I18n.tr("RemoveRuleConfig", "B (end)")
                    text: String(root.rangeEnd)
                    font.pixelSize: EUITheme.fontBody
                    validator: IntValidator { bottom: 0 }

                    onTextChanged: {
                        root.rangeEnd = parseSafeInt(text)
                        updatePreview()
                    }

                    background: Rectangle {
                        color: rangeEndInput.enabled ? "white" : EUITheme.colorMutedBg
                        border.color: rangeEndInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                        border.width: 1
                        radius: EUITheme.radiusMedium
                    }

                    leftPadding: EUITheme.spacingM
                    rightPadding: EUITheme.spacingM
                    topPadding: EUITheme.spacingS
                    bottomPadding: EUITheme.spacingS
                }
            }

            Text {
                text: I18n.tr("RemoveRuleConfig", "Range is invalid. Please use A <= B and both > 0, or leave both as 0.")
                visible: !isRangeValid()
                font.pixelSize: EUITheme.fontCaption
                color: EUITheme.colorDanger
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }

        Row {
            width: parent.width
            spacing: EUITheme.spacingM

            ESwitch {
                id: removeDigitsSwitch
                checked: root.removeDigits
                onCheckedChanged: {
                    root.removeDigits = checked
                    updatePreview()
                }
            }

            Column {
                width: parent.width - removeDigitsSwitch.width - parent.spacing
                spacing: 4

                Text {
                    text: I18n.tr("RemoveRuleConfig", "Delete all digit characters (0-9)")
                    font.pixelSize: EUITheme.fontBody
                    font.weight: Font.Medium
                    color: EUITheme.colorText
                }

                Text {
                    // text: I18n.tr("RemoveRuleConfig", "Removes every numeric character while leaving letters and symbols unchanged")
                    font.pixelSize: EUITheme.fontCaption
                    color: EUITheme.colorTextSubtle
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Column {
            width: parent.width
            spacing: EUITheme.spacingS

            Text {
                text: I18n.tr("RemoveRuleConfig", "Preview")
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
                            text: I18n.tr("RemoveRuleConfig", "Before:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }

                        Text {
                            text: "sample123_file_name.txt"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorText
                            font.family: "monospace"
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: EUITheme.spacingS

                        Text {
                            text: I18n.tr("RemoveRuleConfig", "After:")
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorTextSubtle
                            width: 60
                        }

                        Text {
                            id: afterPreview
                            text: "sample123_file_name.txt"
                            font.pixelSize: EUITheme.fontCaption
                            color: EUITheme.colorPrimary
                            font.family: "monospace"
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }

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
                enabled: hasAnyOperation() && isRangeValid()
                onClicked: {
                    var config = {
                        "ruleType": "remove",
                        "name": buildRuleName(),
                        "removeFirstCount": root.removeFirstCount,
                        "removeLastCount": root.removeLastCount,
                        "rangeStart": root.rangeStart,
                        "rangeEnd": root.rangeEnd,
                        "removeDigits": root.removeDigits
                    };
                    root.ruleConfigured(config);
                    root.close();
                }
            }
        }
    }

    function parseSafeInt(text) {
        var value = parseInt(text);
        if (isNaN(value) || value < 0) {
            return 0;
        }
        return value;
    }

    function hasAnyOperation() {
        return root.removeFirstCount > 0 ||
               root.removeLastCount > 0 ||
               root.removeDigits ||
               (root.rangeStart > 0 && root.rangeEnd > 0);
    }

    function isRangeValid() {
        if (root.rangeStart === 0 && root.rangeEnd === 0) {
            return true;
        }
        return root.rangeStart > 0 && root.rangeEnd > 0 && root.rangeStart <= root.rangeEnd;
    }

    function buildRuleName() {
        var parts = [];
        if (root.removeFirstCount > 0) {
            parts.push(I18n.tr("RemoveRuleConfig", "first %1").replace("%1", root.removeFirstCount));
        }
        if (root.removeLastCount > 0) {
            parts.push(I18n.tr("RemoveRuleConfig", "last %1").replace("%1", root.removeLastCount));
        }
        if (root.rangeStart > 0 && root.rangeEnd > 0) {
            parts.push(I18n.tr("RemoveRuleConfig", "%1-%2").replace("%1", root.rangeStart).replace("%2", root.rangeEnd));
        }
        if (root.removeDigits) {
            parts.push(I18n.tr("RemoveRuleConfig", "digits"));
        }
        return I18n.tr("RemoveRuleConfig", "Delete: %1").replace("%1", parts.join(", "));
    }

    function updatePreview() {
        var text = "sample123_file_name.txt";

        if (root.removeFirstCount > 0) {
            text = text.substring(Math.min(root.removeFirstCount, text.length));
        }

        if (root.removeLastCount > 0 && text.length > 0) {
            var chop = Math.min(root.removeLastCount, text.length);
            text = text.substring(0, text.length - chop);
        }

        if (root.rangeStart > 0 && root.rangeEnd >= root.rangeStart && text.length > 0) {
            var start = Math.max(1, Math.min(root.rangeStart, text.length));
            var end = Math.max(1, Math.min(root.rangeEnd, text.length));
            if (start <= end) {
                var from = start - 1;
                text = text.substring(0, from) + text.substring(end);
            }
        }

        if (root.removeDigits) {
            text = text.replace(/[0-9]/g, "");
        }

        afterPreview.text = text;
    }

    function syncInputsFromProps() {
        firstCountInput.text = String(root.removeFirstCount);
        lastCountInput.text = String(root.removeLastCount);
        rangeStartInput.text = String(root.rangeStart);
        rangeEndInput.text = String(root.rangeEnd);
        removeDigitsSwitch.checked = root.removeDigits;
    }

    onOpened: {
        syncInputsFromProps();
        updatePreview();
        firstCountInput.forceActiveFocus();
    }
}
