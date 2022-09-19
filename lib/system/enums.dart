
enum SubBucketTypes {
  video(1),
  audio(2),
  list(10);

  final int _type;

  const SubBucketTypes(this._type);

  int id(){
    return _type;
  }
}
///=====================================================================================
enum VideoSourceType {
  file,
  network,
  bytes,
  asset
}
///=====================================================================================
enum SavePathType {
  userProfile,
  anyOnInternal,
}
///=====================================================================================
enum ImageType {
  file,
  bytes,
  asset
}