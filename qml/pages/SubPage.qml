import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"

ListPage {
    subpage: true
    autoOpen: false
    localModel: RedditModel {
        id: redditModel
    }
    Component.onCompleted: {
        localModel.load(redditSearchApiString(localItemUrl)) // TODO fix?
    }

}

