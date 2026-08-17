import 'package:PiliPlus/tv/enums/tv_pref_enums.dart';
import 'package:PiliPlus/tv/tv_theme.dart';
import 'package:PiliPlus/tv/utils/tv_storage_pref.dart';
import 'package:PiliPlus/tv/widgets/tv_option_row.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:get/get.dart';

class TvNavigationSettings extends StatefulWidget {
  const TvNavigationSettings({super.key});

  @override
  State<TvNavigationSettings> createState() => _TvNavigationSettingsState();
}

class _TvNavigationSettingsState extends State<TvNavigationSettings> {
  static const double _rowGap = 16 * TvTheme.designScale;

  late final List<TvNavigationType> _enabledItems = [
    ...TvPref.tvNavigationBar,
  ];
  bool _changed = false;

  List<TvNavigationType> get _items => [
    ..._enabledItems,
    ...TvNavigationType.values.where(
      (item) => !_enabledItems.contains(item),
    ),
  ];

  void _save() {
    TvPref.tvNavigationBar = _enabledItems;
    _changed = true;
  }

  void _toggle(TvNavigationType item) {
    setState(() {
      if (_enabledItems.remove(item)) {
        _save();
        return;
      }
      _enabledItems.add(item);
      _save();
    });
  }

  void _move(TvNavigationType item, int offset) {
    final index = _enabledItems.indexOf(item);
    if (index < 0) return;
    final target = index + offset;
    if (target < 0 || target >= _enabledItems.length) return;
    setState(() {
      _enabledItems
        ..removeAt(index)
        ..insert(target, item);
      _save();
    });
  }

  KeyEventResult _onItemKey(
    TvNavigationType item,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _move(item, -1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _move(item, 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onBack(bool didPop, Object? result) {
    if (!didPop) Get.back(result: _changed);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Scaffold(
        backgroundColor: TvTheme.background,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: TvTheme.backgroundGradient,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 920 * TvTheme.designScale,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  TvTheme.screenPadding,
                  TvTheme.screenPadding,
                  TvTheme.screenPadding,
                  TvTheme.gridBottomPadding,
                ),
                children: [
                  const Text('顶部导航', style: TvTheme.sectionHeader),
                  const SizedBox(height: 12 * TvTheme.designScale),
                  const Text(
                    '推荐和设置固定显示；按 OK 显示或隐藏，使用左右键调整顺序。',
                    style: TvTheme.cardMeta,
                  ),
                  const SizedBox(height: 28 * TvTheme.designScale),
                  for (var index = 0; index < items.length; index++) ...[
                    TvOptionRow(
                      autofocus: index == 0,
                      label: items[index].label,
                      value: _enabledItems.contains(items[index])
                          ? '已显示  ·  ◀ ▶ 排序'
                          : '已隐藏',
                      checked: _enabledItems.contains(items[index]),
                      onSelect: () => _toggle(items[index]),
                      onKeyEvent: (node, event) =>
                          _onItemKey(items[index], event),
                    ),
                    if (index != items.length - 1)
                      const SizedBox(height: _rowGap),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
