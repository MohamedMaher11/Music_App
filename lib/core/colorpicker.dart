/*import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:music_app/core/cache.dart';
import 'package:provider/provider.dart';

class ColorPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Choose Your Color '),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: themeProvider.themeColor,
          onColorChanged: (color) {
            themeProvider.changeThemeColor(color);
            Navigator.of(context).pop(); // إغلاق النافذة بعد اختيار اللون
          },
        ),
      ),
    );
  }
}
*/