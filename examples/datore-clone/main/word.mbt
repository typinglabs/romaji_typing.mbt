///|
type Word = String

///|
let words : Array[Word] = ["おはよう", "こんにちは", "ありがとう"]

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
