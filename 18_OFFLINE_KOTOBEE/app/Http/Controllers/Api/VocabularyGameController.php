<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GameResult;
use App\Models\VocabQuestion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class VocabularyGameController extends Controller
{
    ///// Vocabularyステージ選択画面 /////
    public function stages() {

        $user_id = Auth::id();

        // プレイしたステージのid配列
        $played_stage_ids = GameResult::where('game_id', 2)
            ->where('user_id', $user_id)
            ->distinct()
            ->pluck('vcab_stage_id')
            ->values();

        // dd($played_stage_ids);
        
        // 各ステージのurl配列
        $stage_urls = VocabQuestion::where('game_id', 2)
            ->whereRaw('id % 5 = 1')
            ->orderBy('stage_id')
            ->get()
            ->map(fn($s) => route('vocab.start_page', $s->stage_id))
            ->values()
            ->toArray();

        return response()->json([
            'played_stage_ids' => $played_stage_ids,
            'stage_urls' => $stage_urls,
        ]);

    }

    ///// ゲームスタートmodal /////
    public function start_page(Request $request, $stage_id)
    {
        $user = Auth::user();
        $game_id = 2;

        // ユーザーのベストタイム
        $best_value = GameResult::where('user_id', $user->id)
            ->where('vcab_stage_id', $stage_id)
            ->min('play_time');

        // ゲームの top3（ユーザーごとのベストタイム）       
        $top3 = GameResult::with('user:id,name')
            ->where('vcab_stage_id', $stage_id)
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
        $title = 'Vocabulary Game';

        // 文章
        $description = 'How many seconds can you answer within?';

        // ゲーム遷移url
        $play_url = route('vocab.start', $stage_id);

        // 単位
        $unit = 'sec';

        return response()->json([
            'stage_id'   => $stage_id,
            'title'      => $title,
            'description'=> $description,
            'unit'       => $unit,
            'play_url'   => $play_url,
            'best_value' => $best_value,
            'top3'       => $top3,
        ]);
    }

}
