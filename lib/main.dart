import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/screen/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                ThemeProvider()..loadThemeColor()), // تحميل الثيم المحفوظ
      ],
      child: DevicePreview(
        enabled: true, // قم بتعطيل هذا في الإنتاج
        builder: (context) => MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // مطلوب لـ DevicePreview
      locale: DevicePreview.locale(context), // لمحاكاة اللغات المختلفة
      builder: DevicePreview.appBuilder, // التفاف التطبيق بـ DevicePreview
      theme: ThemeData(
        primarySwatch: createMaterialColor(
            themeProvider.themeColor), // استخدام اللون من الثيم
      ),
      home: Homepage(),
    );
  }
}

// Helper function to create MaterialColor from a custom Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
