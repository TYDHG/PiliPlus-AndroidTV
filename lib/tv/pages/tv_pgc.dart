import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models_new/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/pages/pgc/controller.dart';
import 'package:PiliPlus/tv/models/tv_video_data.dart';
import 'package:PiliPlus/tv/widgets/tv_feed_grid.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// TV 影视页，复用原影视数据控制器并使用遥控器网格界面。
class TvPgc extends StatefulWidget {
  const TvPgc({super.key});

  @override
  State<TvPgc> createState() => _TvPgcState();
}

class _TvPgcState extends State<TvPgc> {
  static const String _controllerTag = 'tv-pgc-cinema';
  static const double _posterAspectRatio = 3 / 4;

  final PgcController _controller = Get.put(
    PgcController(tabType: HomeTabType.cinema),
    tag: _controllerTag,
  );

  @override
  void dispose() {
    Get.delete<PgcController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TvFeedGrid<PgcIndexItem>(
      controller: _controller,
      toData: TvVideoData.fromPgc,
      onOpen: (item) => PageUtils.viewPgc(seasonId: item.seasonId),
      emptyMessage: '暂无影视内容',
      columns: 6,
      coverAspectRatio: _posterAspectRatio,
    );
  }
}
