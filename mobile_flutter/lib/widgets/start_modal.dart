import 'package:flutter/material.dart';

class StartModal extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onStart;

  final bool showSettings;
  final VoidCallback? onOpenSettings;

  const StartModal({
    super.key,
    required this.data,
    required this.onStart,
    this.showSettings = false,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString();
    final desc = data['description']?.toString();
    final unit = data['unit']?.toString();

    final isKanaGame = showSettings; // openStartModal 側で kana の時だけ true にする想定

    final bestValue = data['best_value'];
    final top3 = (data['top3'] as List? ?? const []).cast<dynamic>();

    String fmtNum(dynamic v) {

      if (v == null) return '-';

      double? n;
      if (v is num) {
        n = v.toDouble();
      } else if (v is String) {
        n = double.tryParse(v);
      } else {
        return '-';
      }

      if (n == null) return '-';

      final s = n.toStringAsFixed(2);
      return s.replaceFirst(RegExp(r'\.?0+$'), '');

    }

    // ===== Colors (画像の雰囲気寄せ) =====
    const outerBorder = Color(0xFFB07B2F);
    const card = Color(0xFFF2B44C);
    const textDark = Color(0xFF5A3C18);
    const line = Color(0xFF9A6A2B);
    const button = Color(0xFFB7873B);
    const winnerName = Color(0xFFE04B5D);

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

        // modalの枠線の太さ
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

                // ゲーム名表示 + 右端に設定(歯車)ボタン（Kana Gameのみ）
                Row(

                  children: [
                    const SizedBox(width: 48),

                    Expanded(
                      child: Text(
                        title ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (isKanaGame)
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings),
                        iconSize: 28,
                        color: textDark,
                        onPressed: onOpenSettings,
                      )
                      
                    else
                      const SizedBox(width: 48),
                  ],
                ),





                const SizedBox(height: 14),

                // 下線
                _divider(line),

                const SizedBox(height: 18),
                
                // テキスト表示
                Text(
                  desc ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 18),

                // top3テキスト表示                
                const Text(
                  'Top 3 Players',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                // top3表示
                if (top3.isEmpty) // top3が存在しない場合
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'No records yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  )
                else // top3が存在する場合
                  Column(
                    children: List.generate(

                      top3.length.clamp(0, 3),

                      (i) {
                        final r = top3[i] as Map;
                        final name = r['name']?.toString() ?? '';
                        final v = fmtNum(r['best_value']);

                        final isFirst = i == 0;

                        return Padding(
                          padding: EdgeInsets.only(bottom: i == 2 ? 0 : 12),
                          child: _rankRow(
                            medalColor: isFirst ? const Color(0xFFD9A63A) : Colors.white,
                            iconColor: isFirst ? const Color(0xFFD9A63A) : const Color(0xFFB0B0B0),
                            name: name,
                            nameColor: isFirst ? winnerName : textDark,
                            timeText: v.isEmpty ? '' : '$v $unit',
                          ),
                        );

                        // final r = top3[i] as Map<String, dynamic>;

                        // // user.name を読む
                        // final user = r['user'] as Map<String, dynamic>?;
                        // final name = user?['name']?.toString() ?? '';

                        // final v = fmtNum(r['best_value']);
                        // final isFirst = i == 0;

                        // return Padding(
                        //   padding: EdgeInsets.only(bottom: i == 2 ? 0 : 12),
                        //   child: _rankRow(
                        //     medalColor: isFirst ? const Color(0xFFD9A63A) : Colors.white,
                        //     iconColor: isFirst ? const Color(0xFFD9A63A) : const Color(0xFFB0B0B0),
                        //     name: name,
                        //     nameColor: isFirst ? winnerName : textDark,
                        //     timeText: v.isEmpty ? '' : '$v $unit',
                        //   ),
                        // );

                      },

                    ),
                  ),

                                              
                const SizedBox(height: 18),

                // 下線
                _divider(line),

                const SizedBox(height: 14),

                // 今回のスコア表示                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 54), // 左のメダル分の余白
                    const Expanded(
                      child: Text(
                        'You',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      bestValue == null ? 'Not played yet' : '${fmtNum(bestValue)} $unit',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // 下のボタン表示
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundedButton(
                      label: 'Back',
                      color: button,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 28),
                    _roundedButton(
                      label: 'Start',
                      color: button,
                      onTap: onStart,
                    ),
                  ],
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

  // top3表示
  Widget _rankRow({
    required Color medalColor,
    required Color iconColor,
    required String name,
    required Color nameColor,
    required String timeText,
  }) {
    return Row(
      children: [

        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events,
              color: iconColor == medalColor ? Colors.white : iconColor,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: nameColor,
            ),
          ),
        ),

        Text(
          timeText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ボタン作成用関数
  Widget _roundedButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {

    return SizedBox(
      width: 90,
      height: 40,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

  }
}
