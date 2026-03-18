#include <gtest/gtest.h>
#include "../src/calcengine.h"

#include <QObject>
#include <QCoreApplication>
// Набросал самые базовые unit-тесты для calcengine

// Тест сложения
TEST(CalculatorTest, BasicAddition) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("2+2");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "4");
}

// Тест приоритета операций
TEST(CalculatorTest, Precedence) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("2+2*2");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "6");
}

// Тест скобок
TEST(CalculatorTest, Parentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("(2+2)*2");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "8");
}

// Тест вложенных скобок
TEST(CalculatorTest, NestedParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("((2+3)*4)/2"); // (5*4)/2 = 10
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "10");
}

// Тест деления на ноль
TEST(CalculatorTest, DivisionByZero) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("5/0");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");
}

// Тест точности и работы с болшим кол-вом знаков
TEST(CalculatorTest, HighPrecision) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("1/3");
    eng.calculate();
    QString res = eng.display();
    EXPECT_TRUE(res.contains("."));
    EXPECT_GT(res.length(), 30);
    EXPECT_TRUE(res.contains("33333333333333333333"));
}

// Тест отрицательных чисел
TEST(CalculatorTest, NegativeNumbers) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("-5+3");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "-2");
}

// Тест дробей
TEST(CalculatorTest, Decimals) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("0.5+0.5");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "1");
}

// Тест на сверку работы BigFloat с действительно большой дробный частью
TEST(CalculatorTest, ExtremePrecision) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    // Ожидаемое: 0.14285714285714285714285714285714285714...
    eng.setExpressionDirect("1/7");
    eng.calculate();
    QString res = eng.display();

    EXPECT_TRUE(res.contains("."));
    EXPECT_GT(res.length(), 45); // В запас у cpp_dec_float_50

    // Проверка повторения "142857"
    std::string s = res.toStdString();
    std::string fraction = s.substr(2);
    EXPECT_EQ(fraction.substr(0, 6), "142857");
    EXPECT_EQ(fraction.substr(6, 6), "142857");
    EXPECT_EQ(fraction.substr(12, 6), "142857");
    EXPECT_EQ(fraction.substr(30, 6), "142857");
}

// Тест на операцию с большими числами (умножение)
TEST(CalculatorTest, LargeNumbersMultiplication) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("12345678901234567890.123456789 * 2");
    eng.calculate();
    QString res = eng.display();
    // Ожидаемое: 24691357802469135780.246913578
    EXPECT_EQ(res.toStdString(), "24691357802469135780.246913578");
}

// Тест выражения глубокой вложенностью скобок
TEST(CalculatorTest, DeepNestedParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("((((((1+1))))))");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "2");

    eng.clear();

    eng.setExpressionDirect("2*(((3+4)*5))");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "70");
}

// Тест операций смешанного приоритета
TEST(CalculatorTest, LongChainMixedOperations) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    // 1 + 2 * 3 - 4 / 2 + 5 * (2 + 3)
    // 1 + 6 - 2 + 5 * 5
    // 1 + 6 - 2 + 25
    // 30
    eng.setExpressionDirect("1+2*3-4/2+5*(2+3)");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "30");
}

// Тест выражения с несколькими подряд открывающими скобками (без закрытия сразу)
TEST(CalculatorTest, SequentialOpenParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    // (((1+2)*(3+4)))
    // (3 * 7) = 21
    eng.setExpressionDirect("(((1+2)*(3+4)))");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "21");
}

// Тест обработки унарного минуса
TEST(CalculatorTest, ComplexUnaryMinus) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    // -(-5) = 5
    eng.setExpressionDirect("-(-5)");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "5");

    eng.clear();
    // -(2+3) = -5
    eng.setExpressionDirect("-(2+3)");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "-5");

    eng.clear();
    // -2 * -3 = 6
    eng.setExpressionDirect("-2*-3");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "6");

    eng.clear();
    // 10 + -5 = 5
    eng.setExpressionDirect("10+-5");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "5");
}

// Тест обработки ошибок с открывающимися скобками. Автозакрытие оставшейся скобки
TEST(CalculatorTest, ErrorOnlyOpenParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("((2+2");
    // Вот такое ожидаемое преобразование должно быть: ((2+2)) = 4
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "4");
}

// Тест обработки ошибок с лишними закрывающими скобками
TEST(CalculatorTest, ErrorExtraCloseParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("2+2)");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");

    eng.clear();
    eng.setExpressionDirect("2+(2))");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");
}

// Тест обработки ошибок с пустыми скобками
TEST(CalculatorTest, ErrorEmptyParentheses) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("2+()");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");
}

// Тест деления на ноль в результате вычислений
TEST(CalculatorTest, ErrorDivisionByZeroComplex) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    // 10 / (2-2)
    eng.setExpressionDirect("10/(2-2)");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");
}

// Тест на обработку ошибок из-за неверных символов
TEST(CalculatorTest, ErrorInvalidCharacters) {
    auto& eng = CalculatorEngine::instance();
    eng.clear();
    eng.setExpressionDirect("2+2a");
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");

    eng.clear();
    eng.setExpressionDirect("2++2"); // Двойной плюс
    // Токенайзер посчитает это как две операции
    // Поэтому я вижу что это и нужно обработать
    //  как ошибку по текущей логике calcengine
    // В RPN это сделано как runtime_error "not enough operands".
    eng.calculate();
    EXPECT_EQ(eng.display().toStdString(), "Ошибка");
}


