import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page {
    id: page
    property alias url: webview.url

    WebView {
        id: webview
        url: "http://qt-project.org"
        anchors.fill: parent
    }

}

