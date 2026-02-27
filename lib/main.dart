import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

// Main app wrapper.
// - MaterialApp provides theming, navigation, and app-level config.
// - CalculatorUI is our single screen.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator UI',
      home: const CalculatorUI(),
    );
  }
}

// CalculatorUI is Stateful because the display and stored operands/operators
// change as the user taps buttons.
class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  // Text shown in the display area at the top.
  // It should be kept as a String because the user builds the number character-by-character.
  String displayText = "0";

  // UI COLORS (theme-like constants)
  final Color _appBg = const Color(0xFFEFEFEF); // background behind calculator panel
  final Color _panelBg = const Color(0xFF101319); // calculator body
  final Color _displayBg = const Color(0xFF1A1F28); // display background pill
  final Color _numBtn = const Color(0xFF2A2F3A); // number buttons
  final Color _opBtn = Colors.orange; // operator buttons
  final Color _textLight = const Color(0xFFEDEDED); // light text color on dark buttons
  final Color _displayGreen = const Color(0xFF7CFF6B); // display text color

  // CALCULATOR STATE
  double? _firstValue; // first operand (ex: after user presses +)
  String? _operator; // pending operator: "+", "−", "×", "÷"
  bool _startNewNumber = false; // true => next digit replaces display (after operator or =)

  // INPUT HANDLERS (digits + special input)

  // User tapped a digit (0-9).
  // Rules:
  // 1) If user is starting a new number, replace the display with the digit.
  // 2) Otherwise, append the digit to the current display text.
  // 3) Replace leading "0" to avoid numbers like "0007".
  void _tapDigit(String digit) {
    setState(() {
      // After pressing an operator or equals, the next digit should start fresh
      if (_startNewNumber) {
        displayText = digit;
        _startNewNumber = false;
        return;
      }

      // Normal typing behavior (append)
      if (displayText == "0") {
        displayText = digit;
      } else {
        displayText += digit;
      }
    });
  }

  // User tapped the decimal point.
  // Rules:
  // - If user is starting a new number, begin with "0."
  // - No more than one decimal in the same number.
  void _tapDecimal() {
    setState(() {
      if (_startNewNumber) {
        displayText = "0.";
        _startNewNumber = false;
        return;
      }

      if (!displayText.contains(".")) {
        displayText += ".";
      }
    });
  }

  // Clear/All-clear:
  // - resets display
  // - clears stored operand and operator
  // - returns calculator to initial state
  void _clear() {
    setState(() {
      displayText = "0";
      _firstValue = null;
      _operator = null;
      _startNewNumber = false;
    });
  }

  // Toggle sign:
  // - "45"  -> "-45"
  // - "-45" -> "45"
  // Edge case: if display is "0", do nothing.
  void _toggleSign() {
    setState(() {
      if (displayText == "0") return;

      if (displayText.startsWith("-")) {
        displayText = displayText.substring(1);
        if (displayText.isEmpty) displayText = "0";
      } else {
        displayText = "-$displayText";
      }
    });
  }

  // Percent:
  // Converts current number to a percent by dividing by 100.
  // Example: "50" -> "0.5"
  void _percent() {
    setState(() {
      final value = double.tryParse(displayText);
      if (value == null) return; // if display is "Error" or invalid
      final result = value / 100.0;
      displayText = _formatNumber(result);
    });
  }

  // OPERATOR + EQUALS LOGIC

  // User tapped an operator (+, −, ×, ÷).
  // Behavior:
  // - Store the current display as the first operand.
  // - Store the operator.
  // - Set _startNewNumber so the next digit begins the second operand.
  // Also supports chaining:
  //   2 + 3 + 4
  // When user hits the second operator, intermediate result is computed first.
  void _tapOperator(String op) {
    setState(() {
      final current = double.tryParse(displayText);
      if (current == null) {
        // If display is "Error" or invalid text, ignore operator press
        return;
      }

      // If there is already a pending operation and the user is NOT just starting a new number,
      // compute intermediate result (supports chaining like 2 + 3 + 4).
      if (_firstValue != null && _operator != null && !_startNewNumber) {
        final computed = _compute(_firstValue!, _operator!, current);
        if (computed == null) return; // error handled inside _compute

        // Save intermediate result as the new first value
        _firstValue = computed;

        // Show intermediate result in the display
        displayText = _formatNumber(computed);
      } else {
        // Normal case: store current number as first operand
        _firstValue = current;
      }

      // Store operator and prepare for next number input
      _operator = op;
      _startNewNumber = true;
    });
  }

  // User tapped "=".
  // Requirements:
  // - Must have a stored first value and operator
  // - Current display becomes the second operand
  // - Compute result and show it in displayText
  // - Reset stored operator/first value so user can continue from result
  void _equals() {
    setState(() {
      // If user presses "=" without a complete expression, do nothing safely
      if (_firstValue == null || _operator == null) return;

      final second = double.tryParse(displayText);
      if (second == null) return;

      final computed = _compute(_firstValue!, _operator!, second);
      if (computed == null) return; // error handled inside _compute

      // Show final result
      displayText = _formatNumber(computed);

      // Reset stored operation so user can start a new operation from the result
      _firstValue = null;
      _operator = null;
      _startNewNumber = true; // next digit replaces result
    });
  }

  // Perform the math operation.
  // Returns null when an error occurs (ex: divide by zero).
  double? _compute(double a, String op, double b) {
    double result;

    switch (op) {
      case "+":
        result = a + b;
        break;

      case "−":
        result = a - b;
        break;

      case "×":
        result = a * b;
        break;

      case "÷":
        // Division by zero protection:
        // show "Error", reset state, and stop.
        if (b == 0) {
          displayText = "Error";
          _firstValue = null;
          _operator = null;
          _startNewNumber = true;
          return null;
        }
        result = a / b;
        break;

      default:
        return null;
    }

    return result;
  }

  // Formats doubles for cleaner display:
  // - 5.0 -> "5"
  // - 2.5000 -> "2.5"
  // - Prevents weird trailing zeros in the display.
  String _formatNumber(double value) {
    String s = value.toString();

    if (s.contains(".")) {
      // Remove trailing zeros and an optional trailing decimal point
      // Example: "10.000" -> "10", "2.5000" -> "2.5"
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    return s.isEmpty ? "0" : s;
  }

  // REUSABLE BUTTON BUILDER

  // Builds a calculator button with consistent style.
  // I use Expanded so every row's buttons share the available space.
  Widget _calcButton({
    required String label,
    required Color background,
    required Color foreground,
    VoidCallback? onPressed,
    int flex = 1, // flex=2 makes the "0" button twice as wide
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            // If no callback is supplied, it does nothing (safe default)
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  // helper to build one row of buttons.
  Widget _row(List<Widget> children) {
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,

      // Center the calculator "device" on the page
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _panelBg, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // DISPLAY AREA (Top)

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(color: _displayBg, borderRadius: BorderRadius.circular(22)),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    displayText,
                    // Prevent layout overflow for long results (ex: many digits)
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _displayGreen, letterSpacing: 1.0),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // BUTTON GRID

              // Row 1: Clear, sign, percent, divide
              _row([
                _calcButton(label: "C", background: _opBtn, foreground: _textLight, onPressed: _clear),
                _calcButton(label: "±", background: _opBtn, foreground: _textLight, onPressed: _toggleSign),
                _calcButton(label: "%", background: _opBtn, foreground: _textLight, onPressed: _percent),
                _calcButton(label: "÷", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("÷")),
              ]),

              // Row 2: 7 8 9 multiply
              _row([
                _calcButton(label: "7", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("7")),
                _calcButton(label: "8", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("8")),
                _calcButton(label: "9", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("9")),
                _calcButton(label: "×", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("×")),
              ]),

              // Row 3: 4 5 6 subtract
              _row([
                _calcButton(label: "4", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("4")),
                _calcButton(label: "5", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("5")),
                _calcButton(label: "6", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("6")),
                _calcButton(label: "−", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("−")),
              ]),

              // Row 4: 1 2 3 add
              _row([
                _calcButton(label: "1", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("1")),
                _calcButton(label: "2", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("2")),
                _calcButton(label: "3", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("3")),
                _calcButton(label: "+", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("+")),
              ]),

              // Row 5: wide 0, decimal, equals
              _row([
                _calcButton(label: "0", background: _numBtn, foreground: _textLight, flex: 2, onPressed: () => _tapDigit("0")),
                _calcButton(label: ".", background: _numBtn, foreground: _textLight, onPressed: _tapDecimal),
                _calcButton(label: "=", background: _opBtn, foreground: _textLight, onPressed: _equals),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}