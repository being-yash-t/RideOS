import QtQuick
import QtLocation
import QtPositioning

Item {

    Image {
        id: topLeft
        source: "qrc:/Icons/divider-top-left.svg"
        height: 80
        width: 180
        opacity: 0.8
        z: 1

        MouseArea {
            anchors.fill: parent
            onClicked: stackView.pop()
        }
    }

    Image {
        anchors.verticalCenter: topLeft.verticalCenter
        x: 30
        source: "qrc:/Icons/chevron-left.svg"
        height: 30
        width: 30
        sourceSize.height: height
        sourceSize.width: width
        fillMode: Image.PreserveAspectFit
        z: 2
    }

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14
        property geoCoordinate startCentroid

        PinchHandler {
            id: pinch
            target: null
            onActiveChanged: if (active) {
                                 map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
                             }
            onScaleChanged: (delta) => {
                                map.zoomLevel += Math.log2(delta)
                                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                            }
            onRotationChanged: (delta) => {
                                   map.bearing -= delta
                                   map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                               }
            grabPermissions: PointerHandler.TakeOverForbidden
        }
        WheelHandler {
            id: wheel
            rotationScale: 1/120
            property: "zoomLevel"
        }
        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
        }
        Shortcut {
            enabled: map.zoomLevel < map.maximumZoomLevel
            sequence: StandardKey.ZoomIn
            onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
        }
        Shortcut {
            enabled: map.zoomLevel > map.minimumZoomLevel
            sequence: StandardKey.ZoomOut
            onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
        }
    }
}
