import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    visible: true
    width: 1024
    height: 600
    title: "RideOS"
    color: backgroundColor

    property color backgroundColor: "#141414"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "Home.qml"
        focus: true
        Keys.onLeftPressed: stackView.pop()
        Keys.onRightPressed: stackView.push("MapsHome.qml")
    }

}
