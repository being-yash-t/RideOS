import QtQuick 6.5
import QtQuick.Effects
import QtQuick.Shapes

Window {
    id: root
    visible: true
    width: 1024
    height: 600
    title: "RideOS"
    color: "#141414"

    FontLoader {
        id: numbersFont
        source: "qrc:/Fonts/Alien-Encounters-Italic.ttf"  // Replace with your actual font file path
    }

    FontLoader {
        id: textFont
        source: "qrc:/Fonts/Alien-Encounters-Regular.ttf"  // Replace with your actual font file path
    }


    // Values
    property int speedValue: 0
    property int tachoValue: 0
    property int gearValue: 0
    property bool engineWarning: true
    property bool absWarning: true

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
        var maxTacho = 6000;
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
        gearText.opacity = 1
    }


    // Constants
    property color warningColor: "#FFD700"
    property color offColor: "#3D3D3D"

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
    Shape {
        id: glowOverlay
        height: 420
        width: height
        anchors.centerIn: parent

        ShapePath {
            strokeColor: "transparent"
            fillGradient: RadialGradient {
                centerX: glowOverlay.width / 2
                centerY: glowOverlay.height / 2
                centerRadius: glowOverlay.width * 0.7
                focalX: centerX; focalY: centerY;
                // GradientStop { position: 0.0; color: "black"}
                // GradientStop { position: 0.5; color: "black"}
                // GradientStop { position: 0.6; color: "black"}
                // GradientStop { position: 0.6; color: Qt.rgba(speedColor.r, speedColor.g, speedColor.b, 0.6) }
                // GradientStop { position: 0.8; color: tachoColor }
                // GradientStop { position: 0.9; color: "black"}
                // GradientStop { position: 0.9; color: tachoColor }

                GradientStop { position: 0.0; color: "black"}
                GradientStop { position: 0.4; color: "black"}
                GradientStop { position: 0.55; color: Qt.rgba(speedColor.r, speedColor.g, speedColor.b, 0.4)}
                GradientStop { position: 0.6; color: "black"}
                GradientStop { position: 0.55; color: "black" }
                GradientStop { position: 0.75; color: tachoColor }
                GradientStop { position: 0.9; color: "black"}
                GradientStop { position: 0.9; color: tachoColor }
            }

            PathAngleArc {
                centerX: glowOverlay.width / 2
                centerY: glowOverlay.height / 2
                radiusX: glowOverlay.width / 2
                radiusY: glowOverlay.height / 2
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    Text {
        text: "x1000 RPM"
        color: "white"
        x: root.width * 0.64
        y: root.height * 0.8
        font.pointSize: 20
        font.family: textFont.name
        font.italic: true
    }


    Text {
        id: speedText
        anchors.centerIn: parent
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
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 20
        font.family: textFont.name
    }

    Text {
        id: gearText
        text: gearValue == 0 ? "N" : gearValue
        font.pointSize: 36
        font.family: textFont.name
        color: gearValue == 0 ? "green" : "white"
        padding: 30
        anchors.top: glowOverlay.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 10
            shadowScale: 1
            shadowColor: gearText.color
            brightness: 1.0
        }

        // Animation for blinking effect
        SequentialAnimation {
            loops: Animation.Infinite // Make the animation loop infinitely
            running: tachoValue > 4000
            PropertyAnimation { target: gearText; property: "opacity"; to: 0.4; duration: 100 }
            PropertyAnimation { target: gearText; property: "opacity"; to: 1.0; duration: 100 }
        }
    }

    Column {
        padding: 16
        spacing: 40
        anchors.verticalCenter: root.verticalCenter
        anchors.right: glowOverlay.left
        anchors.left: parent.left

        IconIndicator {
            iconPath: "qrc:/Icons/abs-light.svg"
            onColor: warningColor
            offColor: offColor
            height: 40
            width: 40
            isOn: absWarning
        }

        IconIndicator {
            iconPath: "qrc:/Icons/engine.svg"
            onColor: warningColor
            offColor: offColor
            height: 40
            width: 40
            isOn: engineWarning
        }
    }
}

