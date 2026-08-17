/// TV navigations
enum TvNavigationType {
  hot('hot', '热门'),
  cinema('cinema', '影视'),
  live('live', '直播'),
  dynamics('dynamics', '动态'),
  mine('mine', '我的');

  const TvNavigationType(this.id, this.label);

  final String id;
  final String label;
}
