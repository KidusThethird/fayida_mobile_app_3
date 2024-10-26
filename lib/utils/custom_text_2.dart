import 'package:flutter/material.dart';

class FilteredText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  FilteredText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    String processedText = _replaceSpecialCharacters(text);

    // Updated regular expression to include italic (*), superscript (^), and subscript (***)
    RegExp regExp =
        RegExp(r'(_.*?_|\*\*\*.*?\*\*\*|\*\*.*?\*\*|\*.*?\*|\^.*?\^)');
    List<InlineSpan> spans = [];

    int start = 0;

    // Process each match to apply the appropriate style
    regExp.allMatches(processedText).forEach((match) {
      if (start < match.start) {
        // Add any text before the match as normal text
        spans.add(TextSpan(
            text: processedText.substring(start, match.start), style: style));
      }

      String matchText = match.group(0)!;
      TextStyle? matchStyle;

      // Check for triple asterisks for subscript before double asterisks for bold
      if (matchText.startsWith('***') && matchText.endsWith('***')) {
        // Subscript text
        matchStyle = style?.copyWith(
            fontSize: (style?.fontSize ?? 14) *
                0.6); // Further reduced font size for subscript
        matchText = matchText.substring(
            3, matchText.length - 3); // Remove triple asterisks

        // Wrap subscript text in a WidgetSpan with Transform to adjust position
        spans.add(
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(
                  0, 6), // Increase downward offset for subscript position
              child: Text(
                matchText,
                style: matchStyle,
              ),
            ),
          ),
        );
      } else if (matchText.startsWith('**') && matchText.endsWith('**')) {
        // Bold text
        matchStyle = style?.copyWith(fontWeight: FontWeight.bold);
        matchText = matchText.substring(
            2, matchText.length - 2); // Remove double asterisks
        spans.add(TextSpan(text: matchText, style: matchStyle));
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        // Italic text
        matchStyle = style?.copyWith(fontStyle: FontStyle.italic);
        matchText = matchText.substring(
            1, matchText.length - 1); // Remove single asterisks
        spans.add(TextSpan(text: matchText, style: matchStyle));
      } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
        // Underlined text
        matchStyle = style?.copyWith(decoration: TextDecoration.underline);
        matchText =
            matchText.substring(1, matchText.length - 1); // Remove underscores
        spans.add(TextSpan(text: matchText, style: matchStyle));
      } else if (matchText.startsWith('^') && matchText.endsWith('^')) {
        // Superscript text
        matchStyle = style?.copyWith(
            fontSize: (style?.fontSize ?? 14) *
                0.8); // Reduced font size for superscript
        matchText =
            matchText.substring(1, matchText.length - 1); // Remove carets

        // Wrap superscript text in a WidgetSpan with Transform to adjust position
        spans.add(
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(
                  0, -6), // Adjust vertical offset for superscript position
              child: Text(
                matchText,
                style: matchStyle,
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: matchText, style: style));
      }
      start = match.end;
    });

    // Add remaining text after the last match
    if (start < processedText.length) {
      spans.add(TextSpan(text: processedText.substring(start), style: style));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: style,
      ),
    );
  }

  String _replaceSpecialCharacters(String input) {
    // Handle long dash replacement first
    input = input.replaceAll(
        '&&dashl', '————————————————'); // Long dash (multiple dashes)

    // Then handle single dash replacement
    input = input.replaceAll('&&dash', '—————'); // Single dash (em dash)

    return input
        .replaceAll('&&8', '∞') // Infinity
        .replaceAll('&&f', 'ƒ') // Function f
        .replaceAll('&&arf', '→') // Right arrow
        .replaceAll('&&arb', '←') // Left arrow
        .replaceAll('&&aru', '↑') // Up arrow
        .replaceAll('&&ard', '↓') // Down arrow
        .replaceAll('&&pi', 'π') // Pi
        .replaceAll('&&sqrt', '√') // Square root
        .replaceAll('&&noteq', '≠') // Not equal
        .replaceAll('&&empty', '∅') // Empty set
        .replaceAll('&&integ', '∫') // Integral
        .replaceAll('&&triangle', '△') // Triangle
        .replaceAll('&&imp', '⇒') // Implication
        .replaceAll('&&bimp', '⇔') // Bi-implication
        .replaceAll('&&invv', '∧') // Logical and
        .replaceAll('&&alpha', 'α') // Alpha
        .replaceAll('&&beta', 'β') // Beta
        .replaceAll('&&theta', 'θ') // Theta
        .replaceAll('&&gamma', 'γ') // Gamma
        .replaceAll('&&lambda', 'λ') // Lambda
        .replaceAll('&&mu', 'μ') // Mu
        .replaceAll('&&nu', 'ν') // Nu
        .replaceAll('&&rho', 'ρ') // Rho
        .replaceAll('&&tau', 'τ') // Tau
        .replaceAll('&&phi', 'φ') // Phi
        .replaceAll('&&psi', 'ψ') // Psi
        .replaceAll('&&omega', 'ω') // Omega
        .replaceAll('&&eta', 'η') // Eta
        .replaceAll('&&dotdotdot', '⋮') // Dots
        .replaceAll('&&greaterequal', '≥') // Greater than or equal to
        .replaceAll('&&lessequal', '≤') // Less than or equal to
        .replaceAll('&&plusminus', '±') // Plus-minus
        .replaceAll('&&nl', '\n') // New line
        .replaceAll('&&r', 'ℝ') // Real numbers (styled)
        .replaceAll('&&nat', 'ℕ'); // Natural numbers (styled)
  }
}
