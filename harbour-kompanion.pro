# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-kompanion

CONFIG += sailfishapp

SOURCES += src/harbour-kompanion.cpp

OTHER_FILES += qml/harbour-kompanion.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-kompanion.changes.in \
    rpm/harbour-kompanion.spec \
    rpm/harbour-kompanion.yaml \
    translations/*.ts \
    harbour-kompanion.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-kompanion-de.ts

DISTFILES += \
    qml/pages/ListPage.qml \
    qml/pages/UrlDialog.qml \
    qml/pages/HistoryPage.qml \
    qml/pages/components/Storage.qml \
    qml/pages/ConnectionDialog.qml \
    qml/pages/components/RedditModel.qml \
    qml/pages/SubPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/components/KeepAlive.qml \
    qml/pages/WebviewPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/components/ClipboardMonitor.qml

