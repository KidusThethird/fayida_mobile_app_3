// lib/custom_text_widget.dart

import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle; // New parameter to accept additional styles

  CustomTextWidget({required this.text, this.baseStyle});

  // Function to filter and style the text
  List<TextSpan> filterText(String inputText) {
    final List<TextSpan> spans = [];

    // Define regex patterns for different formats
    final RegExp superscriptRegExp = RegExp(r'\^(.*?)\^'); // Matches ^text^
    final RegExp subscriptRegExp =
        RegExp(r'\*\*\*(.*?)\*\*\*'); // Matches ***text***
    final RegExp boldRegExp = RegExp(r'\*\*(.*?)\*\*'); // Matches **bold**
    final RegExp italicRegExp = RegExp(r'\*(.*?)\*'); // Matches *italic*
    final RegExp underlineRegExp = RegExp(r'_(.*?)_'); // Matches _underline_
    final RegExp infinityRegExp = RegExp(r'&&8'); // Matches &&8 for ∞
    final RegExp functionFRegExp = RegExp(r'&&f'); // Matches &&f for ƒ
    final RegExp arrowRegExp = RegExp(r'&&arf'); // Matches &&arf for →
    final RegExp leftArrowRegExp = RegExp(r'&&arb'); // Matches &&arb for ←
    final RegExp upArrowRegExp = RegExp(r'&&aru'); // Matches &&aru for ↑
    final RegExp downArrowRegExp = RegExp(r'&&ard'); // Matches &&ard for ↓
    final RegExp piRegExp = RegExp(r'&&pi'); // Matches &&pi for π
    final RegExp sqrtRegExp = RegExp(r'&&sqrt'); // Matches &&sqrt for √
    final RegExp noteqRegExp = RegExp(r'&&noteq'); // Matches &&noteq for ≠
    final RegExp emptySetRegExp = RegExp(r'&&empty'); // Matches &&empty for ∅
    final RegExp integRegExp = RegExp(r'&&integ'); // Matches &&integ for ∫
    final RegExp triangleRegExp =
        RegExp(r'&&triangle'); // Matches &&triangle for △
    final RegExp implicationRegExp = RegExp(r'&&imp'); // Matches &&imp for ⇒
    final RegExp biconditionalRegExp =
        RegExp(r'&&bimp'); // Matches &&bimp for ⇔
    final RegExp conjunctionRegExp = RegExp(r'&&invv'); // Matches &&invv for ∧
    final RegExp newlineRegExp = RegExp(r'&&nl'); // Matches &&nl for line break
    final RegExp alphaRegExp = RegExp(r'&&alpha'); // Matches &&alpha for α
    final RegExp betaRegExp = RegExp(r'&&beta'); // Matches &&beta for β
    final RegExp thetaRegExp = RegExp(r'&&theta'); // Matches &&theta for θ
    final RegExp gammaRegExp = RegExp(r'&&gamma'); // Matches &&gamma for γ
    final RegExp lambdaRegExp = RegExp(r'&&lambda'); // Matches &&lambda for λ
    final RegExp muRegExp = RegExp(r'&&mu'); // Matches &&mu for μ
    final RegExp nuRegExp = RegExp(r'&&nu'); // Matches &&nu for ν
    final RegExp rhoRegExp = RegExp(r'&&rho'); // Matches &&rho for ρ
    final RegExp tauRegExp = RegExp(r'&&tau'); // Matches &&tau for τ
    final RegExp phiRegExp = RegExp(r'&&phi'); // Matches &&phi for φ
    final RegExp psiRegExp = RegExp(r'&&psi'); // Matches &&psi for ψ
    final RegExp omegaRegExp = RegExp(r'&&omega'); // Matches &&omega for ω
    final RegExp etaRegExp = RegExp(r'&&eta'); // Matches &&eta for η
    final RegExp dotdotdotRegExp =
        RegExp(r'&&dotdotdot'); // Matches &&dotdotdot for ⋮
    final RegExp greaterEqualRegExp =
        RegExp(r'&&greaterequal'); // Matches &&greaterequal for ≥
    final RegExp lessEqualRegExp =
        RegExp(r'&&lessequal'); // Matches &&lessequal for ≤
    final RegExp plusMinusRegExp =
        RegExp(r'&&plusminus'); // Matches &&plusminus for ±
    final RegExp dashRegExp =
        RegExp(r'&&dash'); // Matches &&dash for __________
    final RegExp dashLongRegExp =
        RegExp(r'&&dashl'); // Matches &&dashl for ________________________
    final RegExp rSymbolRegExp = RegExp(r'&&r'); // Matches &&r for ℝ
    final RegExp naturalsRegExp = RegExp(r'&&nat'); // Matches &&nat for ℕ

    int startIndex = 0;

    // Helper function to add text span with base style
    void addTextSpan(String text, TextStyle style) {
      if (text.isNotEmpty) {
        spans
            .add(TextSpan(text: text, style: baseStyle?.merge(style) ?? style));
      }
    }

    // Find matches for superscripts
    for (final match in superscriptRegExp.allMatches(inputText)) {
      if (match.start > startIndex) {
        addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
      }
      addTextSpan(match.group(1)!,
          TextStyle(fontSize: 24, textBaseline: TextBaseline.alphabetic));
      startIndex = match.end;
    }

    inputText = inputText.replaceAll(superscriptRegExp, '');

    // Handle infinity symbol
    inputText = inputText.replaceAll(infinityRegExp, '∞');

    // Handle subscripts
    for (final match in subscriptRegExp.allMatches(inputText)) {
      if (match.start > startIndex) {
        addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
      }
      addTextSpan(match.group(1)!,
          TextStyle(fontSize: 12, textBaseline: TextBaseline.alphabetic));
      startIndex = match.end;
    }

    inputText = inputText.replaceAll(subscriptRegExp, '');

    // Handle bold
    for (final match in boldRegExp.allMatches(inputText)) {
      if (match.start > startIndex) {
        addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
      }
      addTextSpan(match.group(1)!, TextStyle(fontWeight: FontWeight.bold));
      startIndex = match.end;
    }

    inputText = inputText.replaceAll(boldRegExp, '');

    // Handle italic
    for (final match in italicRegExp.allMatches(inputText)) {
      if (match.start > startIndex) {
        addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
      }
      addTextSpan(match.group(1)!, TextStyle(fontStyle: FontStyle.italic));
      startIndex = match.end;
    }

    inputText = inputText.replaceAll(italicRegExp, '');

    // Handle underline
    for (final match in underlineRegExp.allMatches(inputText)) {
      if (match.start > startIndex) {
        addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
      }
      addTextSpan(
          match.group(1)!, TextStyle(decoration: TextDecoration.underline));
      startIndex = match.end;
    }

    // for (final match in underlineRegExp.allMatches(inputText)) {
    //   // Add the text before the match
    //   if (match.start > startIndex) {
    //     addTextSpan(inputText.substring(startIndex, match.start), TextStyle());
    //   }

    //   // Add the underlined text
    //   addTextSpan(
    //     match.group(1)!,
    //     TextStyle(decoration: TextDecoration.underline),
    //   );

    //   // Update the start index for the next segment
    //   startIndex = match.end;
    // }

    inputText = inputText.replaceAll(underlineRegExp, '');

    // Handle symbols and other patterns
    inputText = inputText
        .replaceAll(functionFRegExp, 'ƒ')
        .replaceAll(arrowRegExp, '→')
        .replaceAll(leftArrowRegExp, '←')
        .replaceAll(upArrowRegExp, '↑')
        .replaceAll(downArrowRegExp, '↓')
        .replaceAll(piRegExp, 'π')
        .replaceAll(sqrtRegExp, '√')
        .replaceAll(noteqRegExp, '≠')
        .replaceAll(emptySetRegExp, '∅')
        .replaceAll(integRegExp, '∫')
        .replaceAll(triangleRegExp, '△')
        .replaceAll(implicationRegExp, '⇒')
        .replaceAll(biconditionalRegExp, '⇔')
        .replaceAll(conjunctionRegExp, '∧')
        .replaceAll(newlineRegExp, '\n')
        .replaceAll(alphaRegExp, 'α')
        .replaceAll(betaRegExp, 'β')
        .replaceAll(thetaRegExp, 'θ')
        .replaceAll(gammaRegExp, 'γ')
        .replaceAll(lambdaRegExp, 'λ')
        .replaceAll(muRegExp, 'μ')
        .replaceAll(nuRegExp, 'ν')
        .replaceAll(rhoRegExp, 'ρ')
        .replaceAll(tauRegExp, 'τ')
        .replaceAll(phiRegExp, 'φ')
        .replaceAll(psiRegExp, 'ψ')
        .replaceAll(omegaRegExp, 'ω')
        .replaceAll(etaRegExp, 'η')
        .replaceAll(dotdotdotRegExp, '⋮')
        .replaceAll(greaterEqualRegExp, '≥')
        .replaceAll(lessEqualRegExp, '≤')
        .replaceAll(plusMinusRegExp, '±')
        .replaceAll(dashRegExp, '________')
        .replaceAll(dashLongRegExp, '______________________')
        .replaceAll(rSymbolRegExp, 'ℝ')
        .replaceAll(naturalsRegExp, 'ℕ');

    // Add any remaining normal text
    if (startIndex < inputText.length) {
      addTextSpan(inputText.substring(startIndex), TextStyle());
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    List<TextSpan> filteredSpans = filterText(text);

    return RichText(
      text: TextSpan(
        style: baseStyle ??
            TextStyle(
                fontSize: 16, color: Colors.black), // Use baseStyle if provided
        children: filteredSpans,
      ),
    );
  }
}
