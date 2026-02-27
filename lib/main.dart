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

/// CalculatorUI is Stateful because display changes when buttons are pressed.
class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  /// Display text shown at the top of the calculator.
  String displayText = "0";

  // --- Colors ---
  final Color _appBg = const Color(0xFFEFEFEF);
  final Color _panelBg = const Color(0xFF101319);
  final Color _displayBg = const Color(0xFF1A1F28);
  final Color _numBtn = const Color(0xFF2A2F3A);
  final Color _opBtn = Colors.orange;
  final Color _textLight = const Color(0xFFEDEDED);
  final Color _displayGreen = const Color(0xFF7CFF6B);

  // ==========================
  // INPUT HANDLERS
  // ==========================

  void _tapDigit(String digit) {
    setState(() {
      if (displayText == "0") {
        displayText = digit;
      } else {
        displayText += digit;
      }
    });
  }

  void _tapDecimal() {
    setState(() {
      if (!displayText.contains(".")) {
        displayText += ".";
      }
    });
  }

  void _clear() {
    setState(() {
      displayText = "0";
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
      final s = result.toString();
      displayText = s.endsWith(".0") ? s.substring(0, s.length - 2) : s;
    });
  }

  // ==========================
  // BUTTON BUILDER
  // ==========================

  Widget _calcButton({
    required String label,
    required Color background,
    required Color foreground,
    VoidCallback? onPressed,
    int flex = 1,
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _panelBg, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(color: _displayBg, borderRadius: BorderRadius.circular(22)),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(displayText, style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _displayGreen, letterSpacing: 1.0)),
                ),
              ),

              const SizedBox(height: 16),

              // Row 1
              _row([
                _calcButton(label: "C", background: _opBtn, foreground: _textLight, onPressed: _clear),
                _calcButton(label: "±", background: _opBtn, foreground: _textLight, onPressed: _toggleSign),
                _calcButton(label: "%", background: _opBtn, foreground: _textLight, onPressed: _percent),
                _calcButton(label: "÷", background: _opBtn, foreground: _textLight),
              ]),

              // Row 2
              _row([
                _calcButton(label: "7", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("7")),
                _calcButton(label: "8", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("8")),
                _calcButton(label: "9", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("9")),
                _calcButton(label: "×", background: _opBtn, foreground: _textLight),
              ]),

              // Row 3
              _row([
                _calcButton(label: "4", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("4")),
                _calcButton(label: "5", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("5")),
                _calcButton(label: "6", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("6")),
                _calcButton(label: "−", background: _opBtn, foreground: _textLight),
              ]),

              // Row 4
              _row([
                _calcButton(label: "1", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("1")),
                _calcButton(label: "2", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("2")),
                _calcButton(label: "3", background: _numBtn, foreground: _textLight, onPressed: () => _tapDigit("3")),
                _calcButton(label: "+", background: _opBtn, foreground: _textLight),
              ]),

              // Row 5
              _row([
                _calcButton(label: "0", background: _numBtn, foreground: _textLight, flex: 2, onPressed: () => _tapDigit("0")),
                _calcButton(label: ".", background: _numBtn, foreground: _textLight, onPressed: _tapDecimal),
                _calcButton(label: "=", background: _opBtn, foreground: _textLight),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}