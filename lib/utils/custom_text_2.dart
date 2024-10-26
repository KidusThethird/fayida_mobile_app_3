import 'package:flutter/material.dart';

class FilteredText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  FilteredText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    // Updated regular expression to include italic (*), superscript (^), and subscript (***)
    RegExp regExp =
        RegExp(r'(_.*?_|\*\*\*.*?\*\*\*|\*\*.*?\*\*|\*.*?\*|\^.*?\^)');
    List<InlineSpan> spans = [];

    int start = 0;

    // Process each match to apply the appropriate style
    regExp.allMatches(text).forEach((match) {
      if (start < match.start) {
        // Add any text before the match as normal text
        spans.add(
            TextSpan(text: text.substring(start, match.start), style: style));
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
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: style,
      ),
    );
  }
}
