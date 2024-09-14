import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/screen/Navbar_taps/songpage.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  String searchQuery = '';
  bool sortByRecent = true; // فلتر حسب الوقت

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;

    return Scaffold(
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          // تصفية قائمة التشغيل بناءً على البحث
          final filteredPlaylist = playlistProvider.playlist.where((song) {
            return song.title.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          // ترتيب الأغاني إذا كان الفلتر حسب الوقت
          if (sortByRecent) {
            filteredPlaylist
                .sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
          }

          // عرض مؤشر تحميل إذا لم توجد أغاني
          if (filteredPlaylist.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "استمتع بتجربة موسيقية رائعة 🎶",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'S e a r c h',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton<int>(
                          icon: FaIcon(
                            FontAwesomeIcons.filter, // أيقونة الفلتر الرئيسية
                            color: Colors.orange,
                          ),
                          onSelected: (value) {
                            setState(() {
                              if (value == 1) {
                                sortByRecent = false; // ترتيب من A إلى Z
                              } else if (value == 2) {
                                sortByRecent =
                                    true; // ترتيب حسب الأغاني الحديثة
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha,
                                      color: Colors.white), // أيقونة A to Z
                                  SizedBox(width: 10),
                                  Text("A to Z"),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.schedule,
                                      color:
                                          Colors.white), // أيقونة Recent Songs
                                  SizedBox(width: 10),
                                  Text("Recent Songs"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredPlaylist.length,
                    itemBuilder: (context, index) {
                      final song = filteredPlaylist[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: ListTile(
                          leading: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            keepOldArtwork: true,
                            nullArtworkWidget: Icon(
                              Icons.music_note,
                              color: themeColor,
                              size: 40,
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            song.artist ?? "Unknown Artist",
                          ),
                          onTap: () {
                            // بدل من استخدام الفهرس من playlistProvider، استخدم الفهرس من القائمة المفلترة
                            playlistProvider.currentindex = playlistProvider
                                .playlist
                                .indexWhere((s) => s.id == song.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SongPage(),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
