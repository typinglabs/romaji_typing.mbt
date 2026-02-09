///|
struct TypingState {
  typed_romaji : String
  remaining_romaji : String
  typed_kanji : String
  remaining_kanji : String
}

///|
struct TypingViewModel {
  score : Score
  hits : Int
  misses : Int
  time_left : Int
  typing_state : TypingState
  apply_key : @typing.ApplyKeyFn
}

///|
fn typing_state_from_roman(state : @typing.RomanState) -> TypingState {
  {
    typed_romaji: state.typed_roman,
    remaining_romaji: state.remaining_roman,
    typed_kanji: state.typed_kana,
    remaining_kanji: state.remaining_kana,
  }
}

///|
fn apply_typing_key(model : TypingViewModel, key : Char) -> TypingViewModel {
  try {
    let (state, result) = (model.apply_key)(key)
    let next_state = typing_state_from_roman(state)
    match result {
      @typing.CorrectKey =>
        { ..model, hits: model.hits + 1, typing_state: next_state }
      @typing.WordCompleted =>
        { ..model, hits: model.hits + 1, typing_state: next_state }
      @typing.WrongKey =>
        { ..model, misses: model.misses + 1, typing_state: next_state }
    }
  } catch {
    _ => model
  }
}

///|
fn typing_view(model : TypingViewModel) -> Html[Msg] {
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
    span(class="text-[24px] text-[#999999]", [
      text(typing_state.typed_romaji),
    ]),
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
