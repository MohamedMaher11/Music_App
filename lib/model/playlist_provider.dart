import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_app/model/songs.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [
    Song(
        songname: "HABIBY",
        artistname: "Mohamed Maher",
        albumimagepath: "assets/image/singer.jpg",
        audiopath: "assets/songs/ahmed1.mp3"),
    Song(
        songname: "Tamaly Maak",
        artistname: "Mohamed Ramadan",
        albumimagepath: "assets/image/songphoto2.png",
        audiopath: "assets/songs/ahmed2.mp3"),
    Song(
        songname: "Alby",
        artistname: "sherein",
        albumimagepath: "assets/image/songphoto3.jpg",
        audiopath: "assets/songs/ahmed3.mp3")
  ];

  int? _currentindex = 0;

  // Audio player
  final _audioPlayer = AudioPlayer();
  bool _isRepeating = false;
  bool _isShuffling = false;

  // Durations
  Duration _currentduration = Duration.zero;
  Duration _totalduration = Duration.zero;

  // Constructor
  PlaylistProvider() {
    listenToDuration();
  }

  bool _isplaying = false;

  // Play the song
  void play() async {
    final String path = _playlist[_currentindex!].audiopath;
    print("Playing file at path: $path");

    try {
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
      _isplaying = true;
      notifyListeners();
    } catch (e) {
      print("Error: $e");
    }
  }

  // Pause the song
// Pause the song
  void pause() async {
    await _audioPlayer.pause();
    _isplaying = false;
    notifyListeners();
  }

// Resume playing
  void resume() async {
    await _audioPlayer.play();
    _isplaying = true;
    notifyListeners();
  }

// Pause or resume
  void pauseOrResume() async {
    if (_isplaying) {
      // 1. تحديث الأيقونة إلى زر التشغيل فوراً
      _isplaying = false;
      notifyListeners(); // نُحدث واجهة المستخدم مباشرة

      // 2. إيقاف الصوت في الخلفية
      await _audioPlayer.pause();
    } else {
      // 1. تحديث الأيقونة إلى زر الإيقاف فوراً
      _isplaying = true;
      notifyListeners(); // نُحدث واجهة المستخدم مباشرة

      // 2. تشغيل الصوت في الخلفية
      await _audioPlayer.play();
    }
  }

  // Seek to specific position
  void seekSong(Duration newPosition) {
    // Assuming you have an audioPlayer instance that controls the playback
    _audioPlayer.seek(newPosition);

    // Update the currentDuration to reflect the new position
    _currentduration = newPosition;

    // Notify listeners that the duration has changed
    notifyListeners();
  }

  // Play next song
  void playNext() {
    if (_isShuffling) {
      // اختيار أغنية عشوائية جديدة بشرط أن تكون مختلفة عن الأغنية الحالية
      int nextIndex = _currentindex!;
      final random = Random();

      // التأكد من أن الأغنية العشوائية ليست نفسها الحالية
      while (nextIndex == _currentindex) {
        nextIndex = random.nextInt(_playlist.length);
      }

      // تغيير الأغنية إلى الأغنية العشوائية
      currentindex = nextIndex;
    } else if (_isRepeating) {
      // إعادة تشغيل نفس الأغنية عند التكرار
      seekSong(Duration.zero);
      play();
    } else {
      // التشغيل العادي
      if (_currentindex != null && _currentindex! < _playlist.length - 1) {
        currentindex = _currentindex! + 1;
      } else {
        currentindex = 0;
      }
    }
  }

  // Play previous song
  void playPrevious() {
    if (_currentduration.inSeconds > 2) {
      seekSong(Duration.zero);
    } else {
      if (_currentindex! > 0) {
        currentindex = _currentindex! - 1;
      } else {
        currentindex = _playlist.length - 1;
      }
    }
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    notifyListeners();
  }

  // Listen to duration changes
  void listenToDuration() {
    _audioPlayer.positionStream.listen((newPosition) {
      _currentduration = newPosition;
      notifyListeners(); // Update the current time
    });

    _audioPlayer.durationStream.listen((newDuration) {
      _totalduration = newDuration ?? Duration.zero;
      notifyListeners(); // Update the total song duration
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNext(); // Move to the next song when the current one is completed
      }
    });
  }

  // Dispose the player when done
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Getters
  bool get isplaying => _isplaying;
  Duration get currentDuration => _currentduration;
  Duration get totalDuration => _totalduration;
  List<Song> get playlist => _playlist;
  int? get currentindex => _currentindex;
  bool get isRepeating => _isRepeating;
  bool get isShuffling => _isShuffling;
  // Setter
  set currentindex(int? newindex) {
    _currentindex = newindex;
    if (newindex != null) {
      play();
    }
    notifyListeners();
  }
}
