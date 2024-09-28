import QtQuick 2.15
import QtQuick.Window 2.15
import QtPositioning 6.5

Window {
    visible: true
    width: 1024
    height: 600
    title: "Mappls Tile Example"

    property real tileSize: 256
    property real zoomLevel: 12
    property real latitude: 19.9975  // Example: Nashik latitude
    property real longitude: 73.7898 // Example: Nashik longitude

    // Calculate the tile coordinates for the given latitude, longitude, and zoom level
    property int xTile: Math.floor((longitude + 180) / 360 * Math.pow(2, zoomLevel))
    property int yTile: Math.floor((1 - Math.log(Math.tan(Math.PI / 4 + latitude * Math.PI / 180 / 2)) / Math.PI) / 2 * Math.pow(2, zoomLevel))

    Image {
        id: mapTile
        anchors.centerIn: parent
        width: tileSize
        height: tileSize
        fillMode: Image.PreserveAspectFit

        source: "ttps://apis.mappls.com/advancedmaps/v1/771be1f0a7d253f6bb8053ec3b7f1ea4/still_image?center=19.9975%2C73.7898&zoom=15&size=400x400&ssf=1&markers=19.9975%2C73.7898&markers_icon=https%3A%2F%2Fimg.icons8.com%2Fmaterial-outlined%2F96%2F000000%2Ftruck.png"
            .replace("{z}", zoomLevel.toString())
            .replace("{x}", xTile.toString())
            .replace("{y}", yTile.toString())

        onSourceChanged: console.log("Loading tile at zoom:", zoomLevel, "X:", xTile, "Y:", yTile)
    }
}
