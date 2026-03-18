#ifndef CALCENGINE_H
#define CALCENGINE_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QKeyEvent>
#include <QVector>
#include <QChar>
#include <boost/multiprecision/cpp_dec_float.hpp>

using BigFloat = boost::multiprecision::cpp_dec_float_50;

/**
 * @brief Основной движок калькулятора, реализующий логику вычислений и парсинга выражений
 *
 * Класс реализует паттерн Singleton, обрабатывает ввод данных. Для парсинга выражений
 * используется алгоритм сортировочной станции (Shunting-yard algorithm), а для вычисления результата
 * обратная польская запись (RPN). Для обеспечения работы с большими числами(и конкретно дробями) используется
 * BigFloat собранный из Boost.Multiprecision (boost::multiprecision::cpp_dec_float_50).
 */
class CalculatorEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString expression READ expression NOTIFY expressionChanged)
    Q_PROPERTY(QString display READ display NOTIFY displayChanged)
    Q_PROPERTY(bool secretMenuReady READ secretMenuReady NOTIFY secretMenuReadyChanged)

public:
    explicit CalculatorEngine(QObject *parent = nullptr);

    /**
     * @brief Возвращает единственный экземпляр класса как в обычном синглтоне
     * @return Ссылка на экземпляр CalculatorEngine
     */
    static CalculatorEngine& instance();

    /// @brief Возвращает текущее текстовое выражение
    QString expression() const { return m_expression; }

    /// @brief Возвращает текущий результат вычислений
    QString display() const { return m_display; }

    /// @brief Проверяет, активен ли режим ожидания кода секретного меню
    bool secretMenuReady() const { return m_waitingForCode; }

    /**
     * @brief Метод для gtest-ов в обход GUI
     * @param expr Строка нового выражения
     */
    void setExpressionDirect(const QString& expr) {
        m_expression = expr;
        m_lastWasResult = false;
        emit expressionChanged();
    }

public slots:
    /// @brief Добавляет цифру в текущее выражение
    /// @param digit Строковое представление цифры
    void inputDigit(const QString &digit);

    /// @brief Добавляет десятичную точку
    void inputDot();

    /// @brief Добавляет оператор (+, -, *, /).
    /// @param op Строковое представление оператора
    void inputOperator(const QString &op);

    /// @brief Запускает процесс вычисления текущего выражения
    void calculate();

    /// @brief Очищает выражение и сбрасывает результат
    void clear();

    /// @brief Меняет знак текущего числа на противоположный
    void toggleSign();

    /// @brief Преобразует текущее число в проценты(просто деление на 100)
    void inputPercent();

    /// @brief Вставляет скобки с учетом контекста (открытие, закрытие или умножение)
    void inputParentheses();

    /// @brief Запускает последовательность ввода кода для секретного меню
    void onEqualsLongPressed();

    /**
     * @brief Обрабатывает события клавиатуры.
     * @param event Указатель на событие нажатия клавиши.
     * @return true, если событие было обработано, если нет то false
     */
    bool handleKeyEvent(QKeyEvent *event);

signals:
    void expressionChanged();       ///< Сигнал изменения выражения
    void displayChanged();          ///< Сигнал изменения результата
    void openSecretMenu();          ///< Сигнал открытия секретного меню
    void secretMenuReadyChanged();  ///< Сигнал изменения статуса ожидания кода

protected:
    /**
     * @brief Фильтр событий для перехвата нажатий клавиш до их обработки окном
     * @param obj Объект-получатель события
     * @param event Указатель на событие
     * @return true, если событие обработано, если нет то false
     */
    bool eventFilter(QObject *obj, QEvent *event) override;

private:
    // Структуры и методы для парсинга выражений (Shunting-yard algorithm) и вычисления через RPN
    enum class TokenType { Number, Operator, LParen, RParen };

    struct Token {
        TokenType type = TokenType::Number;
        QString value;
        int precedence = 0;
        bool isLeftAssociative = true;

        Token() {}
        Token(TokenType t, const QString& v, int prec = 0, bool assoc = true)
            : type(t), value(v), precedence(prec), isLeftAssociative(assoc) {}
    };

    /**
     * @brief Разбивает строку выражения на токены
     * @param expr Входная строка выражения
     * @return Вектор токенов
     * @throws std::runtime_error при обнаружении недопустимого символа
     */
    QVector<Token> tokenize(const QString &expr);

    /**
     * @brief Преобразует запись в обратную польскую (RPN)
     * @param tokens Вектор входных токенов
     * @return Вектор токенов в формате RPN
     * @throws std::runtime_error при несоответствии скобок
     */
    QVector<Token> toRPN(const QVector<Token> &tokens);

    /**
     * @brief Вычисляет значение выражения в формате RPN
     * @param rpn Вектор токенов в обратной польской записи
     * @return Результат вычисления типа BigFloat
     * @throws std::runtime_error при делении на ноль или ошибке стека
     */
    BigFloat evaluateRPN(const QVector<Token> &rpn);

    /**
     * @brief Форматирует число высокой точности в строку
     * @param val Число типа BigFloat
     * @return Строковое представление без лишних нулей
     */
    QString bigFloatToString(const BigFloat &val);

    /// @brief Возвращает приоритет оператора (1 для +-, 2 для */)
    int getPrecedence(const QChar &op);

    /// @brief Проверяет, является ли символ оператором
    bool isOperator(const QChar &c);

    // Состояние движка
    QString m_expression;
    QString m_display;
    bool m_lastWasResult;

    // --- Секретное меню ---
    QTimer m_codeTimer;
    bool m_waitingForCode;
    QString m_codeBuffer;

    void startSecretCodeSequence();
    void resetSecretCodeSequence();
    void processCodeInput(const QString &digit);
};


#endif // CALCENGINE_H
