import 'package:flutter/material.dart';

class KanaSettingsResult {
  final int stageId;
  const KanaSettingsResult(this.stageId);
}

enum KanaGameMode { count60s, timeAttack }
enum KanaScript { hiragana, katakana }
enum KanaCharType { seion, dakuon, youon }

class KanaSettingsModal extends StatefulWidget {
  final int initialStageId;

  const KanaSettingsModal({
    super.key,
    required this.initialStageId,
  });

  @override
  State<KanaSettingsModal> createState() => _KanaSettingsModalState();

  // ===== stageId <-> settings mapping =====

  static int toStageId({
    required KanaGameMode mode,
    required KanaScript script,
    required KanaCharType type,
  }) {
    final modeOffset = mode == KanaGameMode.timeAttack ? 6 : 0; // 1-6, 7-12
    final scriptOffset = script == KanaScript.katakana ? 3 : 0; // +3
    final typeOffset = switch (type) {
      KanaCharType.seion => 0,
      KanaCharType.dakuon => 1,
      KanaCharType.youon => 2,
    };
    return 1 + modeOffset + scriptOffset + typeOffset;
  }

  static ({
    KanaGameMode mode,
    KanaScript script,
    KanaCharType type
  }) fromStageId(int stageId) {
    final s = stageId.clamp(1, 12);

    final mode = s >= 7 ? KanaGameMode.timeAttack : KanaGameMode.count60s;

    final inMode = (mode == KanaGameMode.timeAttack) ? (s - 6) : s; // 1..6
    final script = inMode >= 4 ? KanaScript.katakana : KanaScript.hiragana;

    final inScript = (script == KanaScript.katakana) ? (inMode - 3) : inMode; // 1..3
    final type = switch (inScript) {
      1 => KanaCharType.seion,
      2 => KanaCharType.dakuon,
      _ => KanaCharType.youon,
    };

    return (mode: mode, script: script, type: type);
  }
}

class _KanaSettingsModalState extends State<KanaSettingsModal> {
  // ===== Colors (StartModal と雰囲気合わせ) =====
  static const outerBorder = Color(0xFFB07B2F);
  static const card = Color(0xFFF2B44C);
  static const textDark = Color(0xFF5A3C18);
  static const line = Color(0xFF9A6A2B);

  // 選択/未選択
  static const selectedFill = Color(0xFFB7873B); // 濃い
  static const unselectedFill = Color(0xFFF6C46A); // 薄い（cardより少し明るく）
  static const unselectedBorder = Color(0xFFB07B2F);

  late KanaGameMode _mode;
  late KanaScript _script;
  late KanaCharType _type;

  @override
  void initState() {
    super.initState();
    final decoded = KanaSettingsModal.fromStageId(widget.initialStageId);
    _mode = decoded.mode;
    _script = decoded.script;
    _type = decoded.type;
  }

  int get _stageId => KanaSettingsModal.toStageId(mode: _mode, script: _script, type: _type);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: outerBorder,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Colors.black26,
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: DefaultTextStyle(
            style: const TextStyle(color: textDark),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Setting',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _divider(line),
                const SizedBox(height: 18),

                _sectionTitle('Game mode'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _choiceButton(
                        label: '60s_count',
                        selected: _mode == KanaGameMode.count60s,
                        onTap: () => setState(() => _mode = KanaGameMode.count60s),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _choiceButton(
                        label: 'time_attack',
                        selected: _mode == KanaGameMode.timeAttack,
                        onTap: () => setState(() => _mode = KanaGameMode.timeAttack),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle('Display Characters'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _choiceButton(
                        label: 'Hiragana',
                        selected: _script == KanaScript.hiragana,
                        onTap: () => setState(() => _script = KanaScript.hiragana),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _choiceButton(
                        label: 'Katakana',
                        selected: _script == KanaScript.katakana,
                        onTap: () => setState(() => _script = KanaScript.katakana),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle('Character Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _choiceButton(
                        label: 'Seion',
                        selected: _type == KanaCharType.seion,
                        onTap: () => setState(() => _type = KanaCharType.seion),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _choiceButton(
                        label: 'Dakuon',
                        selected: _type == KanaCharType.dakuon,
                        onTap: () => setState(() => _type = KanaCharType.dakuon),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _choiceButton(
                        label: 'Youon',
                        selected: _type == KanaCharType.youon,
                        onTap: () => setState(() => _type = KanaCharType.youon),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _divider(line),
                const SizedBox(height: 16),

                // Back: 選択した stageId を返す（StartModalを再ロードするため）
                _bigButton(
                  label: 'Back',
                  onTap: () => Navigator.of(context).pop(KanaSettingsResult(_stageId)),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(Color c) {
    return Container(
      height: 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.withOpacity(0.75),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
    );
  }

  Widget _choiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 64,
      child: Material(
        color: selected ? selectedFill : unselectedFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.transparent : unselectedBorder.withOpacity(0.9),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bigButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: unselectedFill,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: unselectedBorder.withOpacity(0.9), width: 4),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
