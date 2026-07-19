// ============================================================
// features/super_tree_field/presentation/widgets/shortcuts_help.dart
// ------------------------------------------------------------
// The keyboard-shortcuts cheatsheet dialog (opened with `?` or the keyboard
// icon). Mirrors the React `<ShortcutsHelp>` modal. Show it with
// `showShortcutsHelp(context)`.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';

const List<(String, String)> _shortcuts = [
  ('↑  ↓', 'Move between rows'),
  ('←  →', 'Collapse / step out · expand / step in'),
  ('Home  End', 'Jump to first / last row'),
  ('Enter  Space', 'Open a leaf · toggle a group'),
  ('Space', 'Toggle the checkbox (in selection mode)'),
  ('/', 'Focus the search field'),
  ('Esc', 'Clear the search'),
  ('*  \\', 'Expand all · collapse all'),
  ('Right-click', 'Open the node menu'),
  ('?', 'This cheatsheet'),
];

/// Opens the keyboard cheatsheet as a centered dialog.
Future<void> showShortcutsHelp(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x73000000),
  builder: (_) => const _ShortcutsDialog(),
);

class _ShortcutsDialog extends StatelessWidget {
  const _ShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(SuperThemeData.of(context).tokens.space6),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(
                SuperThemeData.of(context).tokens.radiusCard,
              ),
              border: Border.all(color: t.borderStrong),
              boxShadow: SuperThemeData.popShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.keyboard_command_key,
                      size: 17,
                      color: SuperMaterialThemeData.of(
                        context,
                      ).colorScheme.primary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Keyboard shortcuts',
                        style: SuperText.heading.copyWith(color: t.fg1),
                      ),
                    ),
                    SuperIconButton(
                      icon: Icons.close,
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: SuperThemeData.of(context).tokens.space3),
                for (final (k, d) in _shortcuts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            k,
                            style: SuperText.mono.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: t.fg2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SuperThemeData.of(context).tokens.space3,
                        ),
                        Expanded(
                          child: Text(
                            d,
                            style: SuperText.body.copyWith(
                              fontSize: 13,
                              color: t.fg3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
