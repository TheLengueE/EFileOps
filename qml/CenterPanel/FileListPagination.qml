import QtQuick
import QtQuick.Controls
import EUI
import ".."

// File list pagination component
Rectangle {
    id: root
    height: 50
    color: "transparent"
    
    signal previousPageClicked()
    signal nextPageClicked()
    signal goToPageClicked(int page)
    
    property int totalCount: 0
    property int currentPage: 1
    property int totalPages: 1
    
    Row {
        anchors.centerIn: parent
        spacing: EUITheme.spacingM
        
        // Total count info
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: I18n.tr("CenterPanel", "Total: %1 files").replace("%1", root.totalCount)
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorTextSubtle
        }
        
        Rectangle {
            width: 1
            height: 20
            anchors.verticalCenter: parent.verticalCenter
            color: EUITheme.colorDivider
        }
        
        // Previous page button
        EButton {
            buttonType: EButton.ButtonType.Primary
            text: "<"
            implicitWidth: 40
            implicitHeight: 32
            enabled: root.currentPage > 1
            onClicked: root.previousPageClicked()
        }
        
        // Page info
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: I18n.tr("CenterPanel", "Page %1 / %2")
                    .replace("%1", root.currentPage)
                    .replace("%2", root.totalPages)
            font.pixelSize: EUITheme.fontBody
            color: EUITheme.colorText
            font.weight: Font.Medium
        }
        
        // Next page button
        EButton {
            buttonType: EButton.ButtonType.Primary
            text: ">"
            implicitWidth: 40
            implicitHeight: 32
            enabled: root.currentPage < root.totalPages
            onClicked: root.nextPageClicked()
        }
        
        Rectangle {
            width: 1
            height: 20
            anchors.verticalCenter: parent.verticalCenter
            color: EUITheme.colorDivider
        }
        
        // Go to page
        Row {
            spacing: EUITheme.spacingS
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.tr("CenterPanel", "Go to page:")
                font.pixelSize: EUITheme.fontBody
                color: EUITheme.colorTextSubtle
            }
            
            TextField {
                id: pageInput
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 60
                implicitHeight: 32
                
                placeholderText: root.currentPage.toString()
                horizontalAlignment: Text.AlignHCenter
                validator: IntValidator {
                    bottom: 1
                    top: root.totalPages
                }
                
                background: Rectangle {
                    color: pageInput.enabled ? "white" : EUITheme.colorMutedBg
                    border.color: pageInput.activeFocus ? EUITheme.colorPrimary : EUITheme.colorBorder
                    border.width: 1
                    radius: 4
                }
                
                font.pixelSize: EUITheme.fontBody
                color: EUITheme.colorText
                
                onAccepted: {
                    var page = parseInt(text);
                    if (page >= 1 && page <= root.totalPages) {
                        root.goToPageClicked(page);
                        text = "";
                        focus = false;
                    }
                }
            }
            
            EButton {
                buttonType: EButton.ButtonType.Primary
                text: I18n.tr("CenterPanel", "Go")
                implicitWidth: 50
                implicitHeight: 32
                enabled: pageInput.text !== "" && parseInt(pageInput.text) >= 1 && parseInt(pageInput.text) <= root.totalPages
                onClicked: {
                    var page = parseInt(pageInput.text);
                    if (page >= 1 && page <= root.totalPages) {
                        root.goToPageClicked(page);
                        pageInput.text = "";
                        pageInput.focus = false;
                    }
                }
            }
        }
    }
}
