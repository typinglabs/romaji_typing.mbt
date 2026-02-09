///|
struct TypingState {
  typed_romaji : String
  remaining_romaji : String
  typed_kanji : String
  remaining_kanji : String
}

///|
struct TypingModel {
  score : Score
  hits : Int
  misses : Int
  time_left : Int
  typing_state : TypingState
  apply_key : @typing.ApplyKanjiKeyFn
  display : String
  weak_keys : Map[Char, Int]
}

///|
fn typing_state_from_kanji(
  state : @typing.KanjiState,
  display : String,
) -> TypingState raise Error {
  let typed_kanji = display[0:state.typed_kanji_index].to_string()
  let remaining_kanji = display[state.typed_kanji_index:].to_string()
  {
    typed_romaji: state.typed_roman,
    remaining_romaji: state.remaining_roman,
    typed_kanji,
    remaining_kanji,
  }
}

///|
fn apply_typing_key(model : TypingModel, key : Char) -> TypingModel {
  try {
    let (state, result) = (model.apply_key)(key)
    let next_state = typing_state_from_kanji(state, model.display)
    match result {
      @typing.CorrectKey =>
        { ..model, hits: model.hits + 1, typing_state: next_state }
      @typing.WordCompleted => {
        // 次のワードに進む
        let word = next_word()
        let (state, apply_key) = @typing.create_kanji_engine(word.items)
        let next_state = typing_state_from_kanji(state, word.display)
        {
          ..model,
          typing_state: next_state,
          apply_key,
          display: word.display,
        }
      }
      @typing.WrongKey => {
        let weak_keys = model.weak_keys
        let expected = next_state.remaining_romaji[0].unsafe_to_char()
        match weak_keys.get(expected) {
          Some(count) => weak_keys.set(expected, count + 1)
          None => weak_keys.set(expected, 1)
        }
        {
          ..model,
          misses: model.misses + 1,
          typing_state: next_state,
          weak_keys,
        }
      }
    }
  } catch {
    _ => model
  }
}

///|
fn typing_view(model : TypingModel) -> Html[Msg] {
  let typing_state = model.typing_state
  let kana_row = div(class="flex items-center", [
    span(class="text-[28px] font-bold text-[#999999]", [
      text(typing_state.typed_kanji),
    ]),
    span(class="text-[28px] font-bold text-black", [
      text(typing_state.remaining_kanji),
    ]),
  ])
  let roman_row = div(class="flex items-center", [
    span(class="text-[24px] text-[#999999]", [text(typing_state.typed_romaji)]),
    span(class="text-[24px] text-[#333333]", [
      text(typing_state.remaining_romaji),
    ]),
  ])
  screen({
    hits: model.hits,
    misses: model.misses,
    time_left: model.time_left,
    kana_row,
    roman_row,
    score: model.score,
    footer_button: None,
  })
}
