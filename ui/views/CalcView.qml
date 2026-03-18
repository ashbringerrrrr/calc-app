import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ThemeModule 1.0
import "../components"
import CalculatorModule 1.0

Item {
    id: viewRoot
    signal openSecretMenu

    property string displayText: CalcEngine.display
    property string expressionText: CalcEngine.expression

    // Хранит ID последней активной кнопки для isActive-флага для двух типов кнопок отдельно
    property string activeOperatorId: ""
    property string activeDigitId: ""

    /**
         * @brief Обработчик нажатий кнопок,
         * вызывает методы CalcEngine и отвечает за запись id текущей нажатой кнопки
         */
    function handleButtonAction(actionId) {
        if (actionId.startsWith("digit_")) {
            let val = actionId.replace("digit_", "");

            if (val === "dot") {
                CalcEngine.inputDot();
            } else {
                CalcEngine.inputDigit(val);
            }
            activeDigitId = actionId;
            activeOperatorId = "";
        } else if (actionId === "act_clear") {
            CalcEngine.clear();
            activeOperatorId = "act_clear";
            activeDigitId = "";
        } else {
            if (actionId === "op_percent")
                CalcEngine.inputPercent();
            else if (actionId === "func_plus_minus")
                CalcEngine.toggleSign();
            else if (actionId === "func_parentheses")
                CalcEngine.inputParentheses();
            else if (actionId === "op_equals")
                CalcEngine.calculate();
            else if (["op_add", "op_subtract", "op_multiply", "op_divide"].includes(actionId)) {
                let map = {
                    "op_add": "+",
                    "op_subtract": "-",
                    "op_multiply": "*",
                    "op_divide": "/"
                };
                CalcEngine.inputOperator(map[actionId]);
            }

            activeOperatorId = actionId;
            activeDigitId = "";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Статус-бар
        Rectangle {
            id: statusBarRect
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.statusBarHeight
            color: Theme.teal

            Item {
                id: statusWrapper
                width: 118
                height: 24
                anchors.right: parent.right
                anchors.top: parent.top

                Image {
                    id: iconWifi
                    width: 18.045
                    height: 16
                    source: Theme.iconWifi
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    anchors.top: parent.top
                    anchors.topMargin: 4
                }
                Image {
                    id: iconSignal
                    width: 16
                    height: 16
                    source: Theme.iconSignal
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    anchors.left: parent.left
                    anchors.leftMargin: 35
                    anchors.top: parent.top
                    anchors.topMargin: 4
                }
                Image {
                    id: iconBattery
                    width: 16
                    height: 16
                    source: Theme.iconBattery
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    anchors.left: parent.left
                    anchors.leftMargin: 55

                    anchors.top: parent.top
                    anchors.topMargin: 4
                }
                Text {
                    text: "12:30"
                    font: Theme.fontStatusBar
                    color: Theme.textWhite

                    anchors.left: parent.left
                    anchors.leftMargin: 74

                    anchors.top: parent.top
                    anchors.topMargin: 1
                    // В результате борьбы с фигмой итог таков: Roboto Medium имеет 2px запаса в
                    // своем layer properties, следовательно вот и 1px из 3х требуемых
                }
            }
        }

        // Дисплей
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

            // Контейнер выражения(с скроллом на случай выхода за пределы)
            Item {
                id: exprContainer
                width: 280
                height: 30
                anchors.left: parent.left
                anchors.leftMargin: 39
                anchors.top: parent.top
                anchors.topMargin: 44
                clip: true

                Flickable {
                    id: exprFlickable
                    anchors.fill: parent
                    contentWidth: Math.max(exprText.implicitWidth, width)
                    contentHeight: parent.height
                    interactive: contentWidth > width
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onWheel: {
                            var d = wheel.angleDelta.y / 8;
                            exprFlickable.contentX -= d * 3;
                            exprFlickable.contentX = Math.max(0, Math.min(exprFlickable.contentX, exprFlickable.contentWidth - exprFlickable.width));
                        }
                    }

                    ScrollBar.horizontal: ScrollBar {
                        policy: exprFlickable.contentWidth > exprFlickable.width ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        active: true
                        z: 10
                        contentItem: Rectangle {
                            implicitHeight: 4
                            radius: 2
                            color: "#60FFFFFF"
                            opacity: parent.active ? 1.0 : 0.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }

                    Text {
                        id: exprText
                        text: expressionText
                        font: Theme.fontExpression
                        color: Theme.textWhite
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter

                        // Выравнивание текста справа с ростом влево
                        x: exprFlickable.width - Math.min(exprFlickable.width, exprText.implicitWidth)
                        y: (exprFlickable.height - exprText.implicitHeight) / 2

                        visible: text !== ""

                        onTextChanged: {
                            if (exprFlickable.contentWidth > exprFlickable.width) {
                                Qt.callLater(function () {
                                    exprFlickable.contentX = exprFlickable.contentWidth - exprFlickable.width;
                                });
                            } else {
                                exprFlickable.contentX = 0;
                            }
                        }
                    }
                }
            }

            // Контейнер результата
            Item {
                id: resContainer
                anchors.left: parent.left
                anchors.leftMargin: 39
                anchors.top: parent.top
                anchors.topMargin: 82
                width: 281
                height: 60
                clip: true

                Flickable {
                    id: resFlickable
                    anchors.fill: parent
                    contentWidth: Math.max(resText.implicitWidth, width)
                    contentHeight: parent.height
                    interactive: contentWidth > width
                    flickableDirection: Flickable.HorizontalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onWheel: {
                            var d = wheel.angleDelta.y / 8;
                            resFlickable.contentX -= d * 3;
                            resFlickable.contentX = Math.max(0, Math.min(resFlickable.contentX, resFlickable.contentWidth - resFlickable.width));
                        }
                    }

                    ScrollBar.horizontal: ScrollBar {
                        policy: resFlickable.contentWidth > resFlickable.width ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        active: true
                        z: 10
                        contentItem: Rectangle {
                            implicitHeight: 6
                            radius: 3
                            color: "#80FFFFFF"
                            opacity: parent.active ? 1.0 : 0.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }

                    Text {
                        id: resText
                        text: displayText
                        font: Theme.fontDisplay
                        color: Theme.textWhite
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter

                        // Выравнивание текста справа с ростом влево
                        x: resFlickable.width - Math.min(resFlickable.width, resText.implicitWidth)
                        y: (resFlickable.height - resText.implicitHeight) / 2

                        onTextChanged: {
                            if (resFlickable.contentWidth > resFlickable.width) {
                                Qt.callLater(function () {
                                    resFlickable.contentX = resFlickable.contentWidth - resFlickable.width;
                                });
                            } else {
                                resFlickable.contentX = 0;
                            }
                        }
                    }
                }
            }
        }

        // Грид кнопок
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            GridLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 24
                anchors.bottomMargin: 40
                columns: 4
                rowSpacing: 24
                columnSpacing: 24

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
                        text: "",
                        icon: Theme.iconPercent
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
                        type: "operator",
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

                        // Отображение того что активная кнопка нажата для двух типов кнопок
                        isActive: {
                            if (modelData.type === "number") {
                                return modelData.id === viewRoot.activeDigitId;
                            } else {
                                return modelData.id === viewRoot.activeOperatorId;
                            }
                        }

                        Layout.alignment: Qt.AlignCenter
                        Layout.preferredWidth: Theme.buttonSize
                        Layout.preferredHeight: Theme.buttonSize

                        onActionTriggered: viewRoot.handleButtonAction(id)
                        onLongPressTriggered: {
                            if (id === "op_equals")
                                CalcEngine.onEqualsLongPressed();
                        }
                    }
                }
            }
        }
    }
}
