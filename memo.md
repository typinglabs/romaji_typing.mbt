# メモ

## テストを書く

テストを書いて、バグ修正をしていきます。

機能としては

- ローマ字テーブルを使って、ローマ字をひらがなに変換する機能
- ひらがなを受け取って有効な入力を表すグラフを作成する機能
- 入力を表すグラフを使って判定を行う機能

などがあります。

機能のテストには、打鍵トレーナー高速タイピングのワードを全て打てることを確かめようと思います。

それで結合テストをします。まずは、ここから書きます。

あとは、複数の打ち方に対応していることを確認する必要があります。

他には、キーガイドに表示する単語の優先順位がどう決まっているかを確認します。

ca, co > ka, koになっているようなので、ここは修正した方が良さそう。

---

shortest_pathでクラッシュしているので、修正していきます。

ローマ字→かな、の変換ロジックが間違っていたようです。

かな→グラフの構築について。パニックはしないようにしたい。具体的にどこでエラー出ているのでしょうか。

## 参考

- [Error handling — MoonBit v0.7.1 documentation](https://docs.moonbitlang.com/en/latest/language/error-handling.html)
- [Writing Tests — MoonBit v0.7.1 documentation](https://docs.moonbitlang.com/en/latest/language/tests.html)
- [MoonBit's Package Manager Tutorial — MoonBit v0.7.1 documentation](https://docs.moonbitlang.com/en/latest/toolchain/moon/package-manage-tour.html)
