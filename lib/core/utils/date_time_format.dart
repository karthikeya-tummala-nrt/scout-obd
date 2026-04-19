String formatDdMmYyyyHm(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');

  final dd = two(dt.day);
  final mm = two(dt.month);
  final yyyy = dt.year.toString().padLeft(4, '0');
  final hh = two(dt.hour);
  final min = two(dt.minute);
  final sec = two(dt.second);

  return '$dd-$mm-$yyyy  $hh:$min:$sec';
}
