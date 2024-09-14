import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/screen/Navbar_taps/songpage.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<SongModel> recentSongs = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSongs(); // استدعاء دالة تحميل الأغاني عند تهيئة الشاشة
  }

  Future<void> _loadRecentSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSongsData = prefs.getStringList('recentSongs') ?? [];

    List<SongModel> loadedRecentSongs = recentSongsData.map((songJson) {
      Map<String, dynamic> songMap = jsonDecode(songJson);

      // بناء كائن SongModel من البيانات المخزنة
      return SongModel({
        '_id': songMap['id'],
        'title': songMap['title'],
        'artist': songMap['artist'],
        '_uri': songMap['uri'],
      });
    }).toList();

    setState(() {
      recentSongs = loadedRecentSongs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;
    final recentSongs = Provider.of<PlaylistProvider>(context).recentSongs;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage('assets/image/singer.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCard(
                          context,
                          icon: Icons.radio,
                          title: "Radio Stations - Coming Soon!",
                        ),
                        SizedBox(height: 16),
                        _buildCard(
                          context,
                          icon: Icons.play_arrow,
                          title: "Listen Now",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Songs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: recentSongs.isNotEmpty
                    ? ListView.builder(
                        itemCount: recentSongs.length,
                        itemBuilder: (context, index) {
                          final song = recentSongs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  keepOldArtwork: true,
                                  nullArtworkWidget: Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  song.artist ?? "Unknown Artist",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                onTap: () {
                                  final playlistProvider =
                                      Provider.of<PlaylistProvider>(context,
                                          listen: false);
                                  playlistProvider.currentindex =
                                      playlistProvider.playlist
                                          .indexWhere((s) => s.id == song.id);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        "No recent songs",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon, required String title}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
