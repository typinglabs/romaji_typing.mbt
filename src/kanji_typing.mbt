enum KanjiOrKana {
  Kanji(Char, String)
  Kana(Char)
} derive(Show, Eq)

///|
/// Typing state for kanji-mixed words, including display text.
pub struct KanjiState {
  typed_romaji : String
  remaining_romaji : String
  typed_kanji_len : Int
  display : String
} derive(Show, Eq)

struct KanjiWord {
  display : String
  items : Array[KanjiOrKana]
} derive(Show, Eq)

///|
/// Function that applies a key and returns next kanji state and result.
pub type ApplyKanjiKeyFn = (Char) -> (KanjiState, TypingResult) raise Error

///|
fn is_hiragana(ch : Char) -> Bool {
  (ch >= 'ぁ' && ch <= 'ゖ') || ch == 'ー'
}

///|
fn is_katakana(ch : Char) -> Bool {
  ch >= 'ァ' && ch <= 'ヶ'
}

///|
fn katakana_to_hiragana(ch : Char) -> Char {
  if is_katakana(ch) {
    (ch.to_int() - 0x60).unsafe_to_char()
  } else {
    ch
  }
}

fn parse_annotated_word(annotated : String) -> KanjiWord {
  let items : Array[KanjiOrKana] = []
  let display_chars : Array[Char] = []
  let chars : Array[Char] = []
  for ch in annotated.iter() {
    chars.push(ch)
  }
  let mut i = 0
  while i < chars.length() {
    let ch = chars[i]
    if ch == '{' {
      i += 1
      continue
    }
    if ch == '}' {
      i += 1
      continue
    }
    if i + 1 < chars.length() && chars[i + 1] == '{' {
      let mut j = i + 2
      let mut reading = ""
      while j < chars.length() && chars[j] != '}' {
        reading += chars[j].to_string()
        j += 1
      }
      display_chars.push(ch)
      items.push(Kanji(ch, reading))
      i = j + 1
      continue
    }
    display_chars.push(ch)
    if is_hiragana(ch) {
      items.push(Kana(ch))
    } else if is_katakana(ch) {
      items.push(Kana(katakana_to_hiragana(ch)))
    } else {
      items.push(Kanji(ch, ""))
    }
    i += 1
  }
  let mut display = ""
  for ch in display_chars {
    display += ch.to_string()
  }
  { display, items }
}

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
fn typed_kanji_len(prefix_lengths : Array[Int], typed_kana_len : Int) -> Int {
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
  roman_state : TypingState,
  prefix_lengths : Array[Int],
  display : String,
) -> KanjiState {
  let typed_len = roman_state.typed_kana_len
  let len = typed_kanji_len(prefix_lengths, typed_len)
  {
    typed_romaji: roman_state.typed_romaji,
    remaining_romaji: roman_state.remaining_romaji,
    typed_kanji_len: len,
    display,
  }
}

///|
/// Create a typing engine for kanji-mixed words.
///
/// # Example
/// ```mbt check
/// test {
///   let (state, _apply) = create_kanji_engine("作{さく}成{せい}する")
///   assert_eq(state.typed_kanji_len, 0)
/// }
/// ```
pub fn create_kanji_engine(
  annotated : String,
) -> (KanjiState, ApplyKanjiKeyFn) raise Error {
  let word = parse_annotated_word(annotated)
  let (kana, prefix_lengths) = build_word(word.items)
  let (roman_state, apply_key) = create_kana_engine(kana)
  let initial_state =
    kanji_state_from_roman(roman_state, prefix_lengths, word.display)
  fn apply_kanji_key(key : Char) -> (KanjiState, TypingResult) raise Error {
    let (next_roman_state, result) = apply_key(key)
    let next_state = kanji_state_from_roman(
      next_roman_state,
      prefix_lengths,
      word.display,
    )
    (next_state, result)
  }

  (initial_state, apply_kanji_key)
}

///|
test "漢字混じりの進捗を反映できる 作成する" {
  let (state0, apply_key) = create_kanji_engine("作{さく}成{せい}する")
  assert_eq(state0.typed_kanji_len, 0)
  let mut state = state0
  for key in "saku" {
    let (s, _) = apply_key(key)
    state = s
  }
  assert_eq(state.typed_kanji_len, 1)
  for key in "sei" {
    let (s, _) = apply_key(key)
    state = s
  }
  assert_eq(state.typed_kanji_len, 2)
  let mut result = CorrectKey
  for key in "suru" {
    let (s, r) = apply_key(key)
    state = s
    result = r
  }
  assert_eq(state.typed_kanji_len, 4)
  assert_eq(result, WordCompleted)
}

///|
test "注釈付きの単語を解析できる" {
  let word = parse_annotated_word("漢{かん}字{じ}カタカナ")
  assert_eq(word.display, "漢字カタカナ")
  assert_eq(word.items, [
    Kanji('漢', "かん"),
    Kanji('字', "じ"),
    Kana('か'),
    Kana('た'),
    Kana('か'),
    Kana('な'),
  ])
}
