
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'dart:math';
import 'dart:convert';

import '../screens/home_page.dart';
import '../screens/login_page.dart';

import '../widgets/start_modal.dart';
import '../widgets/common_app_bar.dart';

import '../models/stage_type.dart';

import '../locator/service_locator.dart';
import '../exceptions/auth_exception.dart';

import '../helpers/open_start_modal.dart';

import 'webview/grammar_game.dart';
import 'webview/vocabulary_game.dart';



///// SVG PATHs /////
const String kHexOuterPathD =
    "M90.6973 33.5427C94.0734 39.3867 94.1801 46.5455 91.018 52.4733L90.7027 53.0427L77.2561 76.3473C73.7745 82.3815 67.3378 86.101 60.3711 86.103L33.4649 86.1105C26.4983 86.1124 20.0595 82.3965 16.5745 76.3642L3.11483 53.0672C-0.26126 47.2233 -0.368008 40.0644 2.79412 34.1366L3.10939 33.5672L16.556 10.2627C20.0376 4.22842 26.4743 0.509948 33.441 0.507956L60.3472 0.500441C67.3138 0.498542 73.7526 4.21257 77.2376 10.2447L90.6973 33.5427Z";
const String kHexInnerPathD =
    "M22.5806 52.5984C21.6096 51.0022 21.6096 48.9978 22.5806 47.4016L34.2892 28.1529C35.1963 26.6616 36.8155 25.7513 38.561 25.7513H62.439C64.1845 25.7513 65.8037 26.6616 66.7108 28.1529L78.4194 47.4016C79.3904 48.9978 79.3904 51.0022 78.4194 52.5984L66.7108 71.8471C65.8037 73.3384 64.1845 74.2487 62.439 74.2487H38.561C36.8155 74.2487 35.1963 73.3384 34.2892 71.8471L22.5806 52.5984Z";
const String kHexGroupFramePathD = 
    "M250.642 32.7646L268.663 7.73543C271.482 3.82035 276.012 1.5 280.836 1.5H325.867C330.467 1.5 334.813 3.61049 337.657 7.22574L358.148 33.2743C360.992 36.8895 365.338 39 369.937 39H408.097C413.127 39 417.823 41.5218 420.601 45.7156L438.203 72.2844C440.982 76.4782 445.677 79 450.708 79H478.097C483.127 79 487.823 76.4782 490.601 72.2844L508.203 45.7156C510.982 41.5218 515.677 39 520.708 39H569.582C574.621 39 579.323 41.5296 582.099 45.7341L608.205 85.2659C610.982 89.4704 615.684 92 620.722 92H651.018C656.092 92 660.822 94.5647 663.59 98.8168L688.662 137.334C691.727 142.042 691.904 148.067 689.122 152.946L667.947 190.09C665.028 195.21 665.378 201.564 668.841 206.333L687.69 232.29C691.292 237.249 691.514 243.901 688.251 249.089L668.345 280.743C665.188 285.763 665.285 292.173 668.594 297.096L679.794 313.759C682.242 317.402 686.163 319.79 690.524 320.293L728.666 324.694C733.092 325.205 737.063 327.657 739.501 331.386L764.5 369.62C767.65 374.438 767.765 380.634 764.795 385.566L746.959 415.188C743.761 420.498 744.159 427.229 747.961 432.125L768.963 459.173C772.449 463.663 773.098 469.738 770.638 474.863L748.737 520.491C746.24 525.692 740.983 529 735.214 529H691.928C686.777 529 681.986 531.643 679.239 536L659.066 568C656.319 572.357 651.528 575 646.377 575H609.75C604.425 575 599.498 577.824 596.807 582.419L585.641 601.482C582.614 606.651 582.952 613.126 586.502 617.952L606.51 645.151C610.207 650.175 610.408 656.963 607.015 662.198L582.087 700.658C579.321 704.925 574.583 707.5 569.499 707.5H532.309C526.952 707.5 522.002 710.357 519.321 714.996L501.983 745.004C499.303 749.643 494.353 752.5 488.995 752.5H440.18C435.165 752.5 430.481 749.993 427.699 745.82L406.605 714.18C403.823 710.007 399.14 707.5 394.125 707.5H359.145C353.876 707.5 348.994 704.736 346.283 700.217L326.522 667.283C323.811 662.764 318.928 660 313.659 660H292.145C286.876 660 281.994 662.764 279.283 667.283L259.522 700.217C256.811 704.736 251.928 707.5 246.659 707.5H203.994C198.807 707.5 193.988 704.82 191.251 700.414L170.553 667.086C167.817 662.68 162.998 660 157.811 660H117.235C111.652 660 106.531 656.899 103.943 651.951L83.4887 612.836C81.1009 608.27 81.224 602.798 83.8147 598.344L104.062 563.533C106.613 559.146 106.774 553.767 104.488 549.236L84.033 508.684C81.3682 503.402 82.058 497.046 85.7941 492.457L101.575 473.077C105.53 468.22 106.051 461.418 102.882 456.016L90.4994 434.91C87.8066 430.32 82.8832 427.5 77.5615 427.5H35.1897C29.3699 427.5 24.0753 424.134 21.6064 418.863L2.91656 378.968C0.867359 374.594 1.0501 369.5 3.40752 365.284L21.3162 333.255C23.99 328.473 23.844 322.614 20.9352 317.971L4.57639 291.86C1.55881 287.043 1.52271 280.935 4.48316 276.083L31.267 232.187C33.9907 227.723 38.8425 225 44.0716 225H78.7663C83.4234 225 87.8162 222.837 90.6557 219.146L116.649 185.354C119.488 181.663 123.881 179.5 128.538 179.5H157.617C162.909 179.5 167.809 176.712 170.512 172.162L183.077 151.017C185.343 147.203 185.805 142.581 184.338 138.394L168.921 94.4014C167.2 89.4904 168.148 84.0384 171.424 79.9957L200.15 44.555C202.998 41.0411 207.28 39 211.803 39H238.469C243.293 39 247.823 36.6796 250.642 32.7646Z";


///// Model /////
class HexNode {
  final int stageId;
  final String label;
  final Offset pos; // world pos (center-based)
  final bool isParent;
  final int? parentIndex; // child -> parent index (0..6)
  final bool isPlayed;

  const HexNode({
    required this.stageId,
    required this.label,
    required this.pos,
    required this.isParent,
    required this.parentIndex,
    required this.isPlayed,
  });
}

class ParentCenter {
  final Offset pos;
  final int stageId;
  const ParentCenter({required this.pos, required this.stageId});
}

///// Screen /////
class StageMapScreen extends StatefulWidget {

  final StageMapType type;

  //コンストラクタ
  const StageMapScreen({
    super.key,
    required this.type,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> with TickerProviderStateMixin {

  // JS params
  static const int count = 6;
  static const double gap = 20;

  static const double hexW = 100;
  static const double hexH = 86;
  static const double childR = hexH + gap;

  late final double wTheta = hexW / 2 + hexW / 4 + gap;
  late final double hTheta = 2 * hexH + hexH / 2 + 2 * gap + gap / 2;
  late final double bigR = sqrt(pow(wTheta, 2) + pow(hTheta, 2));
  late final double theta = acos(wTheta / bigR);
  late final double thetaDeg = 90 - (theta * (180 / pi));

  // world
  static const double worldSize = 1400;
  static const Offset worldOrigin = Offset(worldSize / 2, worldSize / 2);

  List<HexNode> nodes = [];
  List<ParentCenter> parentCenters = [];



  late int focusIndex = 0; // 画面中心となる親index
  Offset worldTranslate = Offset.zero; // 中止となる親indexの座標

  int get focusedParentStageId => parentCenters[focusIndex].stageId;

  // 移動アニメctrl
  late final AnimationController _ctrl;
  // 焦点アニメctrl
  late final AnimationController _focusFxCtrl;

  Animation<Offset>? _anim;

  // SVGデータ文字列に基づいた描写Path取得
  late final Path _hexOuterBasePath = _parseSvgPathData(kHexOuterPathD);
  late final Path _hexInnerBasePath = _parseSvgPathData(kHexInnerPathD);

  // SVGの大きさや位置から補正
  late final Rect _hexOuterBounds = _hexOuterBasePath.getBounds(); // should be around 94x87 viewbox
  late final Rect _hexInnerBounds = _hexInnerBasePath.getBounds();


  // api通信中かどうかのflag
  bool _loading = false;

  // ローディング開始関数
  void _startLoading() {
    if (mounted) setState(() => _loading = true);
  }

  // ローディング終了関数
  void _endLoading() {
    if (mounted) setState(() => _loading = false);
  }
  
  // エラー処理用
  String? _error;
  Set<int> _playedStageIds = {};
  List<dynamic> _stageUrls = [];

  // 初期設定
  @override
  void initState() {
    super.initState();    

    // 移動アニメ
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

    // 焦点アニメ
    _focusFxCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // ステージ選択のデータをapiで受信
    _loadStages();

  }  

  /*** dispose ***/
  @override
  void dispose() {
    _ctrl.dispose();
    _focusFxCtrl.dispose();
    super.dispose();
  }

  /*** build ***/

  @override
  Widget build(BuildContext context) {

    final infoText = 'Stage: ${focusIndex + 1}';

    // ロード中の見た目
    if (_loading) {
      return Scaffold(
        // 黄色背景
        backgroundColor: const Color(0xFFFFFFCE), 

        // navバー
        appBar: CommonAppBar(
          title: 'Group 1',
          loading: _loading,
          onStartLoading: _startLoading,
          onEndLoading: _endLoading,
        ),
  
        body: Center(child: CircularProgressIndicator()),        
      );
    }

    // エラー時
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }    

    // 通常時の見た目
    return Scaffold(

      // 黄色背景
      backgroundColor: const Color(0xFFFFFFCE),          

      // navバー
      appBar: CommonAppBar(
        title: 'Group 1',
        loading: _loading,
        onStartLoading: _startLoading,
        onEndLoading: _endLoading,
      ),

      body: SafeArea(

        bottom: false,

        child: Stack(

          children: [

            GestureDetector(

              // 当たり判定が全体
              behavior: HitTestBehavior.opaque,

              // スワイプによる画面遷移
              onHorizontalDragEnd: (details) {

                // スワイプの速度                
                final v = details.primaryVelocity ?? 0;                

                if (v > 0) {
                  _goPrev(); // 後ろに移動
                } else if (v < 0) {
                  _goNext(); // 前に移動
                }

              },


              // タップ処理(stage選択処理)
              onTapUp: (details) async {

                // タップ座標                
                final tap = details.localPosition;
                // タップ座標をワールド座標に変換
                final worldPoint = tap - worldTranslate;

                final hit = _hitTestNode(worldPoint);


                if (hit == null) return; 
                if (!_isInFocusedGroup(hit)) return; // フォーカス中のグループのみ
                if (!hit.isPlayed) return; // プレイしたゲームのみ

                final url = _stageUrlOf(hit.stageId);

                // print('${url}');

                // await _openStartModal(hit.stageId);

                await openStartModal(
                  context: context,
                  type: widget.type,
                  stageId: hit.stageId,

                  setLoading: (v) {
                    if (!mounted) return;
                    setState(() => _loading = v);
                  },
                  setError: (msg) {
                    if (!mounted) return;
                    setState(() => _error = msg);
                  },

                  labelOfStageId: _labelOfStageId,

                  reloadStages: _loadStages,

                  setStartModalOpen: (_) {},

                );

              },

              // ステージmap描画
              child: ClipRect(

                child: CustomPaint(

                  size: MediaQuery.of(context).size,

                  // 描画関数
                  painter: StageMapPainter(
                    nodes: nodes,
                    worldTranslate: worldTranslate,
                    worldOrigin: worldOrigin,
                    hexBasePath: _hexOuterBasePath,
                    hexOuterBounds: _hexOuterBounds,
                    hexInnerPath: _hexInnerBasePath,
                    hexInnerBounds: _hexInnerBounds,
                    isFocusedParent: _isFocusedParent,
                    focusFx: _focusFxCtrl,
                    focusIndex: focusIndex,  
                  ),

                ),

              ),

            ),

            // 画面左上の戻るボタン
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  // 左端の戻る矢印（背景なし）
                  Positioned(
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black, // ← 好きな色にできる
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // 中央の infoText（半透明背景あり）
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        infoText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // 画面左下の戻るボタン
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton(
                heroTag: 'prev',
                onPressed: _goPrev,
                child: const Icon(Icons.chevron_left),
              ),
            ),

            // 画面右下の戻るボタン
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'next',
                onPressed: _goNext,
                child: const Icon(Icons.chevron_right),
              ),
            ),

          ],

        ),

      ),

    );

  }

  /*** buildで使用する関数 ***/

  //// modal用のデータ取得かつ表示 ////
  // Future<void> _openStartModal(int stageId) async {

  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {

  //     late final dynamic data;

  //     // スタートmodalに必要な情報をapiで取得
  //     if (widget.type == StageMapType.grammar) {      
  //       data = await ServiceLocator.grammarGameService.start_page(stageId);              
  //     } else if (widget.type == StageMapType.vocabulary) {
  //       data = await ServiceLocator.vocabularyGameService.start_page(stageId);
  //     } else {
  //       throw Exception('Unsupported StageMapType: ${widget.type}');
  //     }
     
  //     if (!mounted) return;

  //     // 画面本体のcontexを保持
  //     final parentContext = context;
  //     await showDialog<void>(
  //       // 画面本体上にmodalを表示        
  //       context: parentContext,
  //       // 背景タップで閉じる
  //       barrierDismissible: true,
        
  //       // 表示するmodalのUI(widget)を決定
  //       builder: (dialogContext) { // dialogContextがmodalのcontext

  //         return StartModal(

  //           // modalに表示する情報
  //           data: data,

  //           // startボタンを押した時の処理
  //           onStart: () async {

  //             // modalを閉じる
  //             Navigator.of(dialogContext).pop();

  //             try {

  //               // ticketを取得                
  //               final ticket =
  //                   await ServiceLocator.grammarGameService.issueWebViewTicket();

  //               final type = _typeParam(widget.type);

  //               final url =
  //                   'https://willyard-lashaunda-conformable.ngrok-free.dev/mobile/enter'
  //                   '?ticket=$ticket&stage_id=$stageId&type=$type';

  //               if (!parentContext.mounted) return;

  //               // parentContextにpushして、webviewを開く
  //               await Navigator.of(parentContext).push(
  //                 MaterialPageRoute(

  //                   // builder: (_) => GrammarGamePage(
  //                   //   initialUrl: url,
  //                   //   title: _labelOfStageId(stageId),
  //                   // ),

  //                   builder: (_) {

  //                     if (widget.type == StageMapType.grammar) {
  //                       return GrammarGamePage(
  //                         initialUrl: url,
  //                         title: _labelOfStageId(stageId),
  //                       );
  //                     } else if (widget.type == StageMapType.vocabulary) {
  //                       return VocabularyGamePage(
  //                         initialUrl: url,
  //                         title: _labelOfStageId(stageId),
  //                       );
  //                     } else {
  //                       // 念の為
  //                       throw Exception('Unsupported StageMapType: ${widget.type}');                        
  //                     }

  //                   }

  //                 ),
  //               );

  //               if (!parentContext.mounted) return;

  //               // game終了時画面を更新              
  //               await _loadStages();
                                
  //             } catch (e) {

  //               if (!parentContext.mounted) return;

  //               // エラー処理
  //               ScaffoldMessenger.of(parentContext).showSnackBar(
  //                 SnackBar(content: Text('開始に失敗しました: $e')),
  //               );

  //             }
              
  //           },
  //         );

  //       },
  //     );
  //   } on AuthException catch (e) {
  //     if (!mounted) return;
  //     setState(() => _error = e.message);
  //   } on DioException catch (e) {
  //     if (!mounted) return;
  //     setState(() => _error = '通信エラー： ${e.response?.statusCode}');
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() => _error = '予期しないエラー: $e');
  //   } finally {
  //     if (mounted) setState(() => _loading = false);
  //   }    
  // }

  // String _typeParam(StageMapType t) {
  //   switch (t) {
  //     case StageMapType.grammar:
  //       return 'grammar';
  //     case StageMapType.vocabulary:
  //       return 'vocabulary';
  //     case StageMapType.kana:
  //       return 'kana';
  //   }
  // }

  //// select_stagesを開いた時に必要な値を取得 ////
  Future<void> _loadStages() async {

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      List<dynamic> stageUrls = [];
      Set<int> playedSet = {};

      if (widget.type == StageMapType.grammar) {        
        final data = await ServiceLocator.grammarGameService.stages(); // apiでgrammar_gameのデータを取得        
        stageUrls = data['stage_urls'] as List? ?? []; //　各ステージのurlを配列
        final played = data['played_stage_ids'] as List? ?? []; // 各ステージプレイ済みか 
        final playedList = played.map((e) => (e as num).toInt()).toList();

        // print('grammar${stageUrls}');

        if (playedList.isEmpty) { // 空の配列の場合1を付与する
          playedList.add(1);
        } else {
          playedList.add(playedList.last + 1);
        }
        playedSet = playedList.toSet(); // setにする
        _playedStageIds = playedSet;

      } else if (widget.type == StageMapType.vocabulary) {
        final data = await ServiceLocator.vocabularyGameService.stages();
        stageUrls = data['stage_urls'] as List? ?? [];
        final played = data['played_stage_ids'] as List? ?? [];
        final playedList = played.map((e) => (e as num).toInt()).toList();

        // print('vocaburary${stageUrls}');

        if (playedList.isEmpty) {
          playedList.add(1);
        } else {
          playedList.add(playedList.last + 1);
        }
        playedSet = playedList.toSet(); 
        _playedStageIds = playedSet;

      }

      // 全グループの六角形を作成し情報を付与
      final built = _buildWorld();

      // 全グループの六角形の情報(list)
      final newNodes = built.$1;

      // 各グループの親六角形の情報(list)
      final newCenters = built.$2;

      // プレイしたゲームidの最新を取得
      final maxValue = playedSet.isEmpty ? 0 : playedSet.reduce(max);

      // どのグループをフォーカスするか計算      
      final newFocusIndex = (maxValue / 7).floor().clamp(0, newCenters.length - 1);

      if (!mounted) return;

      // build更新
      setState(() {

        _stageUrls = stageUrls;

        nodes = newNodes;
        parentCenters = newCenters;
        focusIndex = newFocusIndex;
        _loading = false;
        
      });

      // フォーカス位置に移動
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToFocus(focusIndex));

    } on AuthException catch (e) { // 予期エラー    
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });

    } catch (e, st) { // 予期しないエラー

      if (!mounted) return;

      setState(() {
        _error = '予期しないエラーが発生しました: $e';
        _loading = false;
      });

    }

  }

  //// 全グループの六角形を作成 ////
  (List<HexNode>, List<ParentCenter>) _buildWorld() {

    // 全ての六角形を入れる
    final out = <HexNode>[];

    // それぞれの六角形のグループの中心のみを入れる
    final centers = <ParentCenter>[];

    int stageId = 1;

    // グループの中央を回す(stage1~6)
    for (int i = 0; i < count; i++) {

      final startAngle = -(90 + thetaDeg);
      final angle = (360 / count) * i + startAngle;
      final rad = angle * (pi / 180);
      final x = bigR * cos(rad);
      final y = bigR * sin(rad);

      final parentPos = Offset(x, y);

      out.add(HexNode(

        stageId: stageId,
        label: '${i + 1}-1',
        pos: parentPos,
        isParent: true,
        parentIndex: null,
        isPlayed: _playedStageIds.contains(stageId),

      ));

      centers.add(ParentCenter(pos: parentPos, stageId: stageId));

      stageId++;

      // 中央の周りを回す
      for (int j = 0; j < 6; j++) {
        final childAngle = (360 / 6) * j - 90;
        final childRad = childAngle * (pi / 180);
        final cx = x + childR * cos(childRad);
        final cy = y + childR * sin(childRad);

        out.add(HexNode(

          stageId: stageId,
          label: '${i + 1}-${j + 2}',
          pos: Offset(cx, cy),
          isParent: false,
          parentIndex: i,
          isPlayed: _playedStageIds.contains(stageId),

        ));

        stageId++;

      }

    }

    ///// 全グループの中央を処理(stage 7) /////
    final centerParentIndex = count;

    out.add(HexNode(

      stageId: stageId,
      label: '${count + 1}-1',
      pos: const Offset(0, 0),
      isParent: true,
      parentIndex: null,
      isPlayed: _playedStageIds.contains(stageId),

    ));

    centers.add(ParentCenter(pos: const Offset(0, 0), stageId: stageId));

    stageId++;

    for (int j = 0; j < 6; j++) {
      final childAngle = (360 / 6) * j - 90;
      final childRad = childAngle * (pi / 180);
      final cx = childR * cos(childRad);
      final cy = childR * sin(childRad);


      out.add(HexNode(

        stageId: stageId,
        label: '${count + 1}-${j + 2}',
        pos: Offset(cx, cy),
        isParent: false,
        parentIndex: centerParentIndex,
        isPlayed: _playedStageIds.contains(stageId),

      ));

      stageId++;

    }

    return (out, centers);

  }

  //// labelを取得する関数 ////
  String _labelOfStageId(int stageId) {
    // nodes は _loadStages() 後に埋まってる前提
    for (final n in nodes) {
      if (n.stageId == stageId) return n.label;
    }
    return 'Stage $stageId'; // 見つからない時の保険
  }

  //// 初期のフォーカス場所 ////
  void _jumpToFocus(int index) {    
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final focusPos = parentCenters[index].pos;

    // worldTranslateを代入しbuildを更新
    setState(() {
      worldTranslate = screenCenter - (worldOrigin + focusPos);
    });

  } 

  //// タップしたステージが存在するか ////
  HexNode? _hitTestNode(Offset worldPoint) {

    for (final n in nodes.reversed) {

      final center = worldOrigin + n.pos; //　ワールド座標
      final rectTopLeft = center - const Offset(hexW / 2, hexH / 2); // 描画のため左上に移動
      final hitPath = _transformHexPath(rectTopLeft); // 
      if (hitPath.contains(worldPoint)) return n;

    }

    return null;

  }

  //// 六角形バスの調整 ////
  Path _transformHexPath(Offset topLeft) {
    
    final sx = hexW / _hexOuterBounds.width;
    final sy = hexH / _hexOuterBounds.height;

    final m = Matrix4.identity()
      ..translate(topLeft.dx, topLeft.dy)
      ..scale(sx, sy)
      ..translate(-_hexOuterBounds.left, -_hexOuterBounds.top);

    return _hexOuterBasePath.transform(m.storage);
  }

  //// 次に移動 ////
  void _goNext() {
    final maxIndex = parentCenters.length - 1;

    setState(() => focusIndex = (focusIndex + 1) % (maxIndex + 1));

    _animateToFocus(focusIndex);
  }

  //// 前に移動 ////
  void _goPrev() {

    final maxIndex = parentCenters.length - 1;

    setState(() => focusIndex = (focusIndex - 1 + (maxIndex + 1)) % (maxIndex + 1));

    _animateToFocus(focusIndex);
  }

  //// 中心軸移動アニメーション ////
  void _animateToFocus(int index) {
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final focusPos = parentCenters[index].pos;
    final target = screenCenter - (worldOrigin + focusPos);

    // 現在のアニメーションを停止
    _ctrl.stop();

    // アニメーション作成
    _anim = Tween<Offset>(
      begin: worldTranslate, 
      end: target
    ).animate(
      CurvedAnimation(
        parent: _ctrl, 
        curve: Curves.easeOutCubic
      ),
    )
    ..addListener(() => setState(() => worldTranslate = _anim!.value));

    _ctrl.forward(from: 0);

  }

  //// urlを取り出す関数 ////
  String? _stageUrlOf(int stageId) {
    // if (stageId < 0 || stageId >= _stageUrls.length) return null;
    // final v = _stageUrls[stageId-1];
    // if (v == null) return null;
    // return v.toString();  

    final idx = stageId - 1;
    if (idx < 0 || idx >= _stageUrls.length) return null;
    final v = _stageUrls[idx];
    return v?.toString();  
  }

  //// フォーカス中の親か判定 ////
  bool _isFocusedParent(int parentStageId) {
    return parentCenters[focusIndex].stageId == parentStageId;
  }

  //// フォーカス中のグループか判定 ////
  bool _isInFocusedGroup(HexNode n) {
    final focusedId = focusedParentStageId;

    // フォーカス中の親そのもの
    if (n.isParent) return n.stageId == focusedId;

    // 子なら、その親indexが focusIndex と一致すればOK
    return n.parentIndex == focusIndex;
  } 

}


//// 画面を描画 ////
class StageMapPainter extends CustomPainter {
  // ノードリスト
  final List<HexNode> nodes;

  // 移動量(スクロール、ドラッグ用)
  final Offset worldTranslate;
  // 座標の原点(中心)
  final Offset worldOrigin;

  // SVG描写Path
  final Path hexBasePath;
  final Path hexInnerPath;

  // SVG補正情報
  final Rect hexOuterBounds;  
  final Rect hexInnerBounds;

  late final Path _groupFrameBasePath = _parseSvgPathData(kHexGroupFramePathD);
  late final Rect _groupFrameBounds = _groupFrameBasePath.getBounds();

  final Animation<double> focusFx;
  final int focusIndex;


  // フォーカス中かどうか
  final bool Function(int parentStageId) isFocusedParent;

  StageMapPainter({
    required this.nodes,
    required this.worldTranslate,
    required this.worldOrigin,
    required this.hexBasePath,
    required this.hexInnerPath,
    required this.hexOuterBounds,
    required this.hexInnerBounds,
    required this.isFocusedParent,
    required this.focusFx,
    required this.focusIndex,
  }) : super(repaint: focusFx);

  // 六角形のサイズ
  static const double hexW = _StageMapScreenState.hexW;
  static const double hexH = _StageMapScreenState.hexH;

  @override
  void paint(Canvas canvas, Size size) {

    // 並行移動を保存    
    canvas.save();
    canvas.translate(worldTranslate.dx, worldTranslate.dy);    
    
    _drawGroupFrame(canvas);
    
    // 六角形ノードを処理
    for (final n in nodes) {

      // 中心      
      final center = worldOrigin + n.pos;
      // Pathは左上基準なので移動
      final topLeft = center - const Offset(hexW / 2, hexH / 2);

      final outerPath = _transformPath(hexBasePath, hexOuterBounds, topLeft);
      final innerPath = _transformInnerPathSmaller(basePath: hexInnerPath, baseBounds: hexInnerBounds, topLeft: topLeft, shrink: 15);

      // 六角形の背景設定
      final fillPaint = Paint()
        ..color = n.isPlayed ? const Color(0xFFF09813) : Colors.grey
        ..style = PaintingStyle.fill;

      // フォーカス中の親のフラグ
      final focused = n.isParent && isFocusedParent(n.stageId);

      // 六角形の枠線設定
      final borderPaint = Paint()
        ..color = n.isPlayed ? const Color(0xFFAF6607) : Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = focused ? 5 : 5; // フォーカス中の親は太枠

      final innerPaint = Paint()
        ..color = const Color(0xFFFFB54E).withOpacity(0.37)
        ..style = PaintingStyle.fill;


      // 六角形の背景描写
      canvas.drawPath(outerPath, fillPaint);

      if (n.isPlayed) {
        canvas.drawPath(innerPath, innerPaint);
      }
      // 六角形の枠線描写
      canvas.drawPath(outerPath, borderPaint);

      // フォーカスアニメ
      final isFocusGroup = _isFocusedGroupNode(n);
      if (isFocusGroup) {
        final t = focusFx.value; // 0..1
        final pulse = 0.5 + 0.5 * sin(2 * pi * t); // 0..1

        final glowPaint = Paint()
          ..color = const Color(0xFFAF6607).withOpacity(0.10 + 0.25 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 + 4 * pulse;

        canvas.drawPath(outerPath, glowPaint);
      }

      // 六角形のラベル描写設定
      final tp = TextPainter(        
        text: TextSpan(
          text: n.label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )
      ..layout(maxWidth: hexW);

      // ラベル描写
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
      );

    }   

    // 並行移動を元に戻す
    canvas.restore();
  }

  // フォーカス中のグループか
  bool _isFocusedGroupNode(HexNode n) {
    if (n.isParent) return isFocusedParent(n.stageId);
    return n.parentIndex == focusIndex;
  }

  // 描写用Pathに加工する
  Path _transformPath(Path basePath, Rect baseBounds, Offset topLeft) {
    final sx = hexW / baseBounds.width;
    final sy = hexH / baseBounds.height;

    final m = Matrix4.identity()
      ..translate(topLeft.dx, topLeft.dy)
      ..scale(sx, sy)
      ..translate(-baseBounds.left, -baseBounds.top);

    return basePath.transform(m.storage);
  }

  Path _transformInnerPathSmaller({
    required Path basePath,
    required Rect baseBounds,
    required Offset topLeft,
    required double shrink, // 例: 6.0 とか 8.0
  }) {
    final sx = (hexW - shrink * 2) / baseBounds.width;
    final sy = (hexH - shrink * 2) / baseBounds.height;

    final m = Matrix4.identity()
      ..translate(topLeft.dx + shrink, topLeft.dy + shrink)
      ..scale(sx, sy)
      ..translate(-baseBounds.left, -baseBounds.top);

    return basePath.transform(m.storage);
  }

  void _drawGroupFrame(Canvas canvas) {
    Rect? worldBounds;

    for (final n in nodes) {
      final center = worldOrigin + n.pos;
      final r = Rect.fromCenter(center: center, width: hexW, height: hexH);
      worldBounds = (worldBounds == null) ? r : worldBounds!.expandToInclude(r);
    }
    if (worldBounds == null) return;

    // 余白（お好みで）
    const padding = 40.0;
    final target = worldBounds.deflate(-padding); // expand

    final sx = target.width / _groupFrameBounds.width;
    final sy = target.height / _groupFrameBounds.height;
    final s = min(sx, sy); // 比率維持

    final scaledW = _groupFrameBounds.width * s;
    final scaledH = _groupFrameBounds.height * s;

    final dx = target.center.dx - (_groupFrameBounds.left * s + scaledW / 2);
    final dy = target.center.dy - (_groupFrameBounds.top * s + scaledH / 2);

    final m = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(s, s)
      ..translate(-_groupFrameBounds.left, -_groupFrameBounds.top);

    final framePath = _groupFrameBasePath.transform(m.storage);
    
    final fillPaint = Paint()
    ..color = const Color(0xFFFCC436)
    ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = const Color(0xFFAF6607)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    
     canvas.drawPath(framePath, fillPaint);
    canvas.drawPath(framePath, framePaint);
  }

  @override
  bool shouldRepaint(covariant StageMapPainter oldDelegate) {
    return oldDelegate.worldTranslate != worldTranslate ||
        oldDelegate.nodes != nodes;
  }
}

//// SVGのデータ文字列に従って描写Path()を定義 ////
Path _parseSvgPathData(String d) {

  // svgのデータ文字列を分解
  final tokens = _tokenizePath(d);
  int i = 0;

  Path path = Path();
  Offset current = Offset.zero;
  Offset start = Offset.zero;

  String? cmd;

  // 次のトークンを数値として取得して、インデックスを進める
  double nextNum() => double.parse(tokens[i++]);

  // トークンがsvgコマンドか判定
  bool isCmd(String t) => RegExp(r'^[a-zA-Z]$').hasMatch(t);


  while (i < tokens.length) {

    final t = tokens[i];

    // 新しいコマンドが来たらcmdを更新
    if (isCmd(t)) {
      cmd = t;
      i++;
    }

    if (cmd == null) break;

    switch (cmd) {

      // 描画位置を移動(M:絶対座標, m:相対座標)
      case 'M':
      case 'm':
        
        {

          final x = nextNum();
          final y = nextNum();

          current = (cmd == 'm') ? current + Offset(x, y) : Offset(x, y);
          path.moveTo(current.dx, current.dy);
          start = current;

          // multiple pairs after M treated as implicit L
          while (i < tokens.length && !isCmd(tokens[i])) {
            final x2 = nextNum();
            final y2 = nextNum();
            current = (cmd == 'm') ? current + Offset(x2, y2) : Offset(x2, y2);
            path.lineTo(current.dx, current.dy);
          }

        }

        break;

      // 現在位置から直線を引く(L:絶対移動, l:相対移動)
      case 'L':
      case 'l':
        while (i < tokens.length && !isCmd(tokens[i])) {
          final x = nextNum();
          final y = nextNum();
          current = (cmd == 'l') ? current + Offset(x, y) : Offset(x, y);
          path.lineTo(current.dx, current.dy);
        }
        break;

      // Cコマンド
      case 'C':
      case 'c':
        while (i < tokens.length && !isCmd(tokens[i])) {
          final x1 = nextNum();
          final y1 = nextNum();
          final x2 = nextNum();
          final y2 = nextNum();
          final x = nextNum();
          final y = nextNum();

          final c1 = (cmd == 'c') ? current + Offset(x1, y1) : Offset(x1, y1);
          final c2 = (cmd == 'c') ? current + Offset(x2, y2) : Offset(x2, y2);
          final end = (cmd == 'c') ? current + Offset(x, y) : Offset(x, y);

          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          current = end;
        }
        break;      
      case 'H':
      case 'h':
        while (i < tokens.length && !isCmd(tokens[i])) {
          final x = nextNum();
          current = (cmd == 'h')
              ? current + Offset(x, 0)
              : Offset(x, current.dy);
          path.lineTo(current.dx, current.dy);
        }
        break;

      case 'V':
      case 'v':
        while (i < tokens.length && !isCmd(tokens[i])) {
          final y = nextNum();
          current = (cmd == 'v')
              ? current + Offset(0, y)
              : Offset(current.dx, y);
          path.lineTo(current.dx, current.dy);
        }
        break;

      // Zコマンド
      case 'Z':
      case 'z':
        path.close();
        current = start;
        break;

      default:
        // unsupported command -> try to skip safely
        // (your path shouldn't hit this)
        break;
    }

  }

  return path;

}

//// svgのデータ文字列を分解 ////
List<String> _tokenizePath(String d) {
  // split into commands and numbers incl scientific, negative, decimals
  final re = RegExp(r'[a-zA-Z]|-?\d*\.?\d+(?:e[-+]?\d+)?');
  return re.allMatches(d).map((m) => m.group(0)!).toList();
}