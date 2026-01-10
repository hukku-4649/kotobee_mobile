import 'package:flutter/material.dart';

class GrammarResultModal extends StatelessWidget {
  final double score;
  final double? bestTime;
  final int? rank;
  final List<dynamic> top3;
  final String unit;

  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const GrammarResultModal({
    super.key,
    required this.score,
    required this.bestTime,
    required this.rank,
    required this.top3,
    this.unit = 'sec',
    this.onRetry,
    this.onBack,
  });

  // ===== util =====
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

  String _nameOf(dynamic r) {
    if (r is Map) {
      final direct = r['name'];
      if (direct != null) return direct.toString();

      final user = r['user'];
      if (user is Map && user['name'] != null) return user['name'].toString();
    }
    return 'NoName';
  }

  dynamic _timeOf(dynamic r) {
    if (r is Map) {
      final v =
        r['best_time'] ??
        r['best_value'] ??
        r['play_time'] ??
        r['value'];

      if (v is num) return v;
      if (v is String) return double.tryParse(v);
    }
    return null;
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final top3List = (top3 as List).cast<dynamic>();

    const cardBg = Color(0xFFF2B84B);
    const border = Color(0xFFB07B2E);
    const divider = Color(0xFFC99244);
    const textDark = Color(0xFF3A2A14);
    const buttonBg = Color(0xFF9A6B2B);

    return Dialog(

      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),

      child: Container(

        width: 360,

        padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),

        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 8),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 8),
              color: Color(0x33000000),
            ),
          ],
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            // Reuslt表示
            Text(
              'Result',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),

            const SizedBox(height: 18),

            // 今回のスコア
            _scoreLine('今回のスコア', '${fmtNum(score)} $unit', textDark),

            const SizedBox(height: 10),

            // あなたのベスト
            _scoreLine(
              'あなたのベスト',
              bestTime == null ? '-' : '${fmtNum(bestTime)} $unit',
              textDark,
            ),

            const SizedBox(height: 10),

            // あなたの順位
            _scoreLine(
              'あなたの順位',
              rank?.toString() ?? '-',
              textDark,
            ),

            const SizedBox(height: 18),

            // 横線
            Container(height: 2, color: divider.withOpacity(0.75)),

            const SizedBox(height: 16),

            // Top3のタイトル表示
            Text(
              'Top 3',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),

            const SizedBox(height: 12),

            // top3の内容表示
            if (top3List.isEmpty)
              Text(
                'No records yet',
                style: TextStyle(color: textDark),
              )
            else
              Column(

                children: List.generate(top3List.length, (i) {
                  final r = top3List[i];
                  final name = _nameOf(r);
                  final t = _timeOf(r);

                  return Padding(

                    padding: const EdgeInsets.symmetric(vertical: 6),

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        // 左側のtrophy
                        if (i == 0)
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: border,
                              size: 22,
                            ),
                          )
                        else                          
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: border,
                              size: 22,
                            ),
                          ),


                        
                        const SizedBox(width: 12),

                        // 右側の名前と記録
                        Text(
                          '$name：${fmtNum(t)} $unit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),

                      ],

                    ),
                  );
                }),
              ),

            const SizedBox(height: 22),

            // ボタン出力
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                _actionButton(
                  label: 'Back',
                  background: buttonBg,
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                ),

                const SizedBox(width: 16),

                _actionButton(
                  label: 'Again',
                  background: buttonBg,
                  onPressed: onRetry,
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  // modal上部のスコアformat
  Widget _scoreLine(String label, String value, Color textColor) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],

    );

  }

  // ボタンサイズ
  Widget _actionButton({
    required String label,
    required Color background,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 90,
      height: 40,
      child: ElevatedButton(

        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        child: Text(label),

      ),
    );
  }

}

