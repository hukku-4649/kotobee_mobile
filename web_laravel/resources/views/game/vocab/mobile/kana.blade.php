{{-- @extends('layouts.app') --}}
@extends('layouts.mobile')

@section('content')

@push('scripts')
    @vite('resources/js/vocab_result_modal.js')    
@endpush


<script>
    console.log("session correct raw:", "{{ session('correct') }}");
    console.log("session last_answer:", "{{ session('last_answer') }}");
    console.log("POST answer:", "{{ old('answer') }}");
</script>

<link rel="stylesheet" href="{{ asset('css/style.css') }}">

<div class="game-wrapper">

    <h2 class="title">じゅんばんに ならべてね！</h2>
    {{-- @php dd('kana.blade reached'); @endphp --}}

    <!-- 画像（正解時は青枠） -->
    @if($question)

        <div class="image-box {{ session('correct') ? 'correct-border' : '' }}">
            <img src="{{ asset('storage/' . $question->image_url) }}" class="word-image">
        </div>
    @endif


    {{-- 回答フォーム --}}
    <form id="kanaForm" method="POST" action="{{ route('vocab.mobile.checkKana') }}">
        @csrf
        <input type="hidden" name="answer" id="answerInput">
    </form>

    <!-- 並べ替えの回答表示（復元対応） -->
    <div id="answer" class="answer-area">
        @if (session('last_answer'))
            @foreach (mb_str_split(session('last_answer')) as $char)
                <div class="kana-box">{{ $char }}</div>
            @endforeach
        @endif
    </div>

    <!-- バラバラの文字（既に使用済みの文字は除外） -->
    <div id="choices">
        @php
            $used = session('last_answer') ? mb_str_split(session('last_answer')) : [];
        @endphp

        @foreach ($shuffled as $char)
            @if (!in_array($char, $used))
                <div class="choice-btn kana-box" onclick="addChar(this)">
                    {{ $char }}
                </div>
            @endif
        @endforeach
    </div>

    {{-- × 不正解 --}}
    @if (session('error'))
        <div class="message error">
            ✖ Try again!
        </div>
    @endif

    {{-- ✔ 正解 --}}
    @if (session('correct'))
    
        <div class="message success">
            ✔ Great job!
        </div>

        <form method="POST" action="{{ route('vocab.mobile.next') }}">
            @csrf
            <button class="continue-btn">CONTINUE</button>
        </form>

    @endif

</div>


<script>
    function addChar(el) {
        // 正解後は操作禁止
        @if (session('correct'))
            return;
        @endif

        // 回答欄へ移動
        document.getElementById('answer').appendChild(el.cloneNode(true));
        el.remove();

        // 回答の文字配列
        let chars = [];
        document.querySelectorAll('#answer .kana-box').forEach(box => {
            chars.push(box.innerText.trim());
        });

        // hidden にセット
        document.getElementById('answerInput').value = chars.join('');

        // 全部選んだら送信（自動）
        if (chars.length === {{ count($chars) }}) {
            document.getElementById('kanaForm').submit();
        }
    }
</script>

@if (session('error'))
    <script>
        // ❌ 不正解 → 回答欄を空にして、選択肢を再生成する
        window.addEventListener('DOMContentLoaded', () => {
            const answerArea = document.getElementById('answer');
            const choicesArea = document.getElementById('choices');

            // 回答欄を空にする
            answerArea.innerHTML = '';

            // 選択肢も Blade から再レンダリングされてるはずなので何もしなくてよい。
            // （すでに元の $shuffled がレンダリングされてる）

            // これで再度選択できるようになる！
        });
    </script>
@endif


@if (session('correct') && $isLast)
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            
            // const res = await fetch("{{ route('vocab.mobile.finish') }}");
            // console.log("finish fetch:", res);

            // const data = await res.json();
            // console.log("finish json:", data);

            // showVocabResult(data);

            fetch('/vocab/mobile/finish', {
                method: 'POST',
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').content
                }
            })
            .then(res => res.json())
            .then(data => {
                if (window.FlutterPostMessage && window.FlutterPostMessage.postMessage) {
                    window.FlutterPostMessage.postMessage(JSON.stringify({
                        type: 'vocabulary_result',
                        payload: data,
                        score: data.time
                    }));
                } else {
                    console.warn('FlutterPostMessage channel not available');
                }
            })
            .catch(err => {
                if (window.FlutterPostMessage && window.FlutterPostMessage.postMessage) {
                    window.FlutterPostMessage.postMessage(JSON.stringify({
                        type: 'vocabulary_result',
                        payload: { saved: false, error: String(err) },
                        score: 0                        
                    }));
                }
            });

        });

    </script>
@endif

<script src="/js/vocab_result_modal.js"></script>



<script>
    console.log("kana.blade 読み込み OK");
</script>

<script>
    console.log("correct?", "{{ session('correct') }}");
    console.log("isLast?", "{{ $isLast }}");
</script>




@endsection


