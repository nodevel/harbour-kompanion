import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Settings")
            }
            ComboBox {
                width: parent.width
                label: "Open in"

                menu: ContextMenu {
                    MenuItem { text: "Quickddit" }
                    MenuItem { text: "Web Browser" }
                    MenuItem { text: "this application" }
                }
                Component.onCompleted: currentIndex = storage.getSetting("openWeb", 0)
                onCurrentIndexChanged: storage.setSetting("openWeb", currentIndex)
            }
            ComboBox {
                width: parent.width
                label: "Sort by "

                menu: ContextMenu {
                    MenuItem { text: "relevance" }
                    MenuItem { text: "hot" }
                    MenuItem { text: "top" }
                    MenuItem { text: "new" }
                    MenuItem { text: "comments" }
                }
                Component.onCompleted: currentIndex = storage.getSetting("sortReddit", 0)
                onCurrentIndexChanged: storage.setSetting("sortReddit", currentIndex)
            }
            TextSwitch {
                text: "Enable auto-open"
                description: "Opens the first link for new every video"
                onCheckedChanged: storage.setSetting("autoOpen", checked*1)
                checked: autoOpen
            }
            TextSwitch {
                text: "Monitor clipboard"
                description: "Monitor clipboard for activity and if a video URL is copied, play it with Kodi (Keep alive is recommended for better functionality)."
                onCheckedChanged: {
                    if (checked) {
                        storage.setSetting("keepAlive", 1)
                    }
                    storage.setSetting("monitorClipboard", checked*1)
                }
                checked: monitorClipboard
            }
            TextSwitch {
                text: "Keep alive"
                description: "Keeps the app running in the background (drains battery)"
                onCheckedChanged: storage.setSetting("keepAlive", checked*1)
                checked: keepAlive
            }
            TextSwitch {
                text: "Minimize on URL launch"
                description: "If the 'Open URL' dialog was launched from the cover, it minimizes the app."
                onCheckedChanged: storage.setSetting("minimize", checked*1)
                checked: minimize
            }
        }
    }
}


