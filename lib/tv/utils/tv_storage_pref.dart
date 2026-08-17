import 'package:PiliPlus/tv/enums/tv_pref_enums.dart';
import 'package:PiliPlus/tv/utils/tv_storage_key.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:hive_ce/hive.dart';

///  TV specific preferences
abstract final class TvPref {
  static final Box _setting = GStorage.setting;

  static const List<TvNavigationType> defaultNavigationBar = [
    TvNavigationType.hot,
    TvNavigationType.cinema,
    TvNavigationType.live,
    TvNavigationType.dynamics,
    TvNavigationType.mine,
  ];

  static List<TvNavigationType> get tvNavigationBar {
    final rawValue = _setting.get(TvSettingBoxKey.tvNavigationBar);

    if (rawValue is! List) {
      return List.of(defaultNavigationBar);
    }

    final result = <TvNavigationType>[];

    for (final id in rawValue.whereType<String>()) {
      final item = TvNavigationType.values
          .where((item) => item.id == id)
          .firstOrNull;

      if (item != null && !result.contains(item)) {
        result.add(item);
      }
    }

    return result;
  }

  static set tvNavigationBar(List<TvNavigationType> value) {
    _setting.put(
      TvSettingBoxKey.tvNavigationBar,
      value.map((item) => item.id).toList(),
    );
  }
}
