///|
struct Word {
  display : String
  items : Array[@typing.KanjiOrKana]
}

///|
fn kana_items(text : String) -> Array[@typing.KanjiOrKana] {
  let items : Array[@typing.KanjiOrKana] = []
  for ch in text.iter() {
    items.push(@typing.kana(ch))
  }
  items
}

///|
let words : Array[Word] = [
  {
    display: "作成する",
    items: [
      @typing.kanji('作', "さく"),
      @typing.kanji('成', "せい"),
      @typing.kana('す'),
      @typing.kana('る'),
    ],
  },
  { display: "おはよう", items: kana_items("おはよう") },
  { display: "こんにちは", items: kana_items("こんにちは") },
  { display: "ありがとう", items: kana_items("ありがとう") },
]

///|
fn create_next_word_fn() -> () -> Word {
  let mut word_index = 0
  fn next_word() -> Word {
    let word = words[word_index]
    word_index += 1
    word
  }

  next_word
}

///|
let next_word : () -> Word = create_next_word_fn()
