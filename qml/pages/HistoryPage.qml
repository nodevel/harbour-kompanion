import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    SilicaListView {
        id: listView
        anchors.fill: parent
        model: historyModel
        PullDownMenu {
            MenuItem {
                text: qsTr("Clear History")
                onClicked: storage.clearHistory()
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: historyModel.reload()
            }
        }
        header: PageHeader {
            title: qsTr("History")
        }
        delegate: ListItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                width: parent.width - 2*Theme.paddingLarge
                truncationMode: TruncationMode.Fade
            }
            menu: contextMenu
            ListView.onRemove: animateRemoval(delegate)
            function remove() {
                remorseAction("Deleting", function() {
                    storage.removeHistory(url)
                    view.model.remove(index) }
                )
            }
            onClicked: pageStack.push(Qt.resolvedUrl("SubPage.qml"), {'subpage': true, 'localItemUrl': url, 'title': name, 'thumbnail': thumbnail})
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Remove"
                        onClicked: remove()
                    }
                }
            }
        }
        section {
            property: "day"
            criteria: ViewSection.FullString
            delegate: SectionHeader { text: section }
        }
        onAtYEndChanged: {
            if (atYEnd && !historyModel.allLoaded) {
                historyModel.offset += historyModel.number
                historyModel.load()
            }
        }

        ViewPlaceholder {
            enabled: (listView.count == 0 && !loading)
            text: qsTr("No items in your history")
            hintText: qsTr("Start playing a Youtube/Vimeo/Liveleak/Gfycat video on Kodi and it will be added here")
        }
        VerticalScrollDecorator {}
    }
}
