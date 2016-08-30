/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                main.activate()
                openUrlDialog(true)
            }
        }
        CoverAction {
            iconSource: autoOpen ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-message"
            onTriggered: {
                if (autoOpen) {
                    storage.setSetting('autoOpen', 0)
                } else {
                    redditModel.openIndex(0)
                }
            }
        }

    }
    Image {
        id: coverImage
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        height: (sourceSize.height/sourceSize.width)*width
        width: parent.width
        source: thumbnailUrl ? thumbnailUrl : "cover.svg"
        opacity: thumbnailUrl ? 1 : 0.3
    }
    Label {
        id: commentsNumText
        anchors {
            centerIn: coverImage
        }
        text: redditModel.firstComments
        font.pixelSize: Theme.fontSizeExtraLarge*2
        font.bold: true
    }
    Label {
        anchors {
            top: commentsNumText.bottom
            margins: -Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        text: qsTr("comments")
        font.bold: true
        font.pixelSize: Theme.fontSizeSmall
    }

    Item {
        width: parent.width - 2*Theme.paddingSmall
        height: parent.height - coverImage.height - Theme.paddingSmall - Theme.itemSizeExtraSmall
        anchors {
            top: coverImage.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingSmall
        }
        clip: true

        Label {
            anchors {
                left: parent.left
                top: parent.top
            }
            text: redditModel.firstTitle
            width: parent.width
            height: parent.height
            wrapMode: Text.Wrap
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: (text.length > 40) ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall
        }
    }
}


