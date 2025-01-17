import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoire/core/designs/colors/color_schemes.dart';

class CustomCodeRender extends StatefulWidget {
  const CustomCodeRender(
      {super.key,
      required this.renderContext,
      this.showBorder = true});

  final ExtensionContext renderContext;
  final bool showBorder;

  @override
  State<StatefulWidget> createState() => CustomCodeRenderState();
}

class CustomCodeRenderState extends State<CustomCodeRender> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    var language = '';
    if (widget.renderContext.attributes['class'] != null) {
      String lg =
          widget.renderContext.attributes['class'] as String;
      language = lg.substring(9);
    }
    var codeText = widget.renderContext.element!.text;
    if (language.isEmpty) {
      codeText = codeText
          .split('\n')
          .where((element) => element.trim().isNotEmpty)
          .join('\n');
      print('code text : $codeText');
      bool isMultiLine = codeText.contains('\n');
      return Container(
          width: isMultiLine
              ? MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .size
                  .width
              : null,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 240, 240, 240),
              border: isMultiLine ? Border.all(color: Colors.grey) : null,
              borderRadius: const BorderRadius.all(Radius.circular(4))),
          child: Padding(
            padding: isMultiLine ? const EdgeInsets.all(8) : EdgeInsets.zero,
            child: Text(
              codeText,
              style: TextStyle(
                  fontSize: isMultiLine ? 14 : 12, fontFamily: 'JetBrainsMono'),
            ),
          ));
    } else {
      return Container(
        padding: const EdgeInsets.all(4),
        width: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .size
            .width,
        decoration: widget.showBorder
            ? BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(8)))
            : null,
        child: Stack(
          children: [
            HighlightView(
              // The original code to be highlighted
              codeText,
              // Specify language
              // It is recommended to give it a value for performance
              language: language,
              // Specify highlight theme
              // All available themes are listed in `themes` folder
              theme: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                          .platformBrightness ==
                      Brightness.light
                  ? atomOneLightTheme
                  : atomOneLightTheme,
              // Specify padding
              padding: const EdgeInsets.all(8),
              // Specify text style
              textStyle: GoogleFonts.robotoMono(),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: MouseRegion(
                  key: widget.key,
                  onEnter: (event) {
                    setState(() {
                      _isHover = true;
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      _isHover = false;
                    });
                  },
                  child: IconButton(
                    alignment: AlignmentDirectional.topEnd,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: codeText))
                          .then((_) => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text("text copied to clipboard"))));
                    },
                    icon: Icon(
                      Icons.copy,
                      color: _isHover ? ColorSchemes.bluePrimary : Colors.grey,
                    ),
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                )),
          ],
        ),
      );
    }
  }
}
