#include "calcengine.h"
#include <QDebug>
#include <QStack>
#include <QRegularExpression>
#include <stdexcept>
#include <locale>
#include <sstream>

CalculatorEngine::CalculatorEngine(QObject *parent)
    : QObject(parent), m_expression(""), m_display("0"), m_lastWasResult(false),
    m_waitingForCode(false)
{
    connect(&m_codeTimer, &QTimer::timeout, this, [this]() {
        resetSecretCodeSequence();
    });
}

CalculatorEngine& CalculatorEngine::instance() {
    static CalculatorEngine _instance;
    return _instance;
}

int CalculatorEngine::getPrecedence(const QChar &op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
}

bool CalculatorEngine::isOperator(const QChar &c) {
    return c == '+' || c == '-' || c == '*' || c == '/';
}

QString CalculatorEngine::bigFloatToString(const BigFloat &val) {
    std::stringstream ss;
    ss.imbue(std::locale::classic());
    ss << std::setprecision(50) << val;
    std::string s = ss.str();

    QString res = QString::fromStdString(s);

    if (res.contains('.')) {
        res = res.remove(QRegularExpression("0+$"));
        res = res.remove(QRegularExpression("\\.$"));
    }

    if (res.isEmpty() || res == "-") return "0";
    return res;
}

// ---------------------------------------------------------------------------
// Реализация алгоритма сортировочной станции (Shunting-yard)
// ---------------------------------------------------------------------------

QVector<CalculatorEngine::Token> CalculatorEngine::tokenize(const QString &expr) {
    QVector<Token> tokens;
    int i = 0;
    int len = expr.length();

    while (i < len) {
        QChar ch = expr[i];

        if (ch.isSpace()) {
            i++;
            continue;
        }

        // Парсинг чисел
        if (ch.isDigit() || ch == '.') {
            int start = i;
            bool hasDot = (ch == '.');
            i++;
            while (i < len && (expr[i].isDigit() || (expr[i] == '.' && !hasDot))) {
                if (expr[i] == '.') hasDot = true;
                i++;
            }
            tokens.append(Token(TokenType::Number, expr.mid(start, i - start)));
            continue;
        }

        if (ch == '(') {
            tokens.append(Token(TokenType::LParen, "("));
            i++;
            continue;
        }
        if (ch == ')') {
            tokens.append(Token(TokenType::RParen, ")"));
            i++;
            continue;
        }

        //  Парсинг операторов
        if (ch == '+' || ch == '*' || ch == '/' || ch == '-' || ch == 0x2212) {
            QChar op = (ch == 0x2212) ? '-' : ch;

            // Определение унарного минуса
            bool isUnary = false;
            if (op == '-') {
                if (tokens.isEmpty()) {
                    isUnary = true;
                } else {
                    TokenType lastType = tokens.last().type;
                    if (lastType == TokenType::Operator || lastType == TokenType::LParen) {
                        isUnary = true;
                    }
                }
            }

            if (isUnary) {
                tokens.append(Token(TokenType::Operator, "~", 3, false));
            } else {
                tokens.append(Token(TokenType::Operator, QString(op), getPrecedence(op)));
            }
            i++;
            continue;
        }

        throw std::runtime_error(std::string("Unexpected character: ") + ch.toLatin1());
    }

    return tokens;
}

QVector<CalculatorEngine::Token> CalculatorEngine::toRPN(const QVector<Token> &tokens) {
    QVector<Token> output;
    QStack<Token> opStack;

    for (const auto &token : tokens) {
        if (token.type == TokenType::Number) {
            output.append(token);
        } else if (token.type == TokenType::Operator) {
            while (!opStack.isEmpty()) {
                Token top = opStack.top();
                if (top.type == TokenType::Operator) {
                    if ((token.isLeftAssociative && token.precedence <= top.precedence) ||
                        (!token.isLeftAssociative && token.precedence < top.precedence)) {
                        output.append(opStack.pop());
                        continue;
                    }
                }
                break;
            }
            opStack.push(token);
        } else if (token.type == TokenType::LParen) {
            opStack.push(token);
        } else if (token.type == TokenType::RParen) {
            bool foundLeft = false;
            while (!opStack.isEmpty()) {
                Token top = opStack.pop();
                if (top.type == TokenType::LParen) {
                    foundLeft = true;
                    break;
                }
                output.append(top);
            }
            if (!foundLeft) {
                throw std::runtime_error("Mismatched parentheses: missing '('");
            }
        }
    }

    while (!opStack.isEmpty()) {
        Token top = opStack.pop();
        if (top.type == TokenType::LParen || top.type == TokenType::RParen) {
            throw std::runtime_error("Mismatched parentheses");
        }
        output.append(top);
    }

    return output;
}

BigFloat CalculatorEngine::evaluateRPN(const QVector<Token> &rpn) {
    QStack<BigFloat> stack;

    for (const auto &token : rpn) {
        if (token.type == TokenType::Number) {
            QString numStr = token.value;
            numStr.replace(',', '.');

            std::istringstream iss(numStr.toStdString());
            iss.imbue(std::locale::classic());
            BigFloat val;
            iss >> val;
            if (iss.fail()) throw std::runtime_error("Invalid number format");

            stack.push(val);
        } else if (token.type == TokenType::Operator) {
            QChar op = token.value[0];

            // Проверка на унарный оператор
            if (op == '~') {
                if (stack.size() < 1) {
                    throw std::runtime_error("Invalid expression: unary operator missing operand");
                }
                BigFloat a = stack.pop();
                stack.push(-a);
            }
            // Бинарные операторы
            else {
                if (stack.size() < 2) {
                    throw std::runtime_error("Invalid expression: not enough operands");
                }
                BigFloat b = stack.pop();
                BigFloat a = stack.pop();
                BigFloat res;

                if (op == '+') res = a + b;
                else if (op == '-') res = a - b;
                else if (op == '*') res = a * b;
                else if (op == '/') {
                    if (b == 0) throw std::runtime_error("Division by zero");
                    res = a / b;
                }
                stack.push(res);
            }
        }
    }

    if (stack.size() != 1) {
        throw std::runtime_error("Invalid expression structure");
    }

    return stack.top();
}

// Public слоты

void CalculatorEngine::inputDigit(const QString &digit) {
    if (m_waitingForCode) {
        processCodeInput(digit);
        return;
    }

    if (m_lastWasResult) {
        m_expression = "";
        m_lastWasResult = false;
    }

    if (digit == "0" && m_expression.isEmpty() && m_display == "0") {
        return;
    }

    m_expression += digit;
    emit expressionChanged();
}

void CalculatorEngine::inputDot() {
    if (m_waitingForCode) return;
    if (m_lastWasResult) {
        m_expression = "";
        m_lastWasResult = false;
    }

    int len = m_expression.length();
    if (len == 0) {
        m_expression = "0.";
    } else {
        QChar last = m_expression.back();
        if (!last.isDigit() && last != '.') {
            m_expression += "0.";
        } else {
            int i = len - 1;
            while (i >= 0 && (m_expression[i].isDigit() || m_expression[i] == '.')) {
                if (m_expression[i] == '.') return;
                i--;
            }
            m_expression += ".";
        }
    }
    emit expressionChanged();
}

void CalculatorEngine::inputOperator(const QString &op) {
    if (m_waitingForCode) return;
    if (op.isEmpty()) return;

    QChar opChar = op.at(0);
    if (opChar.unicode() == 0x2212) opChar = '-';

    // Продолжение вычислений с использованием результата как первое число
    if (m_lastWasResult) {
        m_expression = m_display;
        m_lastWasResult = false;
    }

    if (m_expression.isEmpty()) {
        if (opChar == '-') {
            m_expression = "-";
            emit expressionChanged();
        }
        return;
    }

    QChar lastChar = m_expression.back();

    if (isOperator(lastChar)) {
        if (m_expression.length() == 1 && lastChar == '-') {
            m_expression.chop(1);
        } else {
            m_expression.chop(1);
        }
    }

    m_expression += opChar;
    emit expressionChanged();
}

void CalculatorEngine::inputParentheses() {
    if (m_waitingForCode) return;
    if (m_lastWasResult) {
        m_expression = "";
        m_lastWasResult = false;
    }

    int openCount = m_expression.count('(');
    int closeCount = m_expression.count(')');

    if (m_expression.isEmpty()) {
        m_expression += "(";
    } else {
        QChar lastChar = m_expression.back();
        bool isEndOfOperand = lastChar.isDigit() || lastChar == '.' || lastChar == ')';

        if (isEndOfOperand) {
            if (openCount > closeCount) {
                m_expression += ")";
            } else {
                m_expression += "*(";
            }
        } else {
            m_expression += "(";
        }
    }
    emit expressionChanged();
}

void CalculatorEngine::toggleSign() {
    if (m_expression.isEmpty() || m_waitingForCode) return;

    int i = m_expression.length() - 1;
    while (i >= 0 && (m_expression[i].isDigit() || m_expression[i] == '.')) {
        i--;
    }
    int numStart = i + 1;
    if (numStart >= m_expression.length()) return;

    bool hasSign = false;
    int signIndex = -1;

    if (i >= 0) {
        QChar c = m_expression[i];
        if (c == '-') {
            bool isUnary = (i == 0) || isOperator(m_expression[i-1]) || m_expression[i-1] == '(';
            if (isUnary) {
                hasSign = true;
                signIndex = i;
            }
        }
    }

    if (hasSign) {
        m_expression.remove(signIndex, 1);
    } else {
        m_expression.insert(numStart, '-');
    }
    emit expressionChanged();
}

void CalculatorEngine::inputPercent() {
    if (m_expression.isEmpty() || m_waitingForCode) return;

    int i = m_expression.length() - 1;
    while (i >= 0 && (m_expression[i].isDigit() || m_expression[i] == '.')) i--;
    int start = i + 1;
    if (start >= m_expression.length()) return;

    QString numStr = m_expression.mid(start);
    try {
        std::istringstream iss(numStr.replace(',', '.').toStdString());
        iss.imbue(std::locale::classic());
        BigFloat val;
        iss >> val;
        val /= 100;
        QString newNum = bigFloatToString(val);
        m_expression.replace(start, numStr.length(), newNum);
        emit expressionChanged();
    } catch (...) {
        qWarning() << "Percent error";
    }
}

void CalculatorEngine::clear() {
    m_expression = "";
    m_display = "0";
    m_lastWasResult = false;
    emit expressionChanged();
    emit displayChanged();
}

void CalculatorEngine::calculate() {
    if (m_expression.isEmpty() || m_waitingForCode) return;

    QString expr = m_expression;
    int open = expr.count('(');
    int close = expr.count(')');
    while(open > close) { expr += ")"; close++; }

    try {
        QVector<Token> tokens = tokenize(expr);
        if (tokens.isEmpty()) return;

        QVector<Token> rpn = toRPN(tokens);
        BigFloat result = evaluateRPN(rpn);
        QString resStr = bigFloatToString(result);

        m_display = resStr;
        m_lastWasResult = true;

        emit displayChanged();
    } catch (const std::exception& e) {
        qDebug() << "Calc Error:" << e.what();
        m_display = "Ошибка";
        m_lastWasResult = false;
        emit displayChanged();
        emit expressionChanged();
    }
}

void CalculatorEngine::startSecretCodeSequence() {
    m_waitingForCode = true;
    m_codeBuffer = "";
    m_codeTimer.start(5000);
    emit secretMenuReadyChanged();
}
void CalculatorEngine::resetSecretCodeSequence() {
    if (!m_waitingForCode) return;
    m_waitingForCode = false;
    m_codeBuffer = "";
    m_codeTimer.stop();
    emit secretMenuReadyChanged();
}
void CalculatorEngine::processCodeInput(const QString &digit) {
    if (!m_waitingForCode) return;
    m_codeBuffer += digit;
    if (m_codeBuffer == "123") {
        resetSecretCodeSequence();
        emit openSecretMenu();
    } else if (!QString("123").startsWith(m_codeBuffer)) {
        resetSecretCodeSequence();
    }
}
void CalculatorEngine::onEqualsLongPressed() { startSecretCodeSequence(); }

bool CalculatorEngine::handleKeyEvent(QKeyEvent *event) {
    if (event->type() == QEvent::KeyPress) {
        if (m_waitingForCode) {
            QString text = event->text();
            if (!text.isEmpty()) {
                QChar ch = text.at(0);
                if (ch == '1' || ch == '2' || ch == '3') {
                    processCodeInput(text);
                    return true;
                }
                if (ch.isDigit()) { resetSecretCodeSequence(); return true; }
            }
        }

        Qt::Key key = static_cast<Qt::Key>(event->key());
        if (key >= Qt::Key_0 && key <= Qt::Key_9) { inputDigit(event->text()); return true; }
        if (key == Qt::Key_Period || key == Qt::Key_Comma) { inputDot(); return true; }
        if (key == Qt::Key_Plus) { inputOperator("+"); return true; }
        if (key == Qt::Key_Minus) { inputOperator("-"); return true; }
        if (key == Qt::Key_Asterisk) { inputOperator("*"); return true; }
        if (key == Qt::Key_Slash) { inputOperator("/"); return true; }
        if (key == Qt::Key_ParenLeft || key == Qt::Key_ParenRight) { inputParentheses(); return true; }
        if (key == Qt::Key_Return || key == Qt::Key_Enter || key == Qt::Key_Equal) { calculate(); return true; }
        if (key == Qt::Key_Backspace) {
            if (m_lastWasResult) m_lastWasResult = false;
            if (!m_expression.isEmpty()) {
                m_expression.chop(1);
                if (m_expression.isEmpty()) m_display = "0";
                emit expressionChanged();
                emit displayChanged();
            }
            return true;
        }
        if (key == Qt::Key_Escape) { clear(); return true; }
        if (key == Qt::Key_Percent) { inputPercent(); return true; }
    }
    return false;
}

bool CalculatorEngine::eventFilter(QObject *obj, QEvent *event) {
    if (event->type() == QEvent::KeyPress) {
        if (handleKeyEvent(static_cast<QKeyEvent*>(event))) return true;
    }
    return QObject::eventFilter(obj, event);
}
