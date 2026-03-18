pragma Singleton

import QtQuick 2.15

QtObject {
    id: theme

    // Цвета, большая часть цветов - цвета кнопок, которые сделаны как svg-шки, в случае чего добавить их сюда не составляет большого труда
    property color darkBlue: "#024873"
    property color teal: "#04BFAD"
    property color textWhite: "#FFFFFF"

    // Размеры, в связи с жесткой фиксации здесь практически не нужны, остались для отладки потенциального ресайза
    // В случае если понадобиться скалирование, то будут вынесены сюда по группам их элементов и применяться на месте с коэфф. скалирования
    property real buttonSize: 60
    property real displayHeight: 156
    property real statusBarHeight: 24

    // Шрифты
    // Body_1
    property font fontDisplay: Qt.font({
        family: "Open Sans",
        weight: 600 // 600
        ,
        pixelSize: 50,
        lineHeight: 60,
        letterSpacing: 0.5
    })

    // Body_2
    property font fontExpression: Qt.font({
        family: "Open Sans",
        weight: 600 // 600
        ,
        pixelSize: 20,
        lineHeight: 30,
        letterSpacing: 0.5
    })

    // Body_3
    property font fontButton: Qt.font({
        family: "Open Sans",
        weight: 600 // 600
        ,
        pixelSize: 24,
        lineHeight: 30,
        letterSpacing: 1.0
    })

    //Body_custom, в референсах типографии отсутвует, извлек сам из css
    property font fontStatusBar: Qt.font({
        family: "Roboto",
        weight: 500   // 500
        ,
        pixelSize: 14
    })

    // SVG-ресурсы:
    property string bgDisplay: "qrc:/ui/assets/bg_display.svg"

    // Кнопки
    property string bgNumber: "qrc:/ui/assets/btn_num.svg"
    property string bgNumberActive: "qrc:/ui/assets/btn_num_active.svg"

    property string bgOperator: "qrc:/ui/assets/btn_operator.svg"
    property string bgOperatorActive: "qrc:/ui/assets/btn_operator_active.svg"

    // bgCancel это не оригинальная svg, а кастомная: по сути сочетание белого и красного фона в одной svg для корректной работы opacity по макету
    property string bgCancel: "qrc:/ui/assets/btn_cancel.svg"
    property string bgCancelActive: "qrc:/ui/assets/btn_cancel_active.svg"

    // Иконки кнопок
    property string iconDivide: "qrc:/ui/assets/division.svg"
    property string iconMultiply: "qrc:/ui/assets/multiplication.svg"
    property string iconEquals: "qrc:/ui/assets/equal.svg"
    property string iconPlusMinus: "qrc:/ui/assets/plus_minus.svg"
    property string iconMinus: "qrc:/ui/assets/minus.svg"
    property string iconParentheses: "qrc:/ui/assets/bkt.svg"
    property string iconPercent: "qrc:/ui/assets/percent.svg"
    property string iconPlus: "qrc:/ui/assets/plus.svg"

    // Иконки в статус баре
    property string iconWifi: "qrc:/ui/assets/wifi.svg"
    property string iconSignal: "qrc:/ui/assets/cellular.svg"
    property string iconBattery: "qrc:/ui/assets/battery.svg"
}
