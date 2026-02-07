# romaji_typing.mbt

ローマ字タイピングゲームを実装するための入力判定ライブラリです。

## インストール

WIP

```bash
moon add typinglabs/romaji_typing
```

`moon.pkg.json`でインポートします。

```json
{
  "import": [
    {
      "path": "typinglabs/romaji_typing/src",
      "alias": "typing"
    }
  ]
}
```

## 使い方

`create_roman_engine`にひらがなを渡して初期化します。

```mbt
let (state, apply) = @typing.create_roman_engine("りんご")
inspect(
  state,
  content=(
    #|{typed_roman: "", remaining_roman: "ringo", typed_kana: "", remaining_kana: "りんご"}
  ),
)
```

`create_roman_engine`の戻り値は`(RomanState, ApplyKeyFn)`です。

`RomanState`は、ローマ字タイピングの実装で必要な4つの情報を保持しています。

- `typed_roman` 入力済みのローマ字
- `remaining_roman` 残りの部分のローマ字
- `typed_kana` 入力済みのひらがな
- `typed_roman` 残りの部分のひらがな

ユーザーのキー入力を判定するには、`ApplyKeyFn = (Char) -> (RomanState, RomanResult)`にキーを渡します。

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

## サンプル

WIP

## APIドキュメント

WIP
