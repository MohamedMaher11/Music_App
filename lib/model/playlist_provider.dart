import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlaylistProvider extends ChangeNotifier {
  List<SongModel> _playlist = [];
  List<SongModel> _recentSongs =
      []; // قائمة للأغاني اللي تم الاستماع إليها مؤخراً

  int? _currentindex = 0;

  // Audio player
  final OnAudioQuery _audioQuery = OnAudioQuery();

  final _audioPlayer = AudioPlayer();
  bool _isRepeating = false;
  bool _isShuffling = false;

  // Durations
  Duration _currentduration = Duration.zero;
  Duration _totalduration = Duration.zero;

  // Constructor
  PlaylistProvider() {
    listenToDuration();
    _requestPermissionAndLoadSongs();
    _loadRecentSongsFromSharedPrefs(); // تحميل recentSongs عند التهيئة
  }

  bool _isplaying = false;
  void _addRecentSong(SongModel song) async {
    if (!_recentSongs.contains(song)) {
      _recentSongs.add(song);

      // نحتفظ بآخر 10 أغاني فقط
      if (_recentSongs.length > 10) {
        _recentSongs.removeAt(0);
      }

      // تحويل قائمة الأغاني إلى قائمة JSON لتخزينها في SharedPreferences
      List<String> recentSongsData = _recentSongs.map((song) {
        return jsonEncode({
          'id': song.id,
          'title': song.title,
          'artist': song.artist,
          'uri': song.uri,
        });
      }).toList();

      // حفظ القائمة في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSongs', recentSongsData);
    }

    notifyListeners();
  }

  List<SongModel> get recentSongs => _recentSongs;
  Future<void> _loadRecentSongsFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSongsData = prefs.getStringList('recentSongs') ?? [];

    // تحويل البيانات المحفوظة إلى كائنات SongModel
    _recentSongs = recentSongsData.map((songJson) {
      Map<String, dynamic> songMap = jsonDecode(songJson);

      // بناء SongModel من البيانات المخزنة
      return SongModel({
        '_id': songMap['id'],
        'title': songMap['title'],
        'artist': songMap['artist'],
        '_uri': songMap['uri'],
      });
    }).toList();

    notifyListeners(); // تحديث واجهة المستخدم
  }

  Future<void> _requestPermissionAndLoadSongs() async {
    if (await Permission.storage.request().isGranted) {
      _loadSongs();
    } else {
      // Handle the case when permission is denied
    }
  }

  Future<void> _loadSongs() async {
    _playlist = await _audioQuery.querySongs();
    notifyListeners();
  }

  // Play the song
  void play() async {
    if (_playlist.isNotEmpty && _currentindex != null) {
      await _loadRecentSongsFromSharedPrefs();

      final SongModel currentSong =
          _playlist[_currentindex!]; // احصل على الأغنية الحالية
      final String path = currentSong.uri ?? '';
      try {
        // قم بتهيئة الصوت قبل التحديث
        await _audioPlayer.setUrl(path);

        // استمع إلى حالة المشغل وتحديث واجهة المستخدم بناءً على حالة التشغيل الفعلية
        _audioPlayer.playerStateStream.listen((playerState) {
          if (playerState.playing) {
            _isplaying = true;
          } else {
            _isplaying = false;
          }
          notifyListeners();
        });

        // بعد تهيئة الصوت، ابدأ التشغيل
        await _audioPlayer.play();

        // إضافة الأغنية إلى قائمة الأغاني الحديثة
        _addRecentSong(currentSong);
      } catch (e) {
        print("Error: $e");
      }
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

    _audioPlayer.playerStateStream.listen(
      (playerState) {
        if (playerState.playing) {
          _isplaying = true;
        } else {
          _isplaying = false;
        }
        notifyListeners();
      },
    );
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

  void setPlaylist(List<SongModel> playlist, int index) {
    _playlist = playlist;
    currentindex = index; // سيتم استدعاء play هنا
    notifyListeners();
  }

  // Getters

  bool get isplaying => _isplaying;
  Duration get currentDuration => _currentduration;
  Duration get totalDuration => _totalduration;
  List<SongModel> get playlist => _playlist;
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
