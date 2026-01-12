import QtQuick
import EUI
import ".."

// File drag and drop area component
Item {
    id: root
    
    signal filesDropped(var filePaths)
    
    // Drag and drop support
    DropArea {
        id: dropArea
        anchors.fill: parent
        
        onEntered: (drag) => {
            if (drag.hasUrls) {
                drag.accept(Qt.CopyAction);
            }
        }
        
        onDropped: (drop) => {
            if (drop.hasUrls) {
                var files = [];
                
                for (var i = 0; i < drop.urls.length; i++) {
                    var url = drop.urls[i].toString();
                    // Convert file:/// URL to local path
                    if (url.startsWith("file:///")) {
                        url = url.substring(8);
                    }
                    files.push(url);
                }
                
                if (files.length > 0) {
                    root.filesDropped(files);
                }
            }
        }
    }
    
    // Drag visual feedback
    Rectangle {
        anchors.fill: parent
        color: EUITheme.colorPrimary
        opacity: dropArea.containsDrag ? 0.1 : 0
        visible: dropArea.containsDrag
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: 20
            color: "transparent"
            border.color: EUITheme.colorPrimary
            border.width: 3
            radius: EUITheme.radiusLarge
            
            Column {
                anchors.centerIn: parent
                spacing: EUITheme.spacingM
                
                Image {
                    source: "../../icons/folder.svg"
                    width: 64
                    height: 64
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: I18n.tr("CenterPanel", "Drop files here")
                    font.pixelSize: EUITheme.fontH2
                    font.weight: Font.Medium
                    color: EUITheme.colorPrimary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
