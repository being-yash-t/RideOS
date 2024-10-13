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
    }

    Component {
        id:	map
        Rectangle {

            height: stackView.height
            color: backgroundColor

            Text {
                text: "Screen 2"
                anchors.centerIn: parent
                font.pointSize: 20
            }

            Button {
                text: "Go Back to Screen 1"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: stackView.pop()  // Go back to screen 1
            }
        }
    }
}
