import 'package:PiliPlus/tv/enums/tv_pref_enums.dart';
import 'package:PiliPlus/tv/pages/tv_dynamics.dart';
import 'package:PiliPlus/tv/pages/tv_hot.dart';
import 'package:PiliPlus/tv/pages/tv_live.dart';
import 'package:PiliPlus/tv/pages/tv_my.dart';
import 'package:PiliPlus/tv/pages/tv_pgc.dart';
import 'package:flutter/cupertino.dart';

abstract final class TvNavigationRegistry {
  static Widget build(TvNavigationType type) {
    return switch (type) {
      TvNavigationType.hot => const TvHot(),
      TvNavigationType.cinema => const TvPgc(),
      TvNavigationType.live => const TvLive(),
      TvNavigationType.dynamics => const TvDynamics(),
      TvNavigationType.mine => const TvMy(),
    };
  }
}
