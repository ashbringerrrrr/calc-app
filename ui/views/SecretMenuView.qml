import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ThemeModule 1.0

Item {
    id: root
    anchors.fill: parent

    // Сигнал для возврата назад к CalcView
    signal backRequested

    Rectangle {
        anchors.fill: parent
        color: Theme.darkBlue
    }

    Text {
        text: "Секретное меню"
        font.family: Theme.fontDisplay.family
        font.pixelSize: 36
        font.weight: Font.Bold
        color: Theme.textWhite

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: backButton.top
        anchors.bottomMargin: 60
    }

    Button {
        id: backButton
        text: "Назад"

        implicitWidth: 200
        implicitHeight: 60

        anchors.centerIn: parent

        background: Rectangle {
            color: backButton.pressed ? Theme.teal : Theme.teal
            opacity: backButton.pressed ? 1.0 : 0.8
            radius: 30
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        contentItem: Text {
            text: backButton.text
            color: Theme.darkBlue
            font.family: Theme.fontButton.family
            font.pixelSize: 24
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            root.backRequested();
        }
    }
}
