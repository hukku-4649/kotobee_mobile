<?php

namespace App\Http\Controllers\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $streak = $user->streak;  // ←DBカラム名に合わせる

        // 2026/1/1 バッジ表示ため以下を追加（ただし）
        $prefectureId = $user->prefecture_id ?? 0;

        // prefecture_id 以下のバッジを取得
        // $badges = \DB::table('badges')
        //     ->where('id', '<=', $prefectureId)
        //     ->orderBy('id')
        //     ->get();

        // return view('profile.profile', compact('user', 'streak', 'badges'));

        return view('profile.mobile.profile', compact('user', 'streak'));
    }


    public function edit()
    {
        return view('profile.mobile.edit', [
            'user' => auth()->user()
        ]);
    }


    public function update(Request $request)
    {
        $user = auth()->user();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email',
            'password' => 'nullable|min:8|confirmed',
            'avatar' => 'nullable|image|max:2048', // 2MBまで
        ]);

        $user->name = $request->name;
        $user->email = $request->email;

        if ($request->password) {
            $user->password = bcrypt($request->password);
        }

        // avatar処理
        if ($request->hasFile('avatar')) {
            // 古い画像を削除
            if ($user->avatar_url) {
                Storage::disk('public')->delete($user->avatar_url);
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar_url = $path;
        }

        $user->save();

        return redirect()->route('mobile.profile')->with('success', 'Profile updated');
    }

    public function destroy(Request $request)
    {
        $user = $request->user();

        Auth::logout();       // ログアウト
        $user->delete();      // アカウント削除

        return redirect('/')->with('status', 'アカウントを削除しました。');
    }
}
