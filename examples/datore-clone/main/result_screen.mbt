///|
struct ResultViewModel {
  hits : Int
  misses : Int
  time_left : Int
  weak_keys : Array[(String, Int)]
  max_score : Int
  min_score : Int
}

///|
enum ResultMsg {
  Noop
}

///|
fn weak_keys_to_string(weak_keys : Array[(String, Int)]) -> String {
  weak_keys.map(pair => "\{pair.0}(\{pair.1})").join(" ")
}

///|
fn result_view(model : ResultViewModel) -> @html.Html[ResultMsg] {
  @html.div([
    @html.h2(class="text-lg font-bold mb-2", [@html.text("終了画面")]),
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
          @html.span(class="text-[22px] whitespace-nowrap", [@html.text("打鍵")]),
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
          @html.span(class="text-[22px] whitespace-nowrap", [@html.text("ミス")]),
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
          @html.span(class="text-[22px] whitespace-nowrap", [@html.text("残り時間")]),
        ]),
      ]),
      @html.div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [
          @html.div(class="flex items-center gap-2.5", [
            @html.span(class="text-[20px] font-bold", [
              @html.text("Time Out!! お疲れさまでした"),
            ]),
          ]),
        ],
      ),
      @html.div(class="w-full h-[70px] bg-white flex items-center px-[30px] py-5", [
        @html.span(class="text-[20px] font-bold", [
          @html.text("苦手キー：\{weak_keys_to_string(model.weak_keys)}"),
        ]),
      ]),
      @html.div(
        class="w-full h-[60px] bg-[#DDDDDD] flex items-center justify-between px-5",
        [
          @html.div(class="flex items-center gap-5", [
            @html.span(class="text-[18px]", [@html.text("Max： \{model.max_score}")]),
            @html.span(class="text-[18px]", [@html.text("Min： \{model.min_score}")]),
          ]),
          @html.div(
            class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
            [
              @html.span(class="text-[16px] font-bold text-white", [
                @html.text("リスタート (Esc)"),
              ]),
            ],
          ),
        ],
      ),
    ]),
  ])
}
