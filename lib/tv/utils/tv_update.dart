import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/http/browser_ua.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/tv/focus/tv_focusable.dart';
import 'package:PiliPlus/tv/tv_theme.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Android TV 独立更新服务，不影响通用端的更新来源和弹框。
abstract final class TvUpdate {
  static const _repositoryUrl = 'https://github.com/TYDHG/PiliPlus-AndroidTV';
  static const _latestReleaseApi =
      'https://api.github.com/repos/TYDHG/PiliPlus-AndroidTV/releases/latest';

  static Future<void> checkUpdate(BuildContext context) async {
    _showDialog(
      context,
      title: '检查更新',
      message: '正在获取最新版本…',
      showCancel: false,
      showAction: false,
    );

    try {
      final response = await Request().get(
        _latestReleaseApi,
        options: Options(
          headers: {'user-agent': BrowserUa.mob},
          extra: {'account': const NoAccount()},
        ),
      );
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('GitHub Release 数据格式错误');
      }

      final release = await _parseRelease(data);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (release.isCurrent) {
        _showDialog(
          context,
          title: '已是最新版本',
          message: '当前版本：${_currentVersion()}',
          showCancel: false,
        );
        return;
      }

      _showDialog(
        context,
        title: '发现新版本 ${release.tag}',
        message: release.notes.isEmpty ? '该版本暂无更新说明。' : release.notes,
        actionLabel: release.downloadUrl == null ? '打开发布页' : '下载 APK',
        onAction: () => PageUtils.launchURL(
          release.downloadUrl ?? '$_repositoryUrl/releases/latest',
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (kDebugMode) debugPrint('TV check update failed: $error');
      _showDialog(
        context,
        title: '检查更新失败',
        message: '无法获取最新版本，请检查网络后重试。',
        showCancel: false,
      );
    }
  }

  static Future<_TvRelease> _parseRelease(Map data) async {
    final tag = '${data['tag_name'] ?? '未知版本'}';
    final notes = '${data['body'] ?? ''}'.trim();
    final assets = data['assets'] is List ? data['assets'] as List : const [];
    final currentVersion = _currentVersion();
    print('当前版本：$currentVersion');
    final isCurrentAsset = assets.any(
      (asset) => asset is Map && '${asset['name']}'.contains(currentVersion),
    );
    final createdAt = DateTime.tryParse('${data['created_at'] ?? ''}');
    final isNotNewer =
        createdAt != null &&
        BuildConfig.buildTime > 0 &&
        BuildConfig.buildTime >= createdAt.millisecondsSinceEpoch ~/ 1000;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    String? downloadUrl;
    for (final abi in androidInfo.supportedAbis) {
      for (final asset in assets) {
        if (asset is! Map) continue;
        final name = '${asset['name'] ?? ''}';
        if (name.endsWith('.apk') && name.contains(abi)) {
          downloadUrl = '${asset['browser_download_url']}';
          break;
        }
      }
      if (downloadUrl != null) break;
    }

    return _TvRelease(
      tag: tag,
      notes: notes,
      downloadUrl: downloadUrl,
      isCurrent: isCurrentAsset || isNotNewer,
    );
  }

  static String _currentVersion() =>
      '${BuildConfig.versionName}+${BuildConfig.versionCode}';

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = '确定',
    VoidCallback? onAction,
    bool showCancel = true,
    bool showAction = true,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TvUpdateDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        showCancel: showCancel,
        showAction: showAction,
      ),
    );
  }
}

class _TvRelease {
  const _TvRelease({
    required this.tag,
    required this.notes,
    required this.downloadUrl,
    required this.isCurrent,
  });

  final String tag;
  final String notes;
  final String? downloadUrl;
  final bool isCurrent;
}

class _TvUpdateDialog extends StatelessWidget {
  const _TvUpdateDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.showCancel,
    required this.showAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool showCancel;
  final bool showAction;

  void _closeAndRun(BuildContext context) {
    Navigator.of(context).pop();
    onAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 820 * TvTheme.designScale,
            maxHeight: 680 * TvTheme.designScale,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: TvTheme.surface,
              borderRadius: TvTheme.cardRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(36 * TvTheme.designScale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TvTheme.sectionHeader),
                  const SizedBox(height: 24 * TvTheme.designScale),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(message, style: TvTheme.cardMeta),
                    ),
                  ),
                  const SizedBox(height: 32 * TvTheme.designScale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (showCancel) ...[
                        _TvDialogButton(
                          label: '取消',
                          onSelect: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 20 * TvTheme.designScale),
                      ],
                      if (showAction)
                        _TvDialogButton(
                          autofocus: true,
                          label: actionLabel,
                          onSelect: () => _closeAndRun(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TvDialogButton extends StatelessWidget {
  const _TvDialogButton({
    required this.label,
    required this.onSelect,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback onSelect;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      borderRadius: TvTheme.tabRadius,
      focusScale: TvTheme.focusScaleSmall,
      dimWhenUnfocused: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: TvTheme.buttonFocusFill,
          borderRadius: TvTheme.tabRadius,
        ),
        child: Padding(
          padding: TvTheme.buttonPadding,
          child: Text(label, style: TvTheme.buttonLabel),
        ),
      ),
    );
  }
}
