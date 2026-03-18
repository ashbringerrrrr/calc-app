import QtQuick 2.15
import QtQuick.Window 2.15
import CalculatorModule 1.0
import ThemeModule 1.0
import "views"

Window {
    id: mainWindow

    height: 640
    title: "Calculator"
    visible: true
    width: 360

    // Жесткая фиксация размеров по макету в figma
    minimumWidth: 360
    maximumWidth: 360
    minimumHeight: 640
    maximumHeight: 640

    color: Theme.darkBlue

    property bool showSecret: false
    property bool designCheckMode: false

    // F1-клавиша для открытия оверлея и сверки с скриншотом макета
    Shortcut {
        sequence: "F1"
        onActivated: designCheckMode = !designCheckMode
    }

    Loader {
        anchors.fill: parent
        sourceComponent: showSecret ? secretComp : calcViewComp
    }

    Connections {
        target: CalcEngine
        function onOpenSecretMenu() {
            mainWindow.showSecret = true;
        }
    }

    // Основный вид - калькулятор
    Component {
        id: calcViewComp
        CalcView {}
    }

    // Окно секретного меню
    Component {
        id: secretComp
        SecretMenuView {
            onBackRequested: {
                mainWindow.showSecret = false;
                CalcEngine.clear(); // Необязательно, но оставил для наглядности
            }
        }
    }

    // Оверлей для сверки с скриншотом макета
    DesignOverlay {
        visible: designCheckMode
    }
}
