import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"


Page {
    id: page
    property string localItemUrl
    property string title: playerItem.title
    property string thumbnail: thumbnailUrl
    property bool subpage // whether it is a subpage
    property ListModel localModel
    property bool autoOpen: main.autoOpen


    onStatusChanged: {
        if (status === PageStatus.Active && pageStack.depth === 1) {
            if (address && wsport) {
                pageStack.pushAttached(historyPageComponent)
                if (!websocket.open) websocket.url = 'ws://'+address+':'+wsport+'/jsonrpc'
            } else {
                var dialog = pageStack.push(Qt.resolvedUrl("ConnectionDialog.qml"))
                dialog.accepted.connect(function() {
                    websocket.url = 'ws://'+dialog.address+':'+dialog.wsport+'/jsonrpc'
                })
            }
        }
    }
    SilicaListView {
        id: listView
        model: subpage ? localModel : redditModel
        anchors.fill: parent
        header: Item {
            width: page.width
            height: Theme.itemSizeHuge
            clip: true
            Image {
                id: thumbnailImage
                height: parent.height - 2*Theme.paddingLarge
                width: (sourceSize.width/sourceSize.height)*height
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                source: page.thumbnail
            }
            Label {
                width: parent.width - thumbnailImage.width - 2*Theme.paddingLarge
                height: parent.height - 2*Theme.paddingLarge
                text: page.title
                truncationMode: TruncationMode.Fade
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                anchors {
                    left: thumbnailImage.right
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingLarge
                }
            }
        }

//            PageHeader {
//                        title: page.title
//                        opacity: websocket.open ? 1 : 0.5
//                    }

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                visible: !subpage
                enabled: visible
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Connect")
                visible: !subpage
                enabled: visible
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("ConnectionDialog.qml"),{})
                    dialog.accepted.connect(function() {
//                        header.title = "My name: " + dialog.name
                    })
                }
            }
            MenuItem {
                text: autoOpen ? qsTr("Disable Auto-open") : qsTr("Enable auto-open")
                visible: !subpage
                enabled: visible
                onClicked: storage.setSetting('autoOpen', (!autoOpen)*1)
            }
            MenuItem {
                text: qsTr("Play New URL")
                onClicked: openUrlDialog(false)
            }
        }

        section {
            property: "subredditUrl"
            criteria: ViewSection.FullString
            delegate: SectionHeader { text: section }
        }

        delegate: BackgroundItem {
            id: delegate
            property string mobileUrl: "https://m.reddit.com" + subredditUrl + "/comments/" + postId
            property string url: "https://reddit.com" + subredditUrl + "/comments/" + postId
            property bool opened: false // if the item has been opened
            height: titleLabel.implicitHeight + updatedLabel.implicitHeight + 3*Theme.paddingLarge

            Label {
                id: titleLabel
                text: title
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: Theme.paddingLarge
                }
                width: parent.width - 2*anchors.margins
                wrapMode: Text.Wrap
            }
            Label {
                id: updatedLabel
                text: createdStr
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    margins: Theme.paddingLarge
                }
                color: Theme.secondaryColor
            }
            Label {
                text: num_comments + " " + qsTr("comments")
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: Theme.paddingLarge
                }
                color: updatedLabel.color
            }
            RemorseItem { id: remorse }

            function showRemorseItem() {
                if (!tempLock && main.applicationActive) {
                    remorse.execute(delegate, "Opening", function() { opened = true; redditModel.openIndex(index) }, 3000 )
                } else {
                    tempLock = false // unlock the lock :-)
                }
            }

            onClicked: redditModel.openIndex(index)
            Component.onCompleted: {
                if (index == 0) {
                    if (autoOpen && (index == 0) && !opened) showRemorseItem()
                }
            }
        }
        ViewPlaceholder {
            enabled: (listView.count == 0 && !loading)
            text: websocket.open ? qsTr("No posts for the current video") : qsTr("Disconnected")
            hintText: websocket.open ? qsTr("Try a different one") : qsTr("Try different host settings or restarting the app")
        }
        VerticalScrollDecorator {}
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: loading
    }
    // KeepAlive
    Loader {
        id: keepaliveLoader
        active: keepAlive && !subpage
        source: "components/KeepAlive.qml"
    }

}
