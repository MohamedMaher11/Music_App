class Song {
  final String songname;
  final String artistname;
  final String albumimagepath;
  final String audiopath;

  Song(
      {required this.songname,
      required this.artistname,
      required this.albumimagepath,
      required this.audiopath});
}

class SongModel {
  final String songName;
  final String artistName;
  final String albumImagePath;
  final String audioPath;

  SongModel({
    required this.songName,
    required this.artistName,
    required this.albumImagePath,
    required this.audioPath,
  });
}
