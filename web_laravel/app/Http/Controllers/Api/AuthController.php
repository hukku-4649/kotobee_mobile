<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // POST /api/login
    public function login(Request $request)
    {
        // validateを実行
        $credentials = $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required'],
        ]);

        // 正しいか判定
        if (!Auth::attempt($credentials)) {
            return response()->json([
                'errors' => [
                    'email' => ['メールアドレスまたはパスワードが正しくありません。']
                ]
            ], 401);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        // 必要なら既存トークンを全削除（1端末運用したい場合など）
        // $user->tokens()->delete();

        // トークン生成
        $token = $user->createToken('flutter')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $user,
        ]);
    }

    // 新規ユーザ登録
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:50', 'unique:users,name'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        // データベースに登録
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        $token = $user->createToken('flutter')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $user,
        ], 201);
    }

    // GET /api/me（ログイン済み確認）
    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    // POST /api/logout（トークン削除）
    public function logout(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = $request->user();

        // 今使っているトークンだけ削除
        $user->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out']);
    }
    
}
