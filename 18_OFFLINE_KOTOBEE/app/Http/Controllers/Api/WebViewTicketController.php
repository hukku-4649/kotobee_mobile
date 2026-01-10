<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class WebViewTicketController extends Controller
{
    // tikcet発効
    public function issue(Request $request) 
    {
        $user = $request->user(); // sanctum認証済み

        $ticket = Str::random(64); // ticket発行

        Cache::put("webview_ticket:{$ticket}", $user->id, now()->addSeconds(90));

        return response()->json([
            'ticket' => $ticket,
            'expires_in' => 90,
        ]);
    }
}
