import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
         name: "Scoreboard"
         icon: "atlantikdesigner"
         source: "ConfigScoreboard.qml"
    }
}
