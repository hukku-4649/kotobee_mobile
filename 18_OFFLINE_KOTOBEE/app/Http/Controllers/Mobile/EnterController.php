<?php

namespace App\Http\Controllers\Mobile;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;

class EnterController extends Controller
{
    public function enter(Request $request)
    {
        // urlから値取り出し
        $ticket = $request->query('ticket');
        $type = $request->query('type');
        $stage_id = $request->query('stage_id');        

        // エラー処理       
        if (!$ticket || !$type) {
            abort(400, 'missing ticket or type');
        }

        // user_idを取り出してticket削除
        $cache_key = "webview_ticket:{$ticket}";
        $user_id = Cache::pull($cache_key);
        
        //　エラー処理
        if (!$user_id) {
            abort(401, 'ticket expired or invalid');
        }
        $user = User::find($user_id);
        if (!$user) {
            abort(401, 'user not found');
        }

        // webセッションでログイン
        Auth::login($user);

        // セッション固定化対策
        $request->session()->regenerate();

        // ---- profile は stage_id 不要でここで分岐 ----
        if ($type === 'profile') {
            return redirect()->route('mobile.profile');
        }

        // ---- ゲーム系は stage_id 必須 ----
        if (!$stage_id) {
            abort(400, 'missing stage_id');
        }

        $route = match ($type) {
            'grammar'    => 'grammar.mobile.play',
            'vocabulary' => 'vocab.mobile.start',
            'kana'       => 'kana.mobile.start',
            default      => abort(400, 'invalid type'),
        };
        
        // ルート引数名を type ごとに切り替える
        $params = match ($type) {
            'kana'       => ['id' => $stage_id],
            default      => ['stage_id' => $stage_id],
        };
        
        return redirect()->route($route, $params);
        

    }
}
