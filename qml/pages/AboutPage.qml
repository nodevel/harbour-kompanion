import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("About")
            }
            DetailItem {
                label: qsTr("Name")
                value: "Kompanion"
            }
            DetailItem {
                label: qsTr("Year")
                value: "2016"
            }
            DetailItem {
                label: qsTr("Author")
                value: "nodevel"
            }
        }
    }
}


