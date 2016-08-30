import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property alias address: addressField.text
    property alias wsport: wsportField.text
    property alias username: usernameField.text
    property alias password: passwordField.text
    property alias port: portField.text

    Column {
        width: parent.width

        DialogHeader { acceptText: qsTr("Connect") }

        TextField {
            id: addressField
            width: parent.width
            placeholderText: "i.e. 127.0.0.1"
            label: qsTr("Address")
            text: storage.getSetting("address", "")
        }
        TextField {
            id: portField
            width: parent.width
            placeholderText: "i.e. 8080"
            label: qsTr("Port")
            text: storage.getSetting("port", "8080")
        }
        TextField {
            id: usernameField
            width: parent.width
            placeholderText: "username"
            label: qsTr("Username")
            text: storage.getSetting("username", "")
        }
        TextField {
            id: passwordField
            width: parent.width
            placeholderText: "password"
            label: qsTr("Password")
            text: storage.getSetting("password", "")
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Load above from Kodimote")
            onClicked: {
                getKodimoteConfig(function(result) {
                    addressField.text = result.address
                    portField.text = result.port
                    usernameField.text = result.username
                    passwordField.text = result.password
                })
            }
        }
        TextField {
            id: wsportField
            width: parent.width
            placeholderText: "i.e. 9090"
            label: qsTr("Websockets Port")
            text: storage.getSetting("wsport", "9090")
        }

    }

    onDone: {
        if (result == DialogResult.Accepted) {
            storage.setSetting('address', address)
            storage.setSetting('wsport', wsport)
            storage.setSetting('port', port)
            storage.setSetting('username', username)
            storage.setSetting('password', password)
        }
    }

    function getKodimoteConfig(func) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                var lines = doc.responseText.split(/\r\n|\r|\n/)
                var lastId = '';
                var result = {'address': '', 'hostname': '', 'mac': '', 'password': '', 'port': '', 'username': ''}
                lines.forEach(function(line) {
                    if (!lastId && line.indexOf('LastConnected=') !== -1) {
                        lastId = line.split('=')[1]
                    }
                    if (lastId) {
                        line = line.replace('%7B', '{').replace('%7D', '}')
                        if (line.indexOf(lastId+'\\Address=') !== -1) result['address'] = line.split('=')[1]
                        else if (line.indexOf(lastId+'\\Hostname=') !== -1) result['hostname'] = line.split('=')[1]
                        else if (line.indexOf(lastId+'\\MAC=') !== -1) result['mac'] = line.split('=')[1]
                        else if (line.indexOf(lastId+'\\Password=') !== -1) result['password'] = line.split('=')[1]
                        else if (line.indexOf(lastId+'\\Port=') !== -1) result['port'] = line.split('=')[1]
                        else if (line.indexOf(lastId+'\\Username=') !== -1) result['username'] = line.split('=')[1]
                    }
                })
                func(result)
            } // if
            loading = false
        }
        doc.open("GET", Qt.resolvedUrl("/home/nemo/.config/harbour-kodimote/harbour-kodimote.conf"));
        doc.send();
    }
}

