///|
struct Score {
  max_score : Int
  min_score : Int
}

///|
fn home_view(score : Score) -> @html.Html[Msg] {
  @html.div([
    @html.div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      @html.div(class="flex justify-around items-center h-[80px] px-5", [
        @html.div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          @html.div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              @html.span(class="text-[36px] font-bold text-gray-500", [
                @html.text("0"),
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
                @html.text("0"),
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
                @html.text("0"),
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
          @html.div(class="flex items-center gap-2.5", [
            @html.span(class="text-[20px] font-bold", [@html.text("")]),
          ]),
        ],
      ),
      @html.div(
        class="w-full h-[70px] bg-white flex items-center px-[30px] py-5",
        [@html.span(class="text-[20px] font-bold", [@html.text("")])],
      ),
      @html.div(
        class="w-full h-[60px] bg-[#DDDDDD] flex items-center justify-between px-5",
        [
          @html.div(class="flex items-center gap-5", [
            @html.span(class="text-[18px]", [
              @html.text("Max： \{score.max_score}"),
            ]),
            @html.span(class="text-[18px]", [
              @html.text("Min： \{score.min_score}"),
            ]),
          ]),
          @html.div(
            click=StartGame,
            class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
            [
              @html.span(class="text-[16px] font-bold text-white", [
                @html.text("スタート (Enter)"),
              ]),
            ],
          ),
        ],
      ),
    ]),
  ])
}
