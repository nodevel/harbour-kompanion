import QtQuick 2.0

ListModel {
    id: redditModel
    property int firstComments: 0
    property string firstTitle: "Kompanion"

    signal openIndex(int index)
    onOpenIndex: {
        openObj(get(index))
    }
    signal openObj(var itemObj)
    onOpenObj: {
        var mobileUrl = "https://m.reddit.com" + itemObj.subredditUrl + "/comments/" + itemObj.postId
        var url = "https://reddit.com" + itemObj.subredditUrl + "/comments/" + itemObj.postId
        if (openWeb == 0) {
            quickddit.call('openURL', [url])
        } else if (openWeb == 1) {
            Qt.openUrlExternally(mobileUrl)
        } else {
            pageStack.push(Qt.resolvedUrl("../WebviewPage.qml"), {'url': mobileUrl})
        }
    }
    signal load(string searchUrl)
    onLoad: {
        loading = true
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                var itemObj = JSON.parse(doc.responseText)
                if (itemObj && itemObj.data.children.length > 0) {
                    redditModel.clear()
                    for (var i = 0; i < itemObj.data.children.length; i++) {
                        var entry = itemObj.data.children[i].data
                        var d = new Date(entry.created_utc*1000)
                        redditModel.append(
                                    {
                                        'title': entry.title,
                                        'num_comments': entry.num_comments,
                                        'postId': entry.id,
                                        'gilded': entry.gilded,
                                        'upvotes': entry.ups,
                                        'created': entry.created_utc,
                                        'createdStr': d.getDate()  + "-" + (d.getMonth()+1) + "-" + d.getFullYear() + " " +
                                                      d.getHours() + ":" + d.getMinutes(),
                                        'subreddit': entry.subreddit,
                                        'subredditUrl': '/r/'+entry.subreddit,
                                    }

                                    )
                        if (i == 0) {
                            firstComments = entry.num_comments
                            firstTitle = entry.title
                            if (autoOpen && !main.applicationActive) {
                                tempLock = true
                                openIndex(0)
                            }
                        }
                    }
                }
                loading = false
            } // if
        }

        doc.open("GET", searchUrl);
        doc.send();
    }
}
