import QtQuick
import QtQuick.Layouts

Item {
    id: compactRepresentation
    Layout.preferredWidth:36
    Layout.preferredHeight:42
    Layout.minimumWidth:26
    Layout.maximumWidth:42
    Layout.minimumHeight:26
    Layout.maximumHeight:44

    CompactItem {
        id: compactItem
        anchors.fill: parent
    }
}
