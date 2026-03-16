pragma Singleton

import QtQuick 2.15

QtObject {
    id: theme

    property color darkBlue: "#024873" // Theme_1_1
    property color teal: "#04BFAD" // Theme_1_3
    property color textWhite: "#FFFFFF" // Theme_1_6

    property real buttonSize: 60
    property real buttonSpacing: 24
    property real screenMarginLeft: 24
    property real screenMarginRight: 24
    property real screenMarginTop: 24
    property real screenMarginBottom: 40
    property real displayHeight: 156
    property real statusBarHeight: 24
    property real displayRadius: 30

    property font fontDisplay: Qt.font({
        family: "Open Sans",
        weight: Font.SemiBold,
        pixelSize: 50,
        lineHeight: 60,
        letterSpacing: 0.5
    })

    property font fontExpression: Qt.font({
        family: "Open Sans",
        weight: Font.SemiBold,
        pixelSize: 20,
        lineHeight: 30,
        letterSpacing: 0.5
    })

    property font fontButton: Qt.font({
        family: "Open Sans",
        weight: Font.SemiBold,
        pixelSize: 24,
        lineHeight: 30,
        letterSpacing: 1.0
    })

    property font fontStatusBar: Qt.font({
        family: "Roboto",
        weight: Font.Medium,
        pixelSize: 14
    })

    property string bgDisplay: "qrc:/ui/assets/bg_display.svg"
    property string bgNumber: "qrc:/ui/assets/back_button-1.svg"
    property string bgOperator: "qrc:/ui/assets/back_button.svg"
    property string bgAction: "qrc:/ui/assets/back2_button.svg"
    property string bgOperatorActive: "qrc:/ui/assets/back_button-2.svg"

    property string iconDivide: "qrc:/ui/assets/division.svg"
    property string iconMultiply: "qrc:/ui/assets/multiplication.svg"
    property string iconEquals: "qrc:/ui/assets/equal.svg"
    property string iconPlusMinus: "qrc:/ui/assets/plus_minus.svg"
    property string iconMinus: "qrc:/ui/assets/minus.svg"
    property string iconParentheses: "qrc:/ui/assets/bkt.svg"
    property string iconPercent: "qrc:/ui/assets/percent.svg"
    property string iconPlus: "qrc:/ui/assets/plus.svg"

    property string iconWifi: "qrc:/ui/assets/wifi.svg"
    property string iconSignal: "qrc:/ui/assets/cellular.svg"
    property string iconBattery: "qrc:/ui/assets/battery.svg"
}
