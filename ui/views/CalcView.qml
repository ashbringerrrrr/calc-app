import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import ThemeModule 1.0
import "../components"

Item {
    id: viewRoot

    property string displayText: "865"
    property string expressionText: "368+497"

    property string activeOperatorId: ""

    // Заглушка отработки функционала кнопок
    function handleButtonAction(actionId) {
        console.log("Clicked:", actionId);

        // Набросок обработки операций
        const ops = ["op_add", "op_subtract", "op_multiply", "op_divide", "op_equals"];

        if (ops.includes(actionId)) {
            activeOperatorId = actionId;
        } else if (actionId === "act_clear") {
            activeOperatorId = "";
        } else if (actionId.startsWith("digit_") || actionId === "op_percent" || actionId.startsWith("func_")) {}
    }

    function handleLongPress(actionId) {
        console.log("Long Press:", actionId);
        if (actionId === "op_equals")
        // заготовка под открытие секректного меню
        {}
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.statusBarHeight
            color: Theme.teal

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                spacing: 8

                Image {
                    width: 19
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: Theme.iconWifi
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
                Image {
                    width: 16
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: Theme.iconSignal
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
                Image {
                    width: 16
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: Theme.iconBattery
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Text {
                    text: "12:30"
                    font: Theme.fontStatusBar
                    color: Theme.textWhite
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.displayHeight
            clip: true

            Image {
                anchors.fill: parent
                z: -1
                fillMode: Image.Stretch
                smooth: true
                source: Theme.bgDisplay
            }

            Text {
                id: expressionTextItem
                text: expressionText
                font.family: Theme.fontExpression.family
                font.weight: Theme.fontExpression.weight
                font.pixelSize: Theme.fontExpression.pixelSize
                color: Theme.textWhite
                horizontalAlignment: Text.AlignRight

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.topMargin: 44
                anchors.leftMargin: 39
                anchors.rightMargin: 41

                width: parent.width - 39 - 41
                elide: Text.ElideLeft
            }

            Text {
                id: resultTextItem
                text: displayText
                font.family: Theme.fontDisplay.family
                font.weight: Theme.fontDisplay.weight
                font.pixelSize: Theme.fontDisplay.pixelSize
                color: Theme.textWhite
                horizontalAlignment: Text.AlignRight

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.bottomMargin: 14
                anchors.leftMargin: 39
                anchors.rightMargin: 40

                width: parent.width - 39 - 40
                elide: Text.ElideLeft
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.screenMarginLeft
                anchors.rightMargin: Theme.screenMarginRight
                anchors.topMargin: Theme.screenMarginTop
                anchors.bottomMargin: Theme.screenMarginBottom

                columns: 4
                rowSpacing: Theme.buttonSpacing
                columnSpacing: Theme.buttonSpacing

                property var buttons: [
                    {
                        id: "func_parentheses",
                        type: "operator",
                        text: "",
                        icon: Theme.iconParentheses
                    },
                    {
                        id: "func_plus_minus",
                        type: "operator",
                        text: "",
                        icon: Theme.iconPlusMinus
                    },
                    {
                        id: "op_percent",
                        type: "operator",
                        text: "%",
                        icon: ""
                    },
                    {
                        id: "op_divide",
                        type: "operator",
                        text: "",
                        icon: Theme.iconDivide
                    },
                    {
                        id: "digit_7",
                        type: "number",
                        text: "7",
                        icon: ""
                    },
                    {
                        id: "digit_8",
                        type: "number",
                        text: "8",
                        icon: ""
                    },
                    {
                        id: "digit_9",
                        type: "number",
                        text: "9",
                        icon: ""
                    },
                    {
                        id: "op_multiply",
                        type: "operator",
                        text: "",
                        icon: Theme.iconMultiply
                    },
                    {
                        id: "digit_4",
                        type: "number",
                        text: "4",
                        icon: ""
                    },
                    {
                        id: "digit_5",
                        type: "number",
                        text: "5",
                        icon: ""
                    },
                    {
                        id: "digit_6",
                        type: "number",
                        text: "6",
                        icon: ""
                    },
                    {
                        id: "op_subtract",
                        type: "operator",
                        text: "",
                        icon: Theme.iconMinus
                    },
                    {
                        id: "digit_1",
                        type: "number",
                        text: "1",
                        icon: ""
                    },
                    {
                        id: "digit_2",
                        type: "number",
                        text: "2",
                        icon: ""
                    },
                    {
                        id: "digit_3",
                        type: "number",
                        text: "3",
                        icon: ""
                    },
                    {
                        id: "op_add",
                        type: "operator",
                        text: "",
                        icon: Theme.iconPlus
                    },
                    {
                        id: "act_clear",
                        type: "action",
                        text: "C",
                        icon: ""
                    },
                    {
                        id: "digit_0",
                        type: "number",
                        text: "0",
                        icon: ""
                    },
                    {
                        id: "digit_dot",
                        type: "number",
                        text: ".",
                        icon: ""
                    },
                    {
                        id: "op_equals",
                        type: "equals",
                        text: "",
                        icon: Theme.iconEquals
                    }
                ]

                Repeater {
                    model: parent.buttons

                    delegate: CalcButton {
                        actionId: modelData.id
                        btnType: modelData.type
                        displayText: modelData.text
                        iconSource: modelData.icon

                        isActive: (modelData.id === viewRoot.activeOperatorId)

                        Layout.alignment: Qt.AlignCenter
                        Layout.preferredWidth: Theme.buttonSize
                        Layout.preferredHeight: Theme.buttonSize

                        onActionTriggered: function (id) {
                            viewRoot.handleButtonAction(id);
                        }

                        onLongPressTriggered: function (id) {
                            viewRoot.handleLongPress(id);
                        }
                    }
                }
            }
        }
    }
}
