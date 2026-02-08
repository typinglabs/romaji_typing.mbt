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
enum TypingMsg {
  Noop
}

///|
fn typing_view(model : TypingViewModel) -> @html.Html[TypingMsg] {
  let typing_state = model.typing_state
  @html.div([
    @html.div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      @html.div(class="flex justify-around items-center h-[80px] px-5", [
        @html.div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          @html.div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              @html.span(class="text-[36px] font-bold text-gray-500", [
                @html.text(model.hits.to_string()),
              ]),
            ],
          ),
          @html.span(class="text-[22px] whitespace-nowrap", [
            @html.text("打鍵"),
          ]),
        ]),
        @html.div(class="flex shrink-0 items-center gap-3 w-[150px]", [
          @html.div(
            class="w-[120px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              @html.span(class="text-[36px] font-bold text-gray-500", [
                @html.text(model.misses.to_string()),
              ]),
            ],
          ),
          @html.span(class="text-[22px] whitespace-nowrap", [
            @html.text("ミス"),
          ]),
        ]),
        @html.div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          @html.div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              @html.span(class="text-[36px] font-bold text-gray-500", [
                @html.text(model.time_left.to_string()),
              ]),
            ],
          ),
          @html.span(class="text-[22px] whitespace-nowrap", [
            @html.text("残り時間"),
          ]),
        ]),
      ]),
      @html.div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [
          @html.div(class="flex items-center", [
            @html.span(class="text-[28px] font-bold text-[#999999]", [
              @html.text(typing_state.typed_kanji),
            ]),
            @html.span(class="text-[28px] font-bold text-black", [
              @html.text(typing_state.remaining_kanji),
            ]),
          ]),
        ],
      ),
      @html.div(
        class="w-full h-[70px] bg-white flex items-center px-[30px] py-5",
        [
          @html.div(class="flex items-center", [
            @html.span(class="text-[24px] text-[#999999]", [
              @html.text(typing_state.typed_romaji),
            ]),
            // TODO:
            @html.span(class="text-[28px] font-bold text-red-500", [
              @html.text("d"),
            ]),
            @html.span(class="text-[24px] text-[#333333]", [
              @html.text(typing_state.remaining_romaji),
            ]),
          ]),
        ],
      ),
      @html.div(class="w-full h-[60px] bg-[#DDDDDD] flex items-center px-5", [
        @html.div(class="flex items-center gap-5", [
          @html.span(class="text-[18px]", [
            @html.text("Max： \{model.max_score}"),
          ]),
          @html.span(class="text-[18px]", [
            @html.text("Min： \{model.min_score}"),
          ]),
        ]),
      ]),
    ]),
  ])
}
