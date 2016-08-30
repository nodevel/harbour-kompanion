import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebSockets 1.0
import "pages"
import "pages/components"
import org.nemomobile.dbus 2.0

ApplicationWindow
{
    id: main
    initialPage: Component { ListPage { subpage: false } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
    property string address: storage.getSetting("address", "")
    property int wsport: storage.getSetting("wsport", 9090)
    property int port: storage.getSetting("port", 8080)
    property string username: storage.getSetting("username", "")
    property string password: storage.getSetting("password", "")
    property var playerItem
    property string itemType
    property string itemUrl
    property string thumbnailUrl
    property bool autoOpen: storage.getSetting("autoOpen", 1)*1
    property string apiFormat: "json"
    property int openWeb: storage.getSetting("openWeb", 0)
    property bool keepAlive: storage.getSetting('keepAlive', true)*1 // Keep the app alive. Drains battery
    property int sortReddit: storage.getSetting("sortReddit", 0)
    property bool minimize: storage.getSetting("minimize", true)*1
    property bool monitorClipboard: storage.getSetting("monitorClipboard", false)*1
    property var sortRedditStrings: ['relevance', 'hot', 'top', 'new', 'comments']
    property bool loading
    property bool tempLock: false // temporarily lock auto-opening links from the app if the link has been opened before while the application was in the background
    function redditSearchApiString(str) {
        return encodeURI("https://api.reddit.com/search."+apiFormat+"?q="+str+"&sort="+sortRedditStrings[sortReddit])
    }
    property string lastClipboardVideo: '' // Last video captured from clipboard. This is for a workaround that prevents the current video from being played multiple times.

    WebSocket {
        id: websocket
        property bool open: (websocket.status == WebSocket.Open)
        onStatusChanged: {
            if (websocket.status == WebSocket.Error) {
                    console.log("Error: " + websocket.errorString)
                } else if (websocket.status == WebSocket.Open) {
                    console.log("Hello Secure World")
                    // First load info about the current state
//                    pageStack.replace(Qt.resolvedUrl("KeypadPage.qml"))
                    send_message('Player.GetItem', { "properties": ["title", "album", "artist", "season", "episode", "duration", "showtitle", "tvshowid", "thumbnail", "file", "fanart", "streamdetails", "showlink", "uniqueid", "description"], "playerid": 1})
                } else if (websocket.status == WebSocket.Closed) {
                    console.log("\nSecure socket closed")
                }
        }
        onTextMessageReceived: {
            var msgObj = JSON.parse(message)
            switch(msgObj.method) {
                case 'Player.OnPlay':
//                    playing = true;
                    send_message('Player.GetItem', { "properties": ["title", "album", "artist", "season", "episode", "duration", "showtitle", "tvshowid", "thumbnail", "file", "fanart", "streamdetails", "showlink", "uniqueid", "description"], "playerid": 1})
                    break;
                default:
                    console.log(msgObj.method)
                    // If method is not defined
                    switch(msgObj.id) {
                        case 'VideoGetItem':
                            evaluateItem(msgObj.result.item)
                            break;
                        case 'Player.GetItem':
                            evaluateItem(msgObj.result.item)
                            break;
                        default:
                            console.log(msgObj.id)
                    }
            }

        }

        function send_message(method, params) {
            var msg = {
                "jsonrpc": "2.0",
                "method": method,
                "id": method
            };
            if (params) {
                msg.params = params;
            }
            websocket.sendTextMessage(JSON.stringify(msg));
        }
    }
    function evaluateItem(item) {
        if (item !== playerItem) {
            var videoId = ''
            if (item.thumbnail.indexOf('ytimg.com') > -1) {
                itemType = 'youtube'
                videoId = item.thumbnail.split('%2f')[4]
                itemUrl = "(url:3D"+videoId+" OR url:"+videoId+") (site:youtube.com OR site:youtu.be)";
            } else if (item.thumbnail.indexOf('vimeocdn.com') > -1) {
                itemType = 'vimeo'
                videoId = item.file.split('?s=')[1].split('_')[0]
                itemUrl = "url:https://vimeo.com/"+videoId+" OR url:http://vimeo.com/"+videoId
            } else if (item.thumbnail.indexOf('cdn.liveleak.com') > -1) {
                itemType = 'liveleak'
                videoId = item.file.split('LiveLeak-dot-com-')[1].split('-')[0]
                itemUrl = "url:http://www.liveleak.com/view?i="+videoId+" OR url:http://liveleak.com/view?i="+videoId
            } else if (item.thumbnail.indexOf('thumbs.gfycat.com') > -1) {
                itemType = 'gfycat'
                videoId = item.thumbnail.split('thumbs.gfycat.com%2f')[1].split('-')[0]
                itemUrl = "url:https://gfycat.com/"+videoId+" OR url:http://gfycat.com/"+videoId
            }
            if (videoId) {
                thumbnailUrl = item.thumbnail.replace('image://', '').replace('%3a', ':').replace('%2f', '/').replace(new RegExp('/$'), '')
                storage.addHistory({'url': itemUrl, 'source': itemType, 'id': videoId, 'timestamp': Math.floor(Date.now() / 1000), 'thumbnail': thumbnailUrl, 'name': item.title, 'hits': -1}, true)
                playerItem = item
            }
        }
    }
    DBusInterface {
        id: quickddit

        service: 'org.quickddit'
        iface: 'org.quickddit.view'
        path: '/'
    }



    function play(url) {
        var videoId;
        if (url.indexOf("youtube.com") !== -1) {
            // SEND TO YOUTUBE
            if (url.indexOf("?v=") !== -1) {
                videoId = url.split('&')[0].split('?v=')[1]
            } else {
                videoId = url.split('&v=')[1].split('&')[0]
            }
            websocket.send_message('Player.Open', {"item": {"file":"plugin://plugin.video.youtube/?action=play_video&videoid="+videoId}} )
            itemUrl = "(url:3D"+videoId+" OR url:"+videoId+") (site:youtube.com OR site:youtu.be)";
        } else if (url.indexOf("youtu.be") !== -1) {
            // SEND TO YOUTUBE
            videoId = url.split('?')[0].split('youtu.be/')[1]
            websocket.send_message('Player.Open', {"item": {"file":"plugin://plugin.video.youtube/?action=play_video&videoid="+videoId}} )
            itemUrl = "(url:3D"+videoId+" OR url:"+videoId+") (site:youtube.com OR site:youtu.be)";
        } else if (url.indexOf("vimeo.com") !== -1) {
            // SEND TO VIMEO
            videoId = url.split('?')[0].split('vimeo.com/')[1]
            websocket.send_message('Player.Open', {"item": {"file":"plugin://plugin.video.vimeo/?action=play_video&videoid="+videoId}} )
            itemUrl = "url:https://vimeo.com/"+videoId+" OR url:http://vimeo.com/"+videoId
        } else if (url.indexOf("liveleak.com") !== -1) {
            // SEND TO LIVELEAK
            videoId = url.split('&')[0].split('?i=')[1]
            websocket.send_message('Player.Open', {"item": {"file":"plugin://plugin.video.liveleak/?action=play_video&videoid="+videoId}} )
            itemUrl = "url:http://www.liveleak.com/view?i="+videoId+" OR url:http://liveleak.com/view?i="+videoId
        } else if (url.indexOf("gfycat.com") !== -1) {
            // SEND TO GFYCAT
            videoId = url.split('?')[0].split('gfycat.com/')[1]
            websocket.send_message('Player.Open', {"item": {"file":"plugin://plugin.video.gfycat/?action=play_video&videoid="+videoId}} )
            itemUrl = "url:https://gfycat.com/"+videoId+" OR url:http://gfycat.com/"+videoId
        } else {
            // SEND GENERIC
            websocket.send_message('Player.Open', {"item": {"file": url}} )
        }
    }

    ListModel {
        id: historyModel
        property int offset: 0 // start with the first item
        property int number: 20 // load 20 items at once
        property bool allLoaded: false
        signal load
        onLoad: {
            if (!allLoaded) {
                var history = storage.getHistory('timestamp', 'DESC', offset, number)
                for (var i = 0; i < history.length; i++) {
                    historyModel.append(history[i])
                }
            }
        }
        signal reload
        onReload: {
            offset = 0
            allLoaded = false
            clear()
            load()
        }

        Component.onCompleted: load()
    }


    Storage {
        id: storage
    }
    RedditModel {
        id: redditModel
    }
    onItemUrlChanged: redditModel.load(redditSearchApiString(itemUrl))
    signal openUrlDialog (bool launchedMinimized)
    onOpenUrlDialog: {
        var dialog = pageStack.push(Qt.resolvedUrl("pages/UrlDialog.qml"))
        dialog.accepted.connect(function() {
            if (minimize && launchedMinimized) main.deactivate()
        })
    }
    Keys.onVolumeUpPressed: websocket.send_message('Input.Action', { "volumeup" : "2"})
    Keys.onVolumeDownPressed: websocket.send_message('Input.Action', { "volumedown" : "2"})
    focus: true
    Component.onCompleted: forceActiveFocus()

    ClipboardMonitor {}

    function videoURL(str) {
        var pattern = new RegExp("(\b(https?|ftp|file)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
        var videoStrings = ["youtube.com", "youtu.be", "vimeo.com", "liveleak.com", "gfycat.com", "mp4$", "avi$", "mp3$"]
        if (pattern.test(str) && (new RegExp(videoStrings.join("|"))).test(str)) {
            return true;
        } else {
            return false
        }

    }
    Component {
        id: historyPageComponent
        HistoryPage {}
    }


}
