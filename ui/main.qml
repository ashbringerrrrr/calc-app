import QtQuick 2.15
import QtQuick.Window 2.15
import ThemeModule 1.0
import "views"

Window {
    height: 640
    title: "Calculator"
    visible: true
    width: 360

    minimumWidth: 360
    minimumHeight: 640

    color: Theme.darkBlue

    property bool showSecret: false

    Loader {
        anchors.fill: parent
        sourceComponent: showSecret ? secretComp : calcViewComp
    }

    Component {
        id: calcViewComp
        CalcView {}
    }
}
