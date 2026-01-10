<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\GrammarGameController;
use App\Http\Controllers\Api\KanaGameController;
use App\Http\Controllers\Api\VocabularyGameController;
use App\Http\Controllers\Api\WebViewTicketController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    /*** webviewを開くためのticket発行用 ***/
    Route::post('/webview/ticket', [WebViewTicketController::class, 'issue']);

    /*** grammarゲーム：ステージ選択画面 ***/    
    Route::get('/grammar/stages', [GrammarGameController::class, 'stages']);

    /*** grammarゲーム：ゲーム画面表示用 ***/
    Route::get('/grammar/start_page/{start_id}', [GrammarGameController::class, 'start_page']);
    
    
    
    /*** vocabularyゲーム：ステージ選択画面 ***/
    Route::get('/vocabulary/stages', [VocabularyGameController::class, 'stages']);

    /*** grammarゲーム：ゲーム画面表示用 ***/
    Route::get('/vocab/start_page/{start_id}', [VocabularyGameController::class, 'start_page']);

    

    /*** kanaゲーム：ゲームスタート画面 ***/
    Route::get('/kana/start_page/{setting_id}', [KanaGameController::class, 'start_page']);



});

