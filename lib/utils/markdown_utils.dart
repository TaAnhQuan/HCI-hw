import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownUtils {
  static Widget buildMarkdownWithMath(String text) {
    final hasMath = RegExp(r'\\\[.*?\\\]|\\\(.*?\\\)').hasMatch(text);

    if (hasMath || _isMarkdownFormat(text)) {
      return MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(fontSize: 15, color: Color(0xFFFFFFFF)),
          h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
          h2: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
          h3: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
        ),
        builders: {
          'math': MathBuilder(),
        },
      );
    } else {
      return Text(
        text,
        style: TextStyle(fontSize: 15, color: Color(0xFFFFFFFF)),
      );
    }
  }

  static bool _isMarkdownFormat(String text) {
    return RegExp(r'^\s*#+\s+|\*\s+|\-\s+|\d+\.\s+|^(\s*$)').hasMatch(text);
  }
}

class MathBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    final mathText = text.text.trim();
    if (mathText.startsWith(r'\[') && mathText.endsWith(r'\]')) {
      return Math.tex(
        mathText.substring(2, mathText.length - 2),
        textStyle: preferredStyle ?? TextStyle(color: Color(0xFFFFFFFF)),
      );
    } else if (mathText.startsWith(r'\(') && mathText.endsWith(r'\)')) {
      return Math.tex(
        mathText.substring(2, mathText.length - 2),
        textStyle: preferredStyle ?? TextStyle(color: Color(0xFFFFFFFF)),
      );
    } else {
      return Text(mathText, style: preferredStyle ?? TextStyle(color: Color(0xFFFFFFFF)));
    }
  }
}
