import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    property var db: null


    /**
     * Get the application's database connection
     */
    function getDatabase() {
        return LocalStorage.openDatabaseSync("harbour-kompanion", "0.1", "Kompanion", 100000)
    }


    /**
     * Initialize the tables if needed
     */
    function initialize() {
        if(db !== null) return;
        db = getDatabase();
        try {
            db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)')
                }
            )
            db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS history(url TEXT UNIQUE, source TEXT, id TEXT, timestamp INT, thumbnail TEXT, name TEXT, hits INT)')
                }
            )
        } catch (ex) {
            console.debug('initialize:', ex)
        }
    }

    /**
     * Saves a setting into the database
     * @param setting The setting to save
     * @param value The value for the setting to save
     *
     * @return true if the operation is successfull, false otherwise
     */
    function setSetting(setting, value) {
        initialize()
        var success = false
        try {
            var db = getDatabase()
            db.transaction(function(tx) {
                var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value])
                success = rs.rowsAffected > 0
            })
        } catch (ex) {
            console.debug('setSetting:', ex)
        }
        if (success) main[setting] = value // change global variables
        return success
    }

    /**
     * Retrieves a setting from the database
     * @param setting The setting to retrieve
     * @param defaultValue The default value if no value was found
     *
     * @return The value for the setting
     */
    function getSetting(setting, defaultValue) {
        initialize()
        var res = defaultValue
        try {
            var db = getDatabase();
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
                if (rs.rows.length > 0) {
                    res = rs.rows.item(0).value;
                }
            })
        } catch (ex) {
            console.debug('getSetting:', ex)
        }
        return res
    }


    /**
     * Saves a provider source item into the database
     * @param item The source item to save: (item.url, item.source, item.id, item.timestamp, item.thumbnail, item.name, item.hits)
     *
     * @return The insertion index
     */
    function addHistory(item, force) {
        force = typeof force !== 'undefined' ? force : true;
        var alternativeStr = (force) ? 'REPLACE' : 'IGNORE'
        var insertIndex = -1
        initialize()
        try {
            db.transaction(function(tx) {
                var rs = tx.executeSql('INSERT OR '+alternativeStr+' INTO history VALUES (?,?,?,?,?,?,?);',
                                       [item.url, item.source, item.id, item.timestamp, item.thumbnail, item.name, item.hits])
                insertIndex = rs.insertId
            })
        } catch (ex) {
            console.debug('addHistory:', ex)
        }
        historyModel.reload()
        return insertIndex
    }

    /**
     * Removes a history item item from the database
     * @param url The url to remove
     *
     * @return true if the operation is successful, Error if it failed
     */
    function removeHistory(url) {
        var success = false
        initialize()
        try {
            db.transaction(function(tx) {
                var rs = tx.executeSql('DELETE FROM history WHERE url = ?;',
                                       [url])
                success = rs.rowsAffected > 0
            })
        } catch (ex) {
            console.debug('removeHistory:', ex)
        }
        return success
    }

    /**
     * Removes all items from the history
     *
     * @return true if the operation is successful, Error if it failed
     */
    function clearHistory() {
        var success = false
        initialize()
        try {
            db.transaction(function(tx) {
                var rs = tx.executeSql('DELETE FROM history;')
                success = rs.rowsAffected > 0
            })
        } catch (ex) {
            console.debug('removeHistory:', ex)
        }
        if (success) historyModel.reload()
        return success
    }

    /**
     * Gets history from the database
     *
     * @return The history stored or an empty list
     */
    function getHistory(orderby, direction, offset, number) {
        orderby = typeof orderby !== 'undefined' ? orderby : 'timestamp';
        direction = typeof direction !== 'undefined' ? direction : 'ASC';
        offset = typeof offset !== 'undefined' ? offset : historyModel.offset;
        number = typeof number !== 'undefined' ? number : historyModel.number;
        var res= []
        initialize()
        try {
            db.transaction(function(tx) {
                var rs = tx.executeSql("SELECT url, source, id, timestamp, thumbnail, name, hits, strftime('%d. %m. %Y ', datetime(timestamp, 'unixepoch')) AS day FROM history ORDER BY "+orderby+" "+direction+" LIMIT "+number+" OFFSET "+offset+";")
                if (rs.rows.length > 0) {
                    for(var i = 0; i < rs.rows.length; i++) {
                        var currentItem = rs.rows.item(i)
                        res.push({'url': currentItem.url,
                                  'source': currentItem.source,
                                  'id': currentItem.id,
                                  'timestamp': currentItem.timestamp,
                                  'thumbnail': currentItem.thumbnail,
                                  'name': currentItem.name,
                                  'hits': currentItem.hits,
                                  'day': currentItem.day})
                    }
                    if (rs.rows.length < number) historyModel.allLoaded = true // All items have been loaded.
                }
            })
        } catch (ex) {
            console.debug('getHistory:', ex)
        }
        return res
    }

}
