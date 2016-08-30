import QtQuick 2.0
import Sailfish.Silica 1.0

Loader {
    active: monitorClipboard
    sourceComponent: Component {
        Connections {
            target: Clipboard
            onTextChanged: {
                if (Clipboard.hasText && Clipboard.text !== lastClipboardVideo && videoURL(Clipboard.text)) {
                    play(Clipboard.text)
                    lastClipboardVideo = Clipboard.text
                }
            }
        }
    }
}

