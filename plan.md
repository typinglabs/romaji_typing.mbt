# 実装方針: 単語末尾の「ん」を `n` 1回で許可するオプション

## 目的

- **単語末尾の「ん」だけ** `n` 1回で確定できるモードを追加する。

## 現状整理
- `src/romaji_table.mbt` に `n -> ん` ルールが存在するが、`process` は前方一致候補（`na`, `ni`, ...）があると保留するため、通常は `n` 単体で即確定されない。
- グラフ生成 (`src/kana_graph.mbt`) は `process(buffer, key)` を使って全遷移を作るため、末尾判定の仕様はここにオプションを通すと制御しやすい。
- 公開 API は `create_kana_engine(kana)` / `create_kanji_engine(annotated)`。

## 仕様案
- 追加オプション名（案）: `allow_single_n_at_word_end : Bool`
- 既定値: `false`
- `true` のときのみ、以下を許可:
  - ひらがな文字列の末尾が `ん` の場合、最終打鍵として `n` 1回を正解扱いにする。
- 許可しないケース:
  - 単語末尾以外の `ん`（例: `かんい` の中間 `ん`）
  - 末尾でも `ん` 以外

## 設計方針
1. オプション構造体を追加する。
- `TypingOptions`（公開）を `src/typing.mbt` に追加。
- 例:
  - `pub struct TypingOptions { allow_single_n_at_word_end : Bool }`

2. 公開 API を options 必須に統一する。
- `create_kana_engine` / `create_kanji_engine` のシグネチャを options 受け取りに変更する。
- 呼び出し側は `TypingOptions` を渡す前提に統一する。

3. グラフ構築にオプションを渡せるようにする。
- `build_graph_from_kana_with_dist(kana, options)` に変更する。

4. 末尾 `ん` の特例遷移を限定追加する。
- 方針:
  - 通常遷移生成後、`allow_single_n_at_word_end=true` かつ「次の1文字が末尾 `ん`」の状態に対して、`key='n'` の遷移を追加する。
- 制約:
  - 追加遷移は `kana_index` を 1 進め、`buffer` は空のまま。
  - 既存の `nn` / `n'` 経路は保持する（複数解として共存）。

## 変更対象（想定）
- `src/typing.mbt`
  - `TypingOptions` 追加
  - `create_kana_engine` を options 必須シグネチャへ変更
- `src/kanji_typing.mbt`
  - `create_kanji_engine` を options 必須シグネチャへ変更
- `src/kana_graph.mbt`
  - options 伝播
  - 末尾 `ん` 特例遷移追加
- `README.md`
  - 新オプション利用例を追記

## テスト方針
- 既存テストを options 対応に更新しつつ全通し。
- 新規テストを追加:
  1. options=false（既定）では、末尾 `ん` を `n` 1回で完了できないこと。
  2. options=true では、末尾 `ん` を `n` 1回で完了できること（例: `かん` -> `kan`）。
  3. options=true でも、中間 `ん` は `n` 1回で抜けられないこと（例: `かんい`）。
  4. options=true でも、末尾 `ん` を `nn` / `xn` で完了できること。
  5. options=true でも、既存の `kann` や `kan'` 相当経路が壊れていないこと。
  6. `create_kanji_engine` 系でも同等挙動になること。

## 実装順
1. `TypingOptions` を追加し、公開 API を options 必須シグネチャへ変更。
2. `kana_graph` に options 伝播と末尾特例を実装。
3. `typing` / `kanji_typing` のテスト追加。
4. `moon test` で回帰確認。
5. README の追記。
