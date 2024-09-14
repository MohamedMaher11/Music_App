import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:music_app/screen/Navbar_taps/songpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, String>> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoriteSongsData = prefs.getStringList('favoriteSongs') ?? [];

    setState(() {
      favoriteSongs = favoriteSongsData.map((item) {
        final parts = item.split('|');
        return {
          'id': parts[0],
          'title': parts[1],
          'artist': parts[2],
        };
      }).toList();
    });
  }

  Future<void> _removeFromFavorites(String songId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSongsData = prefs.getStringList('favoriteSongs') ?? [];

    favoriteSongsData.removeWhere((item) => item.startsWith('$songId|'));
    prefs.setStringList('favoriteSongs', favoriteSongsData);

    setState(() {
      favoriteSongs.removeWhere((song) => song['id'] == songId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.transparent,
      ),
      body: favoriteSongs.isEmpty
          ? Center(
              child: Text(
                'No favorites yet.',
                style: TextStyle(color: themeColor),
              ),
            )
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  leading: QueryArtworkWidget(
                    id: int.parse(song['id']!),
                    type: ArtworkType.AUDIO,
                    keepOldArtwork: true,
                    artworkHeight: 50,
                    artworkWidth: 50,
                    nullArtworkWidget: Icon(
                      Icons.music_note,
                      size: 50,
                      color: themeColor,
                    ),
                  ),
                  title: Text(song['title']!),
                  subtitle: Text(song['artist']!),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _removeFromFavorites(song['id']!),
                  ),
                  onTap: () {
                    // Set the current index to the tapped song's index in the playlist
                    final index = playlistProvider.playlist
                        .indexWhere((p) => p.id.toString() == song['id']);
                    if (index != -1) {
                      playlistProvider.currentindex = index;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SongPage()),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
