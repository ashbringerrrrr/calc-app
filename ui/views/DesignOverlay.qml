import QtQuick 2.15

Item {
    id: overlayRoot
    anchors.fill: parent
    visible: false
    z: 9999

    // Ссылка на скриншот макета, чтобы визуально свериться
    property string mockupSource: "qrc:/ui/assets/calculator_mockup.png"

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.0
    }

    Image {
        anchors.fill: parent
        source: mockupSource
        fillMode: Image.Stretch
        smooth: true
        opacity: 0.5
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        text: "DESIGN CHECK MODE [ON]"
        color: "#FF0000"
        font.pixelSize: 16
        font.bold: true
        style: Text.Outline
        styleColor: "white"
        z: 10000
    }
}
