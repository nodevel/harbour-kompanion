import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    property string url
    canAccept: urlField

    Column {
        width: parent.width

        DialogHeader { acceptText: qsTr("Play") }

        TextField {
            id: urlField
            width: parent.width
            placeholderText: "Insert URL"
            label: "URL"
            focus: true
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            url = urlField.text
            play(url)
        }
    }
}

