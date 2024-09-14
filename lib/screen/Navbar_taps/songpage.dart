import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongPage extends StatefulWidget {
  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool isFavorite = false;

  @override
  @override
  void initState() {
    super.initState();

    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // تحقق من الحالة الأولية لتشغيل الصورة والأيقونة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playlistProvider.isplaying) {
        _rotationController.repeat();
        setState(() {}); // تحديث واجهة المستخدم لتعكس حالة التشغيل
      } else {
        _rotationController.stop();
        setState(() {}); // تحديث واجهة المستخدم لتعكس حالة الإيقاف المؤقت
      }
    });

    // أضف مستمعًا لتحديث واجهة المستخدم عند تغيير حالة isplaying
    playlistProvider.addListener(() {
      if (playlistProvider.isplaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
      setState(() {}); // تحديث واجهة المستخدم عند تغيير الحالة
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final currentSongId = Provider.of<PlaylistProvider>(context, listen: false)
        .playlist[Provider.of<PlaylistProvider>(context, listen: false)
                .currentindex ??
            0]
        .id;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoriteSongs = prefs.getStringList('favoriteSongs') ?? [];

    setState(() {
      isFavorite =
          favoriteSongs.any((item) => item.startsWith('$currentSongId|'));
    });
  }

  Future<void> _addToFavorites() async {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final currentSong =
        playlistProvider.playlist[playlistProvider.currentindex ?? 0];
    final currentSongId = currentSong.id;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSongs = prefs.getStringList('favoriteSongs') ?? [];

    if (!favoriteSongs.any((item) => item.startsWith('$currentSongId|'))) {
      final songData =
          '$currentSongId|${currentSong.title}|${currentSong.artist}';
      favoriteSongs.add(songData);
      prefs.setStringList('favoriteSongs', favoriteSongs);
      setState(() {
        isFavorite = true;
      });
    }
  }

  Future<void> _removeFromFavorites() async {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final currentSong =
        playlistProvider.playlist[playlistProvider.currentindex ?? 0];
    final currentSongId = currentSong.id;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteSongs = prefs.getStringList('favoriteSongs') ?? [];

    favoriteSongs.removeWhere((item) => item.startsWith('$currentSongId|'));
    prefs.setStringList('favoriteSongs', favoriteSongs);

    setState(() {
      isFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;

    return Consumer<PlaylistProvider>(builder: (context, value, child) {
      final playlist = value.playlist;
      final currentsong = playlist[value.currentindex ?? 0];

      // دالة لتنسيق الوقت
      String formatDuration(Duration duration) {
        if (duration == Duration.zero) return "00:00";
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final minutes = twoDigits(duration.inMinutes.remainder(60));
        final seconds = twoDigits(duration.inSeconds.remainder(60));
        return '$minutes:$seconds';
      }

      final remainingTime = value.totalDuration - value.currentDuration;

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // صورة الألبوم
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      padding: EdgeInsets.all(4.0), // حجم الإطار
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black, // اللون البرتقالي للإطار
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3), // ظل خفيف
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // موقع الظل
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: currentsong.id,
                          type: ArtworkType.AUDIO,
                          keepOldArtwork: true,
                          artworkHeight: 250,
                          artworkWidth: 250,
                          nullArtworkWidget: Icon(
                            Icons.music_note,
                            size: 250,
                            color: Colors
                                .white, // اللون الذي سيظهر إذا كانت الصورة غير موجودة
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  // اسم الأغنية والفنان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          currentsong.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              _removeFromFavorites();
                            } else {
                              _addToFavorites();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currentsong.artist ?? "Unknown Artist",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  // شريط تقدم الأغنية
                  Slider(
                    min: 0,
                    max: value.totalDuration.inSeconds.toDouble(),
                    value: value.currentDuration.inSeconds.toDouble(),
                    onChanged: (newValue) {
                      value.seekSong(Duration(seconds: newValue.toInt()));
                    },
                    activeColor: themeColor,
                    inactiveColor: Colors.grey,
                  ),
                  // الوقت المنقضي والوقت المتبقي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(value.currentDuration),
                        style: TextStyle(color: themeColor),
                      ),
                      Text(
                        "- ${formatDuration(remainingTime)}",
                        style: TextStyle(color: themeColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: value.isShuffling ? themeColor : Colors.grey,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          value.toggleShuffle();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        iconSize: 40,
                        color: Colors.white,
                        onPressed: () {
                          value.playPrevious();
                          _checkIfFavorite();
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 2,
                                  spreadRadius: 2)
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          icon: Icon(
                            color: Colors.black,
                            value.isplaying ? Icons.pause : Icons.play_arrow,
                          ),
                          iconSize: 40,
                          onPressed: () {
                            value.pauseOrResume();
                            if (value.isplaying) {
                              _rotationController.repeat();
                            } else {
                              _rotationController.stop();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        iconSize: 40,
                        color: Colors.white,
                        onPressed: () {
                          value.playNext();
                          _checkIfFavorite(); // تحديث حالة الأيقونة عند تغيير الأغنية
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.repeat,
                          color: value.isRepeating ? themeColor : Colors.grey,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          value.toggleRepeat();
                          setState(() {}); // لتحديث حالة الزر
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
