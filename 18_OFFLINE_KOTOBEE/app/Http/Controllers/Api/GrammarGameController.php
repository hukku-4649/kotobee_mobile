<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameResult;
use App\Models\GrammarQuestion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class GrammarGameController extends Controller
{
    ///// Grammarステージ選択画面 /////
    public function stages()
    {
        $user_id = Auth::id();

        // プレイしたステージのid配列
        $played_stage_ids = GameResult::where('game_id', 3)
            ->where('user_id', $user_id)
            ->distinct()
            ->pluck('gram_stage_id')
            ->values();

        // dd($played_stage_ids);

        // Grammar Questionを取得
        // $stages = GrammarQuestion::where('game_id', 3)->get();

        // dd($stages);

        // urlの一覧を取得
        // $stage_urls = $stages->filter(fn($s) => $s->id % 5 == 1)
        //     ->sortBy('stage_id')
        //     ->map(fn($s) => route('grammar.start_page', ['stage_id' => $s->stage_id]))
        //     ->values();

        $stage_urls = GrammarQuestion::query()
            ->where('game_id', 3)
            ->whereRaw('id % 5 = 1')
            ->orderBy('stage_id')
            ->get()
            ->map(fn($s) => route('grammar.start_page', ['stage_id' => $s->stage_id]))
            ->values();

        // dd($stage_urls);

        return response()->json([
            'played_stage_ids' => $played_stage_ids,
            'stage_urls' => $stage_urls,
        ]);
    }

    ///// Grammarステージmodal /////
    public function start_page(Request $request, $stage_id)
    {
        $user = $request->user();

        $best_value = GameResult::where('user_id', $user->id)
            ->where('gram_stage_id', $stage_id)
            ->min('play_time');
        
        $top3 = GameResult::with('user:id,name')
            ->where('gram_stage_id', $stage_id)
            ->whereHas('user')
            ->select('user_id', DB::raw('MIN(play_time) as best_value'))
            ->groupBy('user_id')
            ->orderBy('best_value', 'asc')
            ->limit(3)
            ->get()
            ->map(function ($r) {
                return [
                    'user_id' => $r->user_id,
                    'name' => optional($r->user)->name,
                    'best_value' => (float) $r->best_value,
                ];
            })
            ->values();

        // ゲームタイトル
        $title = 'Grammar Game';

        // 文章
        $description = 'How many seconds can you answer within?';

        // ゲーム遷移url
        $play_url = route('grammar.play', ['stage_id' => $stage_id]);

        // 単位
        $unit = 'sec';
        
        
        return response()->json([
            'stage_id' => (int) $stage_id,
            'title' => $title,
            'description' => $description,
            'unit' => $unit,
            'best_value' => $best_value === null ? null : (float) $best_value,
            'top3' => $top3,
            'play_url' => $play_url,
        ]);

    }   


}
