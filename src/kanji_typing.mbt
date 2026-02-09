///|
pub enum KanjiOrKana {
  Kanji(Char, String)
  Kana(Char)
} derive(Show, Eq)

///|
pub fn kanji(ch : Char, reading : String) -> KanjiOrKana {
  Kanji(ch, reading)
}

///|
pub fn kana(ch : Char) -> KanjiOrKana {
  Kana(ch)
}

///|
pub struct KanjiState {
  typed_roman : String
  remaining_roman : String
  typed_kanji_index : Int
} derive(Show, Eq)

///|
pub type ApplyKanjiKeyFn = (Char) -> (KanjiState, RomanResult) raise Error

///|
fn build_word(items : Array[KanjiOrKana]) -> (String, Array[Int]) {
  let mut kana = ""
  let prefix_lengths : Array[Int] = []
  let mut current = 0

  for item in items {
    match item {
      Kanji(_, reading) => {
        kana += reading
        current += reading.length()
        prefix_lengths.push(current)
      }
      Kana(ch) => {
        let s = ch.to_string()
        kana += s
        current += 1
        prefix_lengths.push(current)
      }
    }
  }

  (kana, prefix_lengths)
}

///|
fn typed_kanji_index(prefix_lengths : Array[Int], typed_kana_len : Int) -> Int {
  let mut idx = 0
  for len in prefix_lengths {
    if typed_kana_len >= len {
      idx += 1
    } else {
      break
    }
  }
  idx
}

///|
fn kanji_state_from_roman(
  roman_state : RomanState,
  prefix_lengths : Array[Int],
) -> KanjiState {
  let typed_len = roman_state.typed_kana.length()
  let idx = typed_kanji_index(prefix_lengths, typed_len)
  {
    typed_roman: roman_state.typed_roman,
    remaining_roman: roman_state.remaining_roman,
    typed_kanji_index: idx,
  }
}

///|
pub fn create_kanji_engine(
  items : Array[KanjiOrKana],
) -> (KanjiState, ApplyKanjiKeyFn) raise Error {
  let (kana, prefix_lengths) = build_word(items)
  let (roman_state, apply_key) = create_roman_engine(kana)
  let initial_state = kanji_state_from_roman(roman_state, prefix_lengths)
  fn apply_kanji_key(
    key : Char,
  ) -> (KanjiState, RomanResult) raise Error {
    let (next_roman_state, result) = apply_key(key)
    let next_state = kanji_state_from_roman(
      next_roman_state,
      prefix_lengths,
    )
    (next_state, result)
  }
  (initial_state, apply_kanji_key)
}

///|
test "漢字混じりの進捗を反映できる 作成する" {
  let items : Array[KanjiOrKana] = [
    Kanji('作', "さく"),
    Kanji('成', "せい"),
    Kana('す'),
    Kana('る'),
  ]
  let (state0, apply_key) = create_kanji_engine(items)
  assert_eq(state0.typed_kanji_index, 0)

  let mut state = state0
  for key in "saku" {
    let (s, _) = apply_key(key)
    state = s
  }
  assert_eq(state.typed_kanji_index, 1)

  for key in "sei" {
    let (s, _) = apply_key(key)
    state = s
  }
  assert_eq(state.typed_kanji_index, 2)

  let mut result = CorrectKey
  for key in "suru" {
    let (s, r) = apply_key(key)
    state = s
    result = r
  }
  assert_eq(state.typed_kanji_index, 4)
  assert_eq(result, WordCompleted)
}
