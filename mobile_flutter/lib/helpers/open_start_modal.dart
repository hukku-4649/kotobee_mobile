import 'package:flutter/material.dart';

import '../locator/service_locator.dart';
import '../exceptions/auth_exception.dart';

import '../widgets/start_modal.dart';
import '../widgets/kana_settings_modal.dart';

import '../models/stage_type.dart';

import '../screens/webview/grammar_game.dart';
import '../screens/webview/vocabulary_game.dart';
import '../screens/webview/kana_game.dart';

Future<void> openStartModal({
  required BuildContext context,
  required StageMapType type,
  required int stageId,

  required void Function(bool isLoading) setLoading,
  required void Function(String? errorMessage) setError,
  required String Function(int stageId) labelOfStageId,
  required Future<void> Function() reloadStages,

  // ✅ 必須のままだと他呼び出しが大変なので optional 推奨
  void Function(bool isOpen)? setStartModalOpen,
}) async {
  final notifyOpen = setStartModalOpen ?? (_) {};

  notifyOpen(true);
  setError(null);

  int currentStageId = stageId;

  try {
    while (true) {
      setLoading(true);

      late final dynamic data;
      try {
        if (type == StageMapType.grammar) {
          data = await ServiceLocator.grammarGameService.start_page(currentStageId);
        } else if (type == StageMapType.vocabulary) {
          data = await ServiceLocator.vocabularyGameService.start_page(currentStageId);
        } else if (type == StageMapType.kana) {
          data = await ServiceLocator.kanaGameService.start_page(currentStageId);
        } else {
          throw Exception('Unsupported StageMapType: $type');
        }
      } finally {
        setLoading(false);
      }

      final parentContext = context;

      // ✅ Settingsで変更されたら newStageId を返す（= pop(newStageId)）
      final int? nextStageId = await showDialog<int>(
        context: parentContext,
        barrierDismissible: true,
        builder: (dialogContext) {
          return StartModal(
            data: data,
            showSettings: type == StageMapType.kana,

            onOpenSettings: type == StageMapType.kana
                ? () async {
                    final result = await showDialog<KanaSettingsResult>(
                      context: dialogContext,
                      barrierDismissible: true,
                      builder: (_) => KanaSettingsModal(initialStageId: currentStageId),
                    );

                    if (result == null) return;

                    final newStageId = result.stageId;
                    if (newStageId == currentStageId) return;

                    // ✅ ここが重要：openStartModalを呼ばない
                    // StartModalを閉じて newStageId を返すだけ
                    Navigator.of(dialogContext).pop(newStageId);
                  }
                : null,

            onStart: () async {
              // StartModalを閉じる（Settingsではなく開始）
              Navigator.of(dialogContext).pop(null);

              try {
                final ticket =
                    await ServiceLocator.webViewTicketService.issueWebViewTicket();

                final typeParam = _typeParam(type);

                final url =
                    '${ServiceLocator.baseUrl}/mobile/enter'
                    '?ticket=$ticket&stage_id=$currentStageId&type=$typeParam';

                await Navigator.of(parentContext).push(
                  MaterialPageRoute(
                    builder: (_) {
                      if (type == StageMapType.grammar) {
                        return GrammarGamePage(
                          initialUrl: url,
                          title: labelOfStageId(currentStageId),
                        );
                      } else if (type == StageMapType.vocabulary) {
                        return VocabularyGamePage(
                          initialUrl: url,
                          title: labelOfStageId(currentStageId),
                        );
                      } else if (type == StageMapType.kana) {
                        return KanaGamePage(
                          initialUrl: url,
                          title: currentStageId.toString(),
                        );
                      } else {
                        throw Exception('Unsupported StageMapType: $type');
                      }
                    },
                  ),
                );

                await reloadStages();
              } catch (e) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text('開始に失敗しました: $e')),
                );
              }
            },
          );
        },
      );

      // nextStageId が null → Back/外タップ/Start → 終了
      if (nextStageId == null) break;

      // ✅ Settings変更 → ここで Home は既にローディング表示のまま
      // 次の周回で data を取り直して StartModal を再表示
      currentStageId = nextStageId;
    }
  } on AuthException catch (e) {
    setError(e.message);
  } catch (e) {
    setError('予期しないエラー: $e');
  } finally {
    notifyOpen(false);
  }
}

String _typeParam(StageMapType t) {
  switch (t) {
    case StageMapType.grammar:
      return 'grammar';
    case StageMapType.vocabulary:
      return 'vocabulary';
    case StageMapType.kana:
      return 'kana';
  }
}
