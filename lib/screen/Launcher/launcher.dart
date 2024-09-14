import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:music_app/screen/Home/homepage.dart'; // الصفحة اللي هنروح ليها بعد الأنيميشن
import 'dart:async';

class LauncherScreen extends StatefulWidget {
  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  void initState() {
    super.initState();

    // بعد 3 ثواني، هنروح للصفحة الرئيسية (Homepage)
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Homepage()), // هنا بنروح للـ Homepage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // الخلفية لونها أسود عشان تدي شكل حلو
      body: Center(
        child: Lottie.asset(
          'assets/launcsong.json', // ملف Lottie Animation
          width: 300, // حجم الأنيميشن في النص
          height: 300, // تعديل الحجم عشان يبقى أكبر شويه في النص
          fit: BoxFit.contain, // يخلي الأنيميشن ياخد حجمه الطبيعي في النص
        ),
      ),
    );
  }
}
