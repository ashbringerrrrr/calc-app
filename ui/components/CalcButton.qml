import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import ThemeModule 1.0

Item {
    id: root

    property string actionId: ""
    property string btnType: "number"
    property string displayText: ""
    property string iconSource: ""
    property bool isActive: false

    signal actionTriggered(string id)
    signal longPressTriggered(string id)

    implicitWidth: Theme.buttonSize
    implicitHeight: Theme.buttonSize

    // Эскиз логики фона
    property string currentBgSource: {
        if (btnType === "action")
            return Theme.bgAction;

        if ((btnType === "operator" && isActive) || (btnType === "equals" && isActive)) {
            return Theme.bgOperatorActive;
        }

        if (btnType === "equals")
            return Theme.bgOperator;
        if (btnType === "operator")
            return Theme.bgOperator;

        return Theme.bgNumber;
    }

    // определение цвета
    property color contentColor: {
        if (btnType === "action")
            return Theme.textWhite;

        if (btnType === "number")
            return Theme.darkBlue;

        if (btnType === "operator" || btnType === "equals")
            return Theme.textWhite;

        return Theme.textWhite;
    }

    Image {
        anchors.fill: parent
        source: root.currentBgSource
        fillMode: Image.Stretch
        smooth: true
        visible: source !== ""
    }

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
                id: iconSourceImage
                anchors.fill: parent
                source: iconSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: false
            }

            ColorOverlay {
                anchors.fill: iconSourceImage
                source: iconSourceImage
                color: root.contentColor
                cached: true
            }
        }

        Text {
            anchors.fill: parent
            text: displayText
            visible: iconSource === ""
            font.family: Theme.fontButton.family
            font.weight: Theme.fontButton.weight
            font.pixelSize: Theme.fontButton.pixelSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.contentColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (actionId !== "")
                root.actionTriggered(actionId);
        }
        onPressAndHold: {
            if (actionId !== "")
                root.longPressTriggered(actionId);
        }
    }
}
