import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

/// one screen showing the calculator UI.
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

// CalculatorUI is Stateful only because later I'll change the display
// when buttons are pressed. For now, it’s UI-only.
class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  /// Display text shown at the top of the calculator.
  String displayText = "0";

  // --- Colors to match the look in your screenshot ---
  final Color _appBg = const Color(0xFFEFEFEF); // light page background
  final Color _panelBg = const Color(0xFF101319); // dark calculator body
  final Color _displayBg = const Color(0xFF1A1F28); // darker display pill
  final Color _numBtn = const Color(0xFF2A2F3A); // number button gray
  final Color _opBtn = Colors.orange; // orange operator buttons
  final Color _textLight = const Color(0xFFEDEDED); // white-ish text
  final Color _displayGreen = const Color(0xFF7CFF6B); // green display text

  // ==========================
  // CALC STATE
  // ==========================
  double? _firstValue; // first operand
  String? _operator; // "+", "-", "×", "÷"
  bool _startNewNumber = false; // if true, next digit replaces display

  // ==========================
  // INPUT HANDLERS
  // ==========================

  void _tapDigit(String digit) {
    setState(() {
      // If we just pressed an operator or equals, start a new number
      if (_startNewNumber) {
        displayText = digit;
        _startNewNumber = false;
        return;
      }

      // Normal typing behavior
      if (displayText == "0") {
        displayText = digit;
      } else {
        displayText += digit;
      }
    });
  }

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

  void _clear() {
    setState(() {
      displayText = "0";
      _firstValue = null;
      _operator = null;
      _startNewNumber = false;
    });
  }

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

  void _percent() {
    setState(() {
      final value = double.tryParse(displayText);
      if (value == null) return;
      final result = value / 100.0;
      displayText = _formatNumber(result);
    });
  }

  // OPERATOR + EQUALS LOGIC

  /// User tapped +, −, ×, ÷
  void _tapOperator(String op) {
    setState(() {
      final current = double.tryParse(displayText);
      if (current == null) {
        // if display is "Error" etc, do nothing
        return;
      }

      // If we already have a pending operation and user presses another operator,
      // compute intermediate result first (supports chaining like 2 + 3 + 4).
      if (_firstValue != null && _operator != null && !_startNewNumber) {
        final computed = _compute(_firstValue!, _operator!, current);
        if (computed == null) return; // error handled inside _compute
        _firstValue = computed;
        displayText = _formatNumber(computed);
      } else {
        _firstValue = current;
      }

      _operator = op;
      _startNewNumber = true; // next digit starts fresh
    });
  }

  /// User tapped =
  void _equals() {
    setState(() {
      if (_firstValue == null || _operator == null) return;

      final second = double.tryParse(displayText);
      if (second == null) return;

      final computed = _compute(_firstValue!, _operator!, second);
      if (computed == null) return; // error handled inside _compute

      displayText = _formatNumber(computed);

      // Reset operation state so user can continue from result
      _firstValue = null;
      _operator = null;
      _startNewNumber = true;
    });
  }

  // Performs math. Returns null if error (like divide by zero).
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

  /// Formats doubles nicely:
  ///  5.0 -> "5"
  ///  2.5000 -> "2.5"
  String _formatNumber(double value) {
    String s = value.toString();
    if (s.contains(".")) {
      // trim trailing zeros
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s.isEmpty ? "0" : s;
  }

  // REUSABLE BUTTON BUILDER

  Widget _calcButton({
    required String label,
    required Color background,
    required Color foreground,
    VoidCallback? onPressed,
    int flex = 1, // makes "0" wider when flex=2
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              elevation: 0, // flat modern look like the screenshot
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  /// Helper to build each row (4-column rows, except last row).
  Widget _row(List<Widget> children) {
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,

      // Center the calculator "device" on the page like the picture
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _panelBg, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ======================
              // DISPLAY AREA (Top)
              // ======================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(color: _displayBg, borderRadius: BorderRadius.circular(22)),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _displayGreen, letterSpacing: 1.0),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Row 1
              _row([
                _calcButton(label: "C", background: _opBtn, foreground: _textLight, onPressed: _clear),
                _calcButton(label: "±", background: _opBtn, foreground: _textLight, onPressed: _toggleSign),
                _calcButton(label: "%", background: _opBtn, foreground: _textLight, onPressed: _percent),
                _calcButton(label: "÷", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("÷")),
              ]),

              // Row 2
              _row([
                _calcButton(label: "7", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("7")),
                _calcButton(label: "8", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("8")),
                _calcButton(label: "9", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("9")),
                _calcButton(label: "×", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("×")),
              ]),

              // Row 3
              _row([
                _calcButton(label: "4", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("4")),
                _calcButton(label: "5", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("5")),
                _calcButton(label: "6", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("6")),
                _calcButton(label: "−", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("−")),
              ]),

              // Row 4
              _row([
                _calcButton(label: "1", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("1")),
                _calcButton(label: "2", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("2")),
                _calcButton(label: "3", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("3")),
                _calcButton(label: "+", background: _opBtn, foreground: _textLight, onPressed: () => _tapOperator("+")),
              ]),

              // Row 5 (0 is wide)
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