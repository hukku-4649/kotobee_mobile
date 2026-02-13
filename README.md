## 概要
Kotobeeは、日本語を学習する学生と、学習状況を管理する教師を対象とした日本語学習アプリケーションです。本アプリケーションは、3名のチームで約3か月間かけて開発しました。私は主に、Grammarゲーム、ステージ選択画面、そして教師用ダッシュボードの実装を担当しました。ゲームベースの学習アプローチを取り入れることで、学習者のモチベーションを維持し、継続的な学習を支援することを目的としています。チーム開発では、学生・教師ともにLaravelを用いたWebアプリケーションとして設計・開発しました。その後、学生の利便性向上を目的として、Flutterを用いたモバイルアプリの開発を個人で行い、一部機能を実装しました。

## スクリーンショット (Mobile App)

### ステージ選択画面
<p align="center">
  <img src="assets/screenshots/stage_select.png" width="300" />
</p>

<table align="center">
  <tr>
    <td align="center">
      <img src="assets/screenshots/kana_game.png" width="230" /><br>
      <b>Kana Game</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/vocabulary_game.png" width="230" /><br>
      <b>Vocabulary Game</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/grammar_game.png" width="230" /><br>
      <b>Grammar Game</b>
    </td>
  </tr>
</table>

## スクリーンショット (Teacher Dashboard / Web)

<p align="center">
  <img src="assets/screenshots/teacher_dashboard.png" width="900" />
</p>

## 実装済み機能
- 日本語学習のための3つのゲーム
  - Kana
  - Vocabulary
  - Grammar
- 教師が生徒の学習進捗を確認できるWebダッシュボード
- ユーザー認証（ログイン機能）
- 決済システム

## 今後の機能追加・改善予定
- より強固な認証システム（Googleログイン、メール認証ログイン）
- モバイル・Web両方のUI/UX改善
- 生徒と教師間のチャット機能
- バグ修正および安定性向上

## 技術スタック

### モバイルアプリケーション
- Flutter
- Dart

### バックエンド / Webアプリケーション
- Laravel
- PHP
- MySQL

### 開発環境・ツール
- MAMP (local development environment)
- Git / GitHub

## Project Structure
- `mobile_flutter/` : 学習者向けFlutterモバイルアプリ
- `web_laravel/`   : LaravelバックエンドAPIおよび教師用Webダッシュボード


