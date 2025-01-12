import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/account/account_preferences.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/game_controller.dart';
import 'package:lichess_mobile/src/model/game/game_preferences.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/platform.dart';
import 'package:lichess_mobile/src/widgets/settings.dart';

import 'game_screen_providers.dart';

class GameSettings extends ConsumerWidget {
  const GameSettings({required this.id, super.key});

  final GameFullId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSoundEnabled = ref.watch(
      generalPreferencesProvider.select(
        (prefs) => prefs.isSoundEnabled,
      ),
    );
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final gamePrefs = ref.watch(gamePreferencesProvider);
    final userPrefsAsync = ref.watch(userGamePrefsProvider(id));

    final content = ListView(
      shrinkWrap: true,
      children: [
        SwitchSettingTile(
          title: Text(context.l10n.sound),
          value: isSoundEnabled,
          onChanged: (value) {
            ref.read(generalPreferencesProvider.notifier).toggleSoundEnabled();
          },
        ),
        SwitchSettingTile(
          title: const Text('Haptic feedback'),
          value: boardPrefs.hapticFeedback,
          onChanged: (value) {
            ref.read(boardPreferencesProvider.notifier).toggleHapticFeedback();
          },
        ),
        SwitchSettingTile(
          title: Text(
            context.l10n.preferencesPieceAnimation,
          ),
          value: boardPrefs.pieceAnimation,
          onChanged: (value) {
            ref.read(boardPreferencesProvider.notifier).togglePieceAnimation();
          },
        ),
        SwitchSettingTile(
          title: Text(
            context.l10n.toggleTheChat,
          ),
          value: gamePrefs.enableChat ?? false,
          onChanged: (value) {
            ref.read(gamePreferencesProvider.notifier).toggleChat();
            ref.read(gameControllerProvider(id).notifier).onToggleChat(value);
          },
        ),
        ...userPrefsAsync.maybeWhen(
          data: (data) {
            return [
              if (data.prefs?.submitMove == true)
                SwitchSettingTile(
                  title: Text(
                    context.l10n.preferencesMoveConfirmation,
                  ),
                  value: data.shouldConfirmMove,
                  onChanged: (value) {
                    ref
                        .read(gameControllerProvider(id).notifier)
                        .toggleMoveConfirmation();
                  },
                ),
              if (data.prefs?.zenMode == Zen.gameAuto)
                SwitchSettingTile(
                  title: Text(
                    context.l10n.preferencesZenMode,
                  ),
                  value: data.isZenModeEnabled,
                  onChanged: (value) {
                    ref
                        .read(gameControllerProvider(id).notifier)
                        .toggleZenMode();
                  },
                ),
            ];
          },
          orElse: () => [],
        ),
        const SizedBox(height: 16.0),
      ],
    );

    return PlatformWidget(
      iosBuilder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(context.l10n.settingsSettings),
          ),
          child: content,
        );
      },
      androidBuilder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.settingsSettings),
          ),
          body: content,
        );
      },
    );
  }
}
