import QtQuick
import QtQuick.Layouts

Item {
    id: compactRepresentation
    Layout.preferredWidth:panelViewMode ? 36:panelThickness*10
    Layout.preferredHeight:panelThickness+10
    Layout.minimumWidth:26
    Layout.maximumWidth:124
    Layout.minimumHeight:26
    Layout.maximumHeight:panelThickness+20

    CompactItem {
        id: compactItem
        anchors.fill: parent
    }
}
