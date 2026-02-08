///|
struct TypingState {
  typed_romaji : String
  remaining_romaji : String
  typed_kanji : String
  remaining_kanji : String
}

///|
struct TypingViewModel {
  hits : Int
  misses : Int
  time_left : Int
  typing_state : TypingState
  max_score : Int
  min_score : Int
}

///|
fn typing_view(model : TypingViewModel) -> Html[Msg] {
  let typing_state = model.typing_state
  div([
    h2(class="text-lg font-bold mb-2", [text("タイピング画面")]),
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.hits.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [text("打鍵")]),
        ]),
        div(class="flex shrink-0 items-center gap-3 w-[150px]", [
          div(
            class="w-[120px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.misses.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [text("ミス")]),
        ]),
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.time_left.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [text("残り時間")]),
        ]),
      ]),
      div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [
          div(class="flex items-center", [
            span(class="text-[28px] font-bold text-[#999999]", [
              text(typing_state.typed_kanji),
            ]),
            span(class="text-[28px] font-bold text-black", [
              text(typing_state.remaining_kanji),
            ]),
          ]),
        ],
      ),
      div(class="w-full h-[70px] bg-white flex items-center px-[30px] py-5", [
        div(class="flex items-center", [
          span(class="text-[24px] text-[#999999]", [
            text(typing_state.typed_romaji),
          ]),
          // TODO:
          span(class="text-[28px] font-bold text-red-500", [text("d")]),
          span(class="text-[24px] text-[#333333]", [
            text(typing_state.remaining_romaji),
          ]),
        ]),
      ]),
      div(class="w-full h-[60px] bg-[#DDDDDD] flex items-center px-5", [
        div(class="flex items-center gap-5", [
          span(class="text-[18px]", [text("Max： \{model.max_score}")]),
          span(class="text-[18px]", [text("Min： \{model.min_score}")]),
        ]),
      ]),
    ]),
  ])
}
