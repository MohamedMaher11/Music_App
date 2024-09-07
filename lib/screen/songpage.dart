import 'package:flutter/material.dart';
import 'package:music_app/core/cache.dart';
import 'package:provider/provider.dart';
import 'package:music_app/model/playlist_provider.dart';

class SongPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeColor;

    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
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
          backgroundColor: themeColor.withOpacity(0.1),
          appBar: AppBar(
            backgroundColor: themeColor.withOpacity(0.1),
            title: Text(
              'Now Playing',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورة الألبوم
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    currentsong.albumimagepath,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),

                // اسم الأغنية والفنان
                Text(
                  currentsong.songname,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                Text(
                  currentsong.artistname,
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

                // زر Shuffle وزر Repeat

                // الأزرار: السابق، التشغيل/الإيقاف المؤقت، التالي
                SizedBox(height: 20),
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
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      iconSize: 40,
                      color: themeColor,
                      onPressed: value.playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        value.isplaying ? Icons.pause : Icons.play_arrow,
                      ),
                      iconSize: 40,
                      color: themeColor,
                      onPressed: value.pauseOrResume,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      iconSize: 40,
                      color: themeColor,
                      onPressed: value.playNext,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: value.isRepeating ? themeColor : Colors.grey,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        value.toggleRepeat();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
