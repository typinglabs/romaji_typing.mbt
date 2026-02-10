# romaji_typing.mbt

ローマ字タイピングゲームを実装するための入力判定ライブラリです。

## インストール

```bash
moon add typinglabs/romaji_typing
```

使用したいパッケージの`moonbit.pkg.josn`でインポートします。

```json
{
  "import": [
    {
      "path": "typinglabs/romaji_typing",
      "alias": "typing"
    }
  ]
}
```

## 使い方

`create_kana_engine`にひらがなを渡して初期化します。

```mbt
let (state, apply) = @typing.create_kana_engine("りんご")
inspect(
  state,
  content=(
    #|{typed_romaji: "", remaining_romaji: "ringo", typed_kana_len: 0}
  ),
)
```

`create_kana_engine`の戻り値は`(TypingState, ApplyKeyFn)`です。

`TypingState`は、ローマ字タイピングの実装で必要な3つの情報を保持しています。

- `typed_romaji` 入力済みのローマ字
- `remaining_romaji` 残りの部分のローマ字
- `typed_kana_len` 入力済みのひらがなの長さ

ユーザーのキー入力を判定するには、`ApplyKeyFn = (Char) -> (TypingState, TypingResult)`にキーを渡します。

```mbt
let results = []
for key in "rimngo" {
  let (_state, result) = apply(key)
  match result {
    @typing.CorrectKey => results.push("正解")
    @typing.WrongKey => results.push("不正解")
    @typing.WordCompleted => results.push("完了")
  }
}
inspect(results, content=(
  #|["正解", "正解", "不正解", "正解", "正解", "完了"]
))
```

## 漢字混じりのワードを使う場合

漢字混じり文でどこまで打ったかを把握したい場合は、`create_kanji_engine`を使います。

`漢{かん}字{じ}`のような注釈付き文字列を渡します。

```mbt
let (state, apply) = @typing.create_kanji_engine("漢{かん}字{じ}")
```

## サンプル

[打鍵トレーナーのクローン](./examples/datore-clone)

## APIドキュメント

[mooncakes.io/docs/typinglabs/romaji_typing](https://mooncakes.io/docs/typinglabs/romaji_typing)
