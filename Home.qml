import QtQuick 6.5
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root
    visible: true
    width: 1024
    height: 600

    property color backgroundColor: "#141414"

    FontLoader {
        id: numbersFont
        source: "qrc:/Fonts/Alien-Encounters-Italic.ttf"  // Replace with your actual font file path
    }

    FontLoader {
        id: textFont
        source: "qrc:/Fonts/Alien-Encounters-Solid-Regular.ttf"  // Replace with your actual font file path
    }

    FontLoader {
        id: highLightTextFont
        source: "qrc:/Fonts/Alien-Encounters-Regular.ttf"  // Replace with your actual font file path
    }

    // Values
    property int speedValue: 0
    property int tachoValue: 0
    property int gearValue: 0
    property bool engineWarning: true
    property bool absWarning: true
    property int engineTemp: 35
    property int trip1: 20
    property int trip2: 20
    property int odo: 16000

    // Functions
    function lerpColor(color1, color2, factor) {
        return Qt.rgba(
                    color1.r + factor * (color2.r - color1.r),
                    color1.g + factor * (color2.g - color1.g),
                    color1.b + factor * (color2.b - color1.b),
                    1 // alpha
                    );
    }

    // UI Values
    property color tachoColor: {
        var minTacho = 1000;
        var tachoRanges = [
                    { min: 1000, max: 2000, startColor: Qt.rgba(0, 1, 0, 1), endColor: Qt.rgba(0.2, 1, 0.2, 1) },  // Green to Lime green
                    { min: 2000, max: 2500, startColor: Qt.rgba(0.2, 1, 0.2, 1), endColor: Qt.rgba(0.7, 1, 0, 1) },  // Lime green to Yellow-green
                    { min: 2500, max: 3200, startColor: Qt.rgba(0.7, 1, 0, 1), endColor: Qt.rgba(1, 1, 0, 1) },   // Yellow-green to Yellow
                    { min: 3200, max: 4000, startColor: Qt.rgba(1, 1, 0, 1), endColor: Qt.rgba(1, 0.6, 0, 1) },   // Yellow to Orange
                    { min: 4000, max: 5000, startColor: Qt.rgba(1, 0.6, 0, 1), endColor: Qt.rgba(1, 0.27, 0, 1) }, // Orange to Dark orange
                    { min: 5000, max: 6000, startColor: Qt.rgba(1, 0.27, 0, 1), endColor: Qt.rgba(0.8, 0, 0, 1) }  // Dark orange to Red
                ];

        for (var i = 0; i < tachoRanges.length; i++) {
            var range = tachoRanges[i];
            if (tachoValue <= range.max) {
                var factor = (tachoValue - range.min) / (range.max - range.min);
                return lerpColor(range.startColor, range.endColor, factor);
            }
        }
        return Qt.rgba(1, 0, 0, 1); // Default to Red if above max range
    }
    property color speedColor: {
        var minSpeed = 50;
        var maxSpeed = 120;
        var speedRanges = [
                    { min: 0, max: 50, startColor: Qt.rgba(0, 1, 0, 1), endColor: Qt.rgba(0.2, 1, 0.2, 1) },      // Green to Lime green
                    { min: 50, max: 80, startColor: Qt.rgba(0.2, 1, 0.2, 1), endColor: Qt.rgba(1, 1, 0, 1) },     // Lime green to Yellow
                    { min: 80, max: 100, startColor: Qt.rgba(1, 1, 0, 1), endColor: Qt.rgba(1, 0.55, 0, 1) },     // Yellow to Dark orange
                    { min: 100, max: 110, startColor: Qt.rgba(1, 0.55, 0, 1), endColor: Qt.rgba(1, 0.39, 0.28, 1) }, // Dark orange to Tomato
                    { min: 110, max: 120, startColor: Qt.rgba(1, 0.39, 0.28, 1), endColor: Qt.rgba(0.8, 0, 0, 1) } // Tomato to Dark red
                ];

        for (var j = 0; j < speedRanges.length; j++) {
            var rangeSpeed = speedRanges[j];
            if (speedValue <= rangeSpeed.max) {
                var factorSpeed = (speedValue - rangeSpeed.min) / (rangeSpeed.max - rangeSpeed.min);
                return lerpColor(rangeSpeed.startColor, rangeSpeed.endColor, factorSpeed);
            }
        }
        return Qt.rgba(0.8, 0, 0, 1); // Default to Dark red if above max range
    }
    property bool gearBlinking: tachoValue > 4000
    onGearBlinkingChanged: {
        if (!gearBlinking) {
            gearText.opacity = 1
            tachoMark.opacity = 1
            glowOverlay.opacity = 1
        }
    }

    // Constants
    property color warningColor: "#FFD700"
    property color offColor: "#3D3D3D"
    property int maxTacho: 10000

    // Behaviors
    // Behavior on tachoColor { ColorAnimation { duration: 200 } }
    // Behavior on speedColor { ColorAnimation { duration: 200 } }

    // Animation block for startup sequence (can be commented out to disable it)
    SequentialAnimation on gearValue {
        // Comment this block to remove the start animation
        id: startupAnimation
        running: true
        loops: 1 // Only run once

        PropertyAnimation {
            target: root
            property: "engineWarning"
            from: true
            to: false
            duration: 1000
        }

        PropertyAnimation {
            target: root
            property: "absWarning"
            from: true
            to: false
            duration: 1000
        }
        // Gear 1: 0-20 km/h, RPM increasing
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "gearValue"
                from: 1
                to: 1
                duration: 2000
            }
            NumberAnimation {
                target: root
                property: "speedValue"
                from: 0
                to: 20
                duration: 2000
            }
            NumberAnimation {
                target: root
                property: "tachoValue"
                from: 1000
                to: 4500 // RPM increases with speed in Gear 1
                duration: 2000
            }

        }

        // Gear 2: RPM drops, speed increases, and RPM increases again
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "gearValue"
                from: 1
                to: 2
                duration: 200 // Shorter duration for gear shift
                onStopped: { tachoValue = 1500; } // Reset RPM to low value
            }
            NumberAnimation {
                target: root
                property: "speedValue"
                from: 20
                to: 40
                duration: 2500
            }
            NumberAnimation {
                target: root
                property: "tachoValue"
                from: 1500
                to: 4500 // RPM increases with speed in Gear 2
                duration: 2500
            }
        }

        // Gear 3: RPM drops, speed increases, and RPM increases again
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "gearValue"
                from: 2
                to: 3
                duration: 200 // Shorter duration for gear shift
                onStopped: { tachoValue = 2000; } // Reset RPM to low value
            }
            NumberAnimation {
                target: root
                property: "speedValue"
                from: 40
                to: 70
                duration: 4000
            }
            NumberAnimation {
                target: root
                property: "tachoValue"
                from: 2000
                to: 5000 // RPM increases with speed in Gear 3
                duration: 4000
            }
        }

        // Gear 4: RPM drops, speed increases, and RPM increases again
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "gearValue"
                from: 3
                to: 4
                duration: 200 // Shorter duration for gear shift
                onStopped: { tachoValue = 2500; } // Reset RPM to low value
            }
            NumberAnimation {
                target: root
                property: "speedValue"
                from: 70
                to: 100
                duration: 4000
            }
            NumberAnimation {
                target: root
                property: "tachoValue"
                from: 2500
                to: 5500 // RPM increases with speed in Gear 4
                duration: 4000
            }
        }

        // Gear 5: RPM drops, speed increases, and RPM increases again
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "gearValue"
                from: 4
                to: 5
                duration: 200 // Shorter duration for gear shift
                onStopped: { tachoValue = 3000; } // Reset RPM to low value
            }
            NumberAnimation {
                target: root
                property: "speedValue"
                from: 100
                to: 125
                duration: 4000
            }
            NumberAnimation {
                target: root
                property: "tachoValue"
                from: 3000
                to: 6000 // RPM increases with speed in Gear 5
                duration: 4000
            }
        }
    }

    // UI
    Image {
        id: glowOverlay
        source: "qrc:/Icons/glow-outer.svg"
        height: 420
        width: height
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width         // Adjust source size to match the item size
        sourceSize.height: height       // Adjust source size to match the item size
        anchors.left: meterPath.left
        anchors.right: meterPath.right
        anchors.verticalCenter: parent.verticalCenter
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: tachoColor
        }
        SequentialAnimation {
            loops: Animation.Infinite // Make the animation loop infinitely
            running: gearBlinking
            PropertyAnimation { target: glowOverlay; property: "opacity"; to: 0.4; duration: 100 }
            PropertyAnimation { target: glowOverlay; property: "opacity"; to: 1.0; duration: 100 }
        }
    }

    Image {
        source: "qrc:/Icons/glow-inner.svg"
        height: 420
        width: height
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width         // Adjust source size to match the item size
        sourceSize.height: height       // Adjust source size to match the item size
        anchors.left: meterPath.left
        anchors.right: meterPath.right
        anchors.verticalCenter: parent.verticalCenter
        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: speedColor
        }
    }

    Image {
        id: meterPath
        source: "qrc:/Icons/meter-path.svg"
        height: 504
        width: height
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width         // Adjust source size to match the item size
        sourceSize.height: height       // Adjust source size to match the item size
        x: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: fuelMeter
        source: "qrc:/Icons/fuel-meter.svg"
        height: meterPath.height - 120
        sourceSize.height: height       // Adjust source size to match the item size
        fillMode: Image.PreserveAspectFit
        x: (meterPath.x + meterPath.width) - 64
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        anchors.verticalCenter: glowOverlay.verticalCenter
        anchors.horizontalCenter: glowOverlay.horizontalCenter
        height: 420
        width: 420
        // -60 startAngle, 240 endAngle
        rotation: -60 + ((tachoValue / (maxTacho)) * (240 + 60))
        transformOrigin: Item.Center

        Image {
            id: tachoMark
            source: "qrc:/Icons/meter-mark.svg"
            width: 42
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            rotation: 180
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width         // Adjust source size to match the item size
            sourceSize.height: height       // Adjust source size to match the item size
            z: 5
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowScale: 1
                shadowColor: "orangered"
                brightness: 1.0
                colorization: 1.0
                colorizationColor: "orangered"
            }
        }
        Rectangle {
            // color: "transparent"
            width: parent.width - tachoMark.width
            height: 0
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Image {
        id: topLeft
        source: "qrc:/Icons/divider-top-left.svg"
        height: 80
        width: 180
        opacity: 0.4
    }

    Image {
        id: bottomLeft
        source: "qrc:/Icons/divider-bottom-left.svg"
        height: 80
        width: 180
        opacity: 0.4
        anchors.bottom: parent.bottom
    }

    Image {
        id: topRight
        source: "qrc:/Icons/divider-top-right.svg"
        height: 80
        x: 364
        opacity: 0.4
    }

    Image {
        id: bottomRight
        source: "qrc:/Icons/divider-bottom-right.svg"
        height: 80
        anchors.bottom: parent.bottom
        x: topRight.x
        opacity: 0.4
    }

    Text {
        id: speedText
        anchors.verticalCenter: glowOverlay.verticalCenter
        anchors.horizontalCenter: glowOverlay.horizontalCenter
        text: speedValue
        color: "white"
        font.pointSize: 140
        font.family: numbersFont.name
        font.italic: true
        horizontalAlignment: Text.AlignHCenter
        leftPadding: -36
    }

    Text {
        text: "km/h"
        color: "white"
        anchors.top: speedText.bottom
        anchors.horizontalCenter: speedText.horizontalCenter
        font.pointSize: 20
        topPadding: -16
        font.family: textFont.name
    }

    Text {
        id: gearText
        text: gearValue == 0 ? "N" : gearValue
        font.pointSize: 36
        font.family: textFont.name
        color: gearValue == 0 ? "green" : "white"
        padding: 36
        anchors.top: glowOverlay.bottom
        anchors.horizontalCenter: glowOverlay.horizontalCenter
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 10
            shadowScale: 1
            shadowColor: gearText.color
            brightness: 1.0
        }

        SequentialAnimation {
            loops: Animation.Infinite // Make the animation loop infinitely
            running: gearBlinking
            PropertyAnimation { target: gearText; property: "opacity"; to: 0.4; duration: 100 }
            PropertyAnimation { target: gearText; property: "opacity"; to: 1.0; duration: 100 }
        }
    }

    // Column {
    //     padding: 16
    //     spacing: 40
    //     anchors.left: parent.left
    //     anchors.right: glowOverlay.left
    //     anchors.verticalCenter: parent.verticalCenter

    //     Row {
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         height: 40
    //         spacing: 16

    //         Text {
    //             text: "Trip 1:"
    //             font.pointSize: 18
    //             font.family: textFont.name
    //             color: "white"
    //             anchors.verticalCenter: parent.verticalCenter
    //             topPadding: 8
    //         }

    //         Text {
    //             text: trip1 + " km"
    //             font.pointSize: 24
    //             font.family: textFont.name
    //             color: "white"
    //             anchors.verticalCenter: parent.verticalCenter
    //             topPadding: 8
    //         }
    //     }

    //     Row {
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         height: 40
    //         spacing: 16

    //         Text {
    //             text: "Trip 2:"
    //             font.pointSize: 18
    //             font.family: textFont.name
    //             color: "white"
    //             anchors.verticalCenter: parent.verticalCenter
    //             topPadding: 8
    //         }

    //         Text {
    //             text: trip2 + " km"
    //             font.pointSize: 24
    //             font.family: textFont.name
    //             color: "white"
    //             anchors.verticalCenter: parent.verticalCenter
    //             topPadding: 8
    //         }
    //     }
    // }

    Text {
        anchors.right: modeRow.left
        text: odo + " km"
        font.pointSize: 24
        font.family: textFont.name
        color: "white"
        rightPadding: 36
        anchors.verticalCenter: topRight.verticalCenter
    }

    Row {
        id: modeRow
        anchors.right: topRight.right
        anchors.verticalCenter: topRight.verticalCenter
        rightPadding: 36
        height: 40
        spacing: 16

        Text {
            text: "Mode:"
            font.pointSize: 24
            font.family: textFont.name
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "Race"
            font.pointSize: 24
            font.family: highLightTextFont.name
            color: "red"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: mapRow
        onClicked: stackView.push("MapsHome.qml")  // Switch to screen 2
    }

    Row {
        id: mapRow
        anchors.right: settingsAction.left
        anchors.top: bottomRight.top
        anchors.bottom: bottomRight.bottom
        spacing: 16
        rightPadding: 36

        Image {
            id: mapIcon
            source: "qrc:/Icons/maps.svg"
            width: 30
            height: 30
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width         // Adjust source size to match the item size
            sourceSize.height: height       // Adjust source size to match the item size
            layer.enabled: true
            property color iconColor: "white"
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowScale: 1
                shadowColor: mapIcon.iconColor
                brightness: 1.0
                colorization: 1.0
                colorizationColor: mapIcon.iconColor
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "Maps"
            font.pointSize: 24
            font.family: textFont.name
            color: mapIcon.iconColor
            anchors.verticalCenter: parent.verticalCenter
            topPadding: 8
        }

    }

    Row {
        id: settingsAction
        anchors.right: bottomRight.right
        anchors.top: bottomRight.top
        anchors.bottom: bottomRight.bottom
        spacing: 16
        rightPadding: 36

        // Image {
        //     id: settingsIcon
        //     source: "qrc:/Icons/maps.svg"
        //     width: 30
        //     height: 30
        //     fillMode: Image.PreserveAspectFit
        //     sourceSize.width: width         // Adjust source size to match the item size
        //     sourceSize.height: height       // Adjust source size to match the item size
        //     layer.enabled: true
        //     property color iconColor: "white"
        //     layer.effect: MultiEffect {
        //         shadowEnabled: true
        //         shadowScale: 1
        //         shadowColor: settingsIcon.iconColor
        //         brightness: 1.0
        //         colorization: 1.0
        //         colorizationColor: settingsIcon.iconColor
        //     }
        //     anchors.verticalCenter: parent.verticalCenter
        // }

        Text {
            text: "Settings"
            font.pointSize: 24
            font.family: textFont.name
            color: mapIcon.iconColor
            anchors.verticalCenter: parent.verticalCenter
            topPadding: 8
        }
    }


    Row {
        anchors.left: topLeft.right
        anchors.right: topRight.left
        anchors.top: topLeft.top
        spacing: 44
        topPadding: 30
        // leftPadding: 70

        IconIndicator {
            iconPath: "qrc:/Icons/abs-light.svg"
            onColor: warningColor
            offColor: offColor
            height: 30
            width: 30
            isOn: absWarning
            anchors.verticalCenter: parent.verticalCenter
        }

        IconIndicator {
            iconPath: "qrc:/Icons/engine.svg"
            onColor: warningColor
            offColor: offColor
            height: 30
            width: 30
            isOn: engineWarning
            anchors.verticalCenter: parent.verticalCenter
        }

        // Row {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     height: 40
        //     spacing: 16

        //     Text {
        //         text: "99 ℃"
        //         font.pointSize: 20
        //         font.family: textFont.name
        //         color: "white"
        //         anchors.verticalCenter: parent.verticalCenter
        //     }

        Image {
            id: tempIcon
            source: "qrc:/Icons/engine-temp.svg"
            width: 28
            height: 28
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width         // Adjust source size to match the item size
            sourceSize.height: height       // Adjust source size to match the item size
            layer.enabled: true
            property color iconColor:  {
                // if (engineTemp <= 15) {
                // return "lightblue";  // Low temperature (cold conditions)
                // } else if (engineTemp > 15 && engineTemp <= 30) {
                return "darkseagreen";      // Average temperature (optimal conditions)
                // } else if (engineTemp > 30 && engineTemp <= 40) {
                // return "firebrick";     // High temperature (hot conditions)
                // } else {
                // return "red";        // Very high temperature (overheating) }
            }
            layer.effect: MultiEffect {
                shadowEnabled: engineTemp > 35
                shadowScale: 1
                shadowColor: tempIcon.iconColor
                brightness: shadowEnabled ? 1.0 : 0.4
                colorization: 1.0
                colorizationColor: tempIcon.iconColor
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Image {
        id: mapPreview
        source: "https://i.redd.it/b49g8bxadrs21.png"
        height: root.height
        x: fuelMeter.x + fuelMeter.width
        width: root.width - x
        anchors.top: topRight.bottom
        anchors.bottom: bottomRight.top
        fillMode: Image.PreserveAspectCrop
        z: -10

        MouseArea {
            anchors.fill: parent
            onClicked: stackView.push("MapsHome.qml")
        }
    }

    Rectangle {
        anchors.left: mapPreview.left
        anchors.right: mapPreview.right
        anchors.top: root.top
        anchors.bottom: root.bottom
        z: -9
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: backgroundColor }
            GradientStop { position: 0.2; color: "transparent" }
            GradientStop { position: 0.8; color: "transparent" }
            GradientStop { position: 1.0; color: backgroundColor }
        }
    }
    Rectangle {
        anchors.left: mapPreview.left
        anchors.right: mapPreview.right
        anchors.top: root.top
        anchors.bottom: root.bottom
        height: mapPreview.height
        z: -9
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: backgroundColor }
            GradientStop { position: 0.25; color: "transparent" }
            GradientStop { position: 0.75; color: "transparent" }
            GradientStop { position: 1.0; color: backgroundColor }
        }
    }

}

