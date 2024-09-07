import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:music_app/screen/colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/model/songs.dart';
import 'package:music_app/screen/songpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final PlaylistProvider playlistproviderr;
  String searchQuery = '';

  @override
  void initState() {
    playlistproviderr = Provider.of<PlaylistProvider>(context, listen: false);
    super.initState();
  }

  void gotosong(int song) {
    playlistproviderr.currentindex = song;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SongPage()));
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;
    final isDarkMode = themeColor.computeLuminance() < 0.5;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          "P l a y L i s t",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playlist = value.playlist
              .where((song) => song.songname
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black),
                    hintText: 'Search for songs...',
                    hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: playlist.length,
                  itemBuilder: (context, index) {
                    final Song song = playlist[index];
                    return ListTile(
                      title: Text(
                        song.artistname,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      subtitle: Text(
                        song.songname,
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(song.albumimagepath, width: 50),
                      ),
                      onTap: () => gotosong(index),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        child: Icon(
          Icons.color_lens,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ColorPickerDialog(),
          );
        },
      ),
    );
  }
}
