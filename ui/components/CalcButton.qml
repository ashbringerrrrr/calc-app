import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import ThemeModule 1.0

Item {
    id: root
    property string actionId: ""
    property string btnType: "number" // "number", "operator", "action"
    property string displayText: ""
    property string iconSource: ""

    // Флаг активного состояния (кнопка нажата)
    property bool isActive: false

    signal actionTriggered(string id)
    signal longPressTriggered(string id)

    implicitWidth: Theme.buttonSize
    implicitHeight: Theme.buttonSize

    // Выбор стиля-svgшки в зависимости от типа кнопки и текущего isActive-флага
    property string currentBgSource: {
        if (btnType === "operator") {
            return isActive ? Theme.bgOperatorActive : Theme.bgOperator;
        }

        if (btnType === "number") {
            return isActive ? Theme.bgNumberActive : Theme.bgNumber;
        }

        if (btnType === "action") {
            return isActive ? Theme.bgCancelActive : Theme.bgCancel;
        }

        return Theme.bgNumber;
    }

    property color contentColor: (btnType === "number") ? Theme.darkBlue : Theme.textWhite

    Image {
        anchors.fill: parent
        source: currentBgSource
        fillMode: Image.Stretch
        smooth: true
    }

    // Анимация нажатия с затемнением
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#000000"
        opacity: mouseArea.pressed ? 0.15 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    scale: mouseArea.pressed ? 0.92 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }

    Item {
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: parent.height * 0.5

        Item {
            anchors.fill: parent
            visible: iconSource !== ""
            Image {
                id: iconImg
                anchors.fill: parent
                source: iconSource
                visible: false
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: root.contentColor
                cached: true
            }
        }
        Text {
            anchors.fill: parent
            text: displayText
            visible: iconSource === ""
            font: Theme.fontButton
            color: root.contentColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        pressAndHoldInterval: 4000

        onClicked: {
            if (actionId !== "")
                root.actionTriggered(actionId);
        }
        onPressAndHold: {
            console.log("[CalcButton] LONG PRESS DETECTED (4s):", actionId);
            if (actionId !== "")
                root.longPressTriggered(actionId);
        }
    }
}
