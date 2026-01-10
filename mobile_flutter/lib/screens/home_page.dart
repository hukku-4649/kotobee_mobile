import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../screens/login_page.dart';
import '../screens/select_stages.dart';

import '../widgets/common_app_bar.dart';

import '../models/stage_type.dart';

import '../services/auth_service.dart';

import '../locator/service_locator.dart';

import '../exceptions/auth_exception.dart';

import '../helpers/open_start_modal.dart';


class HomePage extends StatefulWidget {

  // コンストラクタ
  const HomePage({super.key});

  // createState()をoverrideして_HomePageStateを入れる
  @override
  State<HomePage> createState() => _HomePageState();
}

// HomePage専用のStateクラス
class _HomePageState extends State<HomePage> {

  // api通信中かどうかのflag
  bool _loading = false;

  // kanaのstartmodalを開いているかフラグ(六角形を削除するため)
  bool _showStartModal = false;

  // ローディング開始関数
  void _startLoading() {
    if (mounted) setState(() => _loading = true);
  }

  // ローディング終了関数
  void _endLoading() {
    if (mounted) setState(() => _loading = false);
  }

  // エラーメッセージ(なければnull)
  String? _error;

  Future<void> _reloadKanaStartModal() async {
    // ここで start_page を叩き直すだけでOK
    // 返り値をHomePageで使わないなら捨ててOK
    await ServiceLocator.kanaGameService.start_page(1);

    // もし HomePage で何か表示に使うなら setState で保存する
    // setState(() => _kanaStartData = data);
  }

  @override
  Widget build(BuildContext context) {
    
    const hexSize = 250.0;    
    final double strokeWidth = 10.0;

    return Scaffold(
      
      backgroundColor: const Color(0xFFF7F5C9),         

      appBar: CommonAppBar(
        title: 'Group 1',
        loading: _loading,
        onStartLoading: _startLoading,
        onEndLoading: _endLoading,
      ),     
      
      body: LayoutBuilder(
        
        builder: (context, constraints) {
          
          // Stack の中心座標（画面中央）
          final cx = constraints.maxWidth / 2;
          final cy = constraints.maxHeight / 2;

          // あなたの HexButton と同じ高さ計算
          final hexH = hexSize * 0.866;
          final radius = hexH;
          
          // 各値
          final labels = ['VOCABULARY', 'KANA', '', '', 'GRAMMAR', '', ''];          
          final degs = <double>[0, 90, 30, -30, -90, -150, 150];
          final enables = [true, true, false, false, true, false, false];
          
          final items = List<_HexItem>.generate(labels.length, (i) {
            final deg = degs[i];
            final isEnabled = enables[i];
            final label = labels[i];
            
            final r = deg == 0 ? -(strokeWidth / 2) : radius;
            
            return _HexItem.fromPolar(
              label: label,
              radius: r,
              deg: deg,
              enabled: isEnabled,
              strokeWidth: strokeWidth,
              onTap: isEnabled
                ? () async {
                  if (label == 'VOCABULARY') {

                    final type = StageMapType.vocabulary;

                    // print('tap label=$label -> type=$type (go StageMapScreen)');

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StageMapScreen(type: type),
                      ),
                    );

                  } else if (label == 'GRAMMAR') {

                    final type = StageMapType.grammar;

                    // print('tap label=$label -> type=$type (go StageMapScreen)');

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StageMapScreen(type: type),
                      ),
                    );

                  } else if (label == 'KANA') {

                    if (_showStartModal) return; 

                    await openStartModal(
                      context: context,
                      type: StageMapType.kana,
                      stageId: 1,
                      setLoading: (v) { if (!mounted) return; setState(() => _loading = v); },
                      setError: (msg) { if (!mounted) return; setState(() => _error = msg); },
                      labelOfStageId: (_) => '',
                      reloadStages: _reloadKanaStartModal,
                      setStartModalOpen: (isOpen) {
                        if (!mounted) return;
                        setState(() => _showStartModal = isOpen);
                      },
                    );

                  } 

                }
                : null,
            );
          });

          return Stack(
            
            children: [
              if (!_showStartModal)
                for (final item in items)
                  Positioned(
                    
                    left: cx - hexSize / 2 + item.dx,
                    top: cy - hexH / 2 - item.dy,
                    
                    
                    
                    child: HexButton(
                      label: item.label,
                      size: hexSize,
                      fill: Color(0xFFF2BA4B),
                      border: Color(0xFFB27A3A),
                      enabled: item.enabled,
                      onTap: item.onTap,
                      strokeWidth: strokeWidth,
                    ),
                    
                  ),
              if (_showStartModal)
                const Center(
                  child: CircularProgressIndicator(),
                ),            
            ],
            
          );
        },
      ),
    );
  }

}


// 各六角形の値を作成
class _HexItem {
  final String label;
  final double dx;
  final double dy;
  final bool enabled;
  final double strokeWidth;
  final VoidCallback? onTap;

  const _HexItem({
    required this.label,
    required this.dx,
    required this.dy,
    required this.enabled,
    required this.strokeWidth,
    this.onTap,
  });


  factory _HexItem.fromPolar({
    required String label,
    required double radius,
    required double deg,
    required bool enabled,
    required double strokeWidth,
    VoidCallback? onTap,
  }) {
    final rad = deg * math.pi / 180.0;
    
    final dx = (radius + (strokeWidth / 2)) * math.cos(rad);
    final dy = (radius + (strokeWidth / 2)) * math.sin(rad);
    
    return _HexItem(
      label: label,
      dx: dx,
      dy: dy,
      enabled: enabled,
      strokeWidth: strokeWidth,
      onTap: onTap,
    );
    
  }
  
}

// 六角形のボタンを作成
class HexButton extends StatelessWidget {
  final String label;
  final double size;
  final Color fill;
  final Color border;
  final VoidCallback? onTap;
  final double strokeWidth;
  final bool enabled;

  const HexButton({
    super.key,
    required this.label,
    required this.size,
    required this.fill,
    required this.border,
    required this.onTap,
    required this.strokeWidth,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = size * 0.866;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.75,
        child: SizedBox(
          width: size,
          height: height,
          child: CustomPaint(
            painter: _HexBorderPainter(
              color: border,
              strokeWidth: strokeWidth,
            ),
            child: ClipPath(
              clipper: _HexClipper(),
              child: Container(
                color: fill,
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 六角形の枠線を作成
class _HexBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HexBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _HexClipper().getClip(size);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HexBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// 六角形を作成
class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;

    return Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.25, h)
      ..lineTo(0, h * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
