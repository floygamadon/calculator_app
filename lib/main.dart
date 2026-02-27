import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

/// Root app widget.
/// Keeps it simple: one screen showing the calculator UI.
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

/// CalculatorUI is Stateful only because later you’ll change the display
/// when buttons are pressed. For now, it’s UI-only.
class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  /// Display text shown at the top of the calculator.
  /// (Static for now—UI only.)
  String displayText = "123";

  // --- Colors to match the look in your screenshot ---
  final Color _appBg = const Color(0xFFEFEFEF); // light page background
  final Color _panelBg = const Color(0xFF101319); // dark calculator body
  final Color _displayBg = const Color(0xFF1A1F28); // darker display pill
  final Color _numBtn = const Color(0xFF2A2F3A); // number button gray
  final Color _opBtn = Colors.orange; // orange operator buttons
  final Color _textLight = const Color(0xFFEDEDED); // white-ish text
  final Color _displayGreen = const Color(0xFF7CFF6B); // green display text

  /// Reusable button widget builder for consistent styling.
  ///
  /// 
  /// - Expanded to auto-fill each "cell" in the row
  /// - fixed height for a uniform grid
  /// - rounded corners similar to the screenshot
  /// - spacing via Padding
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
            // UI only: allow passing a callback later; for now, do nothing
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
              elevation: 0, // flat modern look like the screenshot
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to build each row (4-column rows, except last row).
  ///
  /// Using a method keeps the build() clean and readable.
  Widget _row(List<Widget> children) {
    return Row(
      children: children,
    );
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
          decoration: BoxDecoration(
            color: _panelBg,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ======================
              // DISPLAY AREA (Top)
              // ======================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(
                  color: _displayBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    displayText,
                    // Big, right-aligned, green-ish text like the screenshot
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: _displayGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Row 1
              _row([
                _calcButton(label: "C", background: _opBtn, foreground: _textLight),
                _calcButton(label: "±", background: _opBtn, foreground: _textLight),
                _calcButton(label: "%", background: _opBtn, foreground: _textLight),
                _calcButton(label: "÷", background: _opBtn, foreground: _textLight),
              ]),

              // Row 2
              _row([
                _calcButton(label: "7", background: _numBtn, foreground: _textLight),
                _calcButton(label: "8", background: _numBtn, foreground: _textLight),
                _calcButton(label: "9", background: _numBtn, foreground: _textLight),
                _calcButton(label: "×", background: _opBtn, foreground: _textLight),
              ]),

              // Row 3
              _row([
                _calcButton(label: "4", background: _numBtn, foreground: _textLight),
                _calcButton(label: "5", background: _numBtn, foreground: _textLight),
                _calcButton(label: "6", background: _numBtn, foreground: _textLight),
                _calcButton(label: "−", background: _opBtn, foreground: _textLight),
              ]),

              // Row 4
              _row([
                _calcButton(label: "1", background: _numBtn, foreground: _textLight),
                _calcButton(label: "2", background: _numBtn, foreground: _textLight),
                _calcButton(label: "3", background: _numBtn, foreground: _textLight),
                _calcButton(label: "+", background: _opBtn, foreground: _textLight),
              ]),

              // Row 5 (0 is wide)
              _row([
                _calcButton(
                  label: "0",
                  background: _numBtn,
                  foreground: _textLight,
                  flex: 2, // makes the 0 button double-width (like the screenshot)
                ),
                _calcButton(label: ".", background: _numBtn, foreground: _textLight),
                _calcButton(label: "=", background: _opBtn, foreground: _textLight),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}