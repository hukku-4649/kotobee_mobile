<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameResult;
use App\Models\GameSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class KanaGameController extends Controller
{
    ///// Kanaステージmodal /////
    public function start_page(Request $request, $setting_id)
    {
        // ゲーム設定情報取り出し、ない場合404エラー
        $game_setting = GameSetting::findOrFail($setting_id);

        $user = Auth::user();
        $game_id = 1;
        $mode = $game_setting->mode;

        if ($mode === '60s-count') {
            $order_column = 'score';
            $order_direction = 'desc';
            $description = 'How many can you get in 60s?';
            $unit = 'こ';
    
            $top3 = GameResult::with('user')
                ->select('user_id', DB::raw("MAX($order_column) as best_value"))
                ->where('game_id', $game_id)
                ->where('setting_id', $setting_id)
                ->groupBy('user_id')
                ->orderBy('best_value', $order_direction)
                ->limit(3)
                ->get();
    
            $best_value = GameResult::where('user_id', $user->id)
                ->where('game_id', $game_id)
                ->where('setting_id', $setting_id)
                ->max($order_column);
    
        } elseif ($mode === 'timeattack') {
            $order_column = 'play_time';
            $order_direction = 'asc';
            $description = 'How many seconds does it take to get everything?';
            $unit = 'sec';
    
            $top3 = GameResult::with('user')
                ->select('user_id', DB::raw("MIN($order_column) as best_value"))
                ->where('game_id', $game_id)
                ->where('setting_id', $setting_id)
                ->groupBy('user_id')
                ->orderBy('best_value', $order_direction)
                ->limit(3)
                ->get();
    
            $best_value = GameResult::where('user_id', $user->id)
                ->where('game_id', $game_id)
                ->where('setting_id', $setting_id)
                ->min($order_column);
    
        } else {
            return response()->json([
                'message' => 'Unsupported mode',
                'mode' => $mode,
            ], 422);
        }
    
        $title = 'Kana Game';
        
        $play_url = route('kana.start', $setting_id);
    
        // Flutter で扱いやすい形に整形
        $top3_payload = $top3->map(function ($row) {
            return [
                'user_id' => $row->user_id,
                'name' => optional($row->user)->name,
                'best_value' => $row->best_value,
            ];
        })->values();
    
        // ★ 常に JSON を返す（redirect なし）
        return response()->json([
            'setting_id' => (int) $setting_id,
            'mode' => $mode,
            'title' => $title,
            'description' => $description,
            'unit' => $unit,
            'play_url' => $play_url,
            'best_value' => $best_value,
            'top3' => $top3_payload,
        ]);

    }
}
