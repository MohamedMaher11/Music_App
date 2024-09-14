import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:music_app/screen/Home/homepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';

// Define your primary color
const Color primaryColor = Color(0xFFFF5722); // Orange color

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider()..loadThemeColor(), // Load saved theme
        ),
      ],
      child: MyApp(),
    ),
  );
}

Future<PermissionStatus> checkAndRequest() async {
  PermissionStatus status = await Permission.storage.status;
  if (status.isDenied) {
    status = await Permission.storage.request();
  }
  return status;
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkAndRequest().then((status) {
      if (status.isGranted) {
        print("Storage permission granted");
      } else {
        print("Permission denied");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // Required for DevicePreview
      theme: ThemeData(
        brightness: Brightness.dark,
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
          color: primaryColor,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: primaryColor,
        ),

        // Add more theme customizations here if needed
      ),
      home: Homepage(),
    );
  }
}
