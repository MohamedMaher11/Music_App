import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // مكتبة GNav
import 'package:music_app/screen/Navbar_taps/favouratepage.dart';
import 'package:music_app/screen/Navbar_taps/hometap.dart';
import 'package:music_app/screen/Navbar_taps/songlist.dart';
import 'package:music_app/screen/Navbar_taps/songpage.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final PlaylistProvider playlistproviderr;
  int _selectedIndex = 0; // لتتبع التبويبات

  @override
  void initState() {
    playlistproviderr = Provider.of<PlaylistProvider>(context, listen: false);
    super.initState();
  }

  // الدوال التي تعرض الصفحات المختلفة بناءً على التبويبات
  List<Widget> _pages = [
    HomeTab(), // صفحة Home
    FavoritesPage(), // صفحة Favorites
    SongListPage(), // صفحة All Songs
    SongPage(), // صفحة الأغنية التي تُشغّل حاليًا
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: _pages[_selectedIndex], // عرض الصفحة المختارة
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            backgroundColor: Color.fromRGBO(3, 27, 75, 0.301),
            activeColor: Colors.black,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white,
            color: Colors.grey,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.favorite,
                text: 'Favorites',
              ),
              GButton(
                icon: Icons.library_music,
                text: 'All Songs',
              ),
              GButton(
                icon: Icons.music_note,
                text: 'Now Playing',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
