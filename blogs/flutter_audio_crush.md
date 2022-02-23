## はじめに

`audioplayers` を使用して、複数の効果音を高速かつ連続で再生するという実装をしていました。

すると、効果音の再生後しばらくすると再生が遅延したり、アプリがクラッシュする事象が発生しました。

その際の解決法について記載していきます。

## 動作環境

- Flutter 2.10.0
- audioplayers: ^0.20.1

## サンプルコード

- [audio_players_sample](https://github.com/YoshikazuHosono/audio_players_sample)

## クラッシュするコード

まず、アセットに含まれる音声ファイルの一覧を定義しています。

```dart
final soundList = [
  "C.wav",
  "D.wav",
  "E.wav",
  "F.wav",
  "G.wav",
  "A.wav",
  "B.wav",
];
```

次に、ボタン押下時に Timer を作成し、音声ファイルを 100 milliseconds の間隔でランダムに再生するようにします。

```dart
            ElevatedButton(
                onPressed: () {
                  var audioCache = AudioCache();
                  crushTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                    final idx = Random().nextInt(soundList.length);
                    audioCache.play(soundList[idx]);
                  });
                },
                child: const Text("play crush sound")
            ),
```

最後に、音声を停止するボタンを作成します。

```dart
            ElevatedButton(
                onPressed: () {
                  crushTimer?.cancel();
                },
                child: const Text("stop crush sound")
            ),
```

この状態で再生ボタンを押下します。

一定時間再生されますが、しばらくするとクラッシュが発生しました。

Mac でのシミュレータ実行ではクラッシュしない場合がありますが、IPhone 実機での実行時、かなりの頻度でクラッシュします。

## クラッシュしないコード

Timer を作成するボタン押下時の処理を、以下のように書き換えます。

`soundList` の数だけ `AudioCache` を生成し、Map に変換して保持します。

また `AudioCache` の引数 `fixedPlayer` には、 `AudioPlayer` のインスタンスを渡します。

```dart
            ElevatedButton(
                onPressed: () {
                  var audioMap = Map.fromIterables(
                      soundList,
                      soundList.map((e) => AudioCache(fixedPlayer: AudioPlayer())).toList()
                  );
                  noCrushTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                    final idx = Random().nextInt(soundList.length);
                    audioMap[soundList[idx]]?.play(soundList[idx]);
                  });
                },
                child: const Text("play no crush sound")
            ),
```

音声の停止は、変更箇所はありません。

```dart
            ElevatedButton(
                onPressed: () {
                  crushTimer?.cancel();
                },
                child: const Text("stop crush sound")
            ),
```

## なぜクラッシュしなくなるのか

`AudioCache.play` の実装を見てみます。

`player` という変数に格納された `AudioPlayer` に対して、 `play` メソッドを呼び出しています。

`get player` とコメントされた箇所で取得しているようなので、その中身を確認します。

```dart
  Future<AudioPlayer> play(
    String fileName, {
    double volume = 1.0,
    bool? isNotification,
    PlayerMode mode = PlayerMode.MEDIA_PLAYER,
    bool stayAwake = false,
    bool recordingActive = false,
    bool? duckAudio,
  }) async {
    final uri = await load(fileName);
    final player = _player(mode); # get player
    if (fixedPlayer != null) {
      await player.setReleaseMode(ReleaseMode.STOP);
    }
    await player.play(
      uri.toString(),
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
      stayAwake: stayAwake,
      recordingActive: recordingActive,
      duckAudio: duckAudio ?? this.duckAudio,
    );
    return player;
  }
```

`_player` の実装です。

引数から `fixedPlayer` を受け取っていない場合、 `play` される度に `AudioPlayer` インスタンスが新規生成されて使用されます。

今回のように高速で何度も `play` メソッドを呼び出す場合に、この処理はメモリ不足を引き起こし、クラッシュや再生の遅延などを発生させていました。

```dart
  AudioPlayer _player(PlayerMode mode) {
    return fixedPlayer ?? AudioPlayer(mode: mode);
  }
```

## 参考文献

- <https://github.com/bluefireteam/audioplayers/issues/619>
