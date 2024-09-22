import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Effects

Item {
    id: root
    property string iconPath: ""
    property color onColor: "green"
    property color offColor: "#222222"
    property bool isOn: false

    // Intermediary properties for animation
    property int glowBlur: isOn ? 10 : 0
    property color currentColor: isOn ? onColor : offColor

    Image {
        id: icon
        source: iconPath
        width: root.width
        height: root.height
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width         // Adjust source size to match the item size
        sourceSize.height: height       // Adjust source size to match the item size
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: glowBlur != 0
            shadowBlur: glowBlur / 10
            shadowScale: 1
            shadowColor: onColor
            brightness: 1.0
            colorization: 1.0
            colorizationColor: currentColor
        }
    }

    Behavior on glowBlur {
        NumberAnimation {
            duration: 200
        }
    }

    Behavior on currentColor {
        ColorAnimation {
            duration: 200
        }
    }
}
