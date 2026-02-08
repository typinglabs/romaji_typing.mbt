///|
struct CountdownViewModel {
  count : Int
  max_score : Int
  min_score : Int
}

///|
fn countdown_view(model : CountdownViewModel) -> Html[Msg] {
  div([
    h2(class="text-lg font-bold mb-2", [text("カウントダウン画面")]),
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.count.to_string()),
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
                text(model.count.to_string()),
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
                text(model.count.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [text("残り時間")]),
        ]),
      ]),
      div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [
          div(class="flex items-center gap-2.5", [
            span(class="text-[20px] font-bold", [text("")]),
          ]),
        ],
      ),
      div(class="w-full h-[70px] bg-white flex items-center px-[30px] py-5", [
        span(class="text-[20px] font-bold", [text("")]),
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
