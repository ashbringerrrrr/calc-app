#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "src/calcengine.h"

/**
 * @brief Точка входа в приложение
 *
 * Инициализирует QGuiApplication, регистрирует синглтоны и QML,
 * устанавливает глобальный фильтр событий и загружает main.qml
 */
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QFontDatabase::addApplicationFont(":/ui/styles/fonts/OpenSans-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/ui/styles/fonts/Roboto-Medium.ttf");

    // Регистрация CalcEngine и Theme для использования как qmlSingleton в ui
    qmlRegisterSingletonInstance("CalculatorModule", 1, 0, "CalcEngine", &CalculatorEngine::instance());
    qmlRegisterSingletonType(QUrl("qrc:/ui/styles/Theme.qml"), "ThemeModule", 1, 0, "Theme");

    // Решил добавить захват нажатия кнопок с клавиатуры -> установил фильтра событий для обработки нажатий
    app.installEventFilter(&CalculatorEngine::instance());

    const QUrl url(QStringLiteral("qrc:/ui/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
