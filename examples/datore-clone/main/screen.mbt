///|
struct ScreenProps {
  hits : Int
  misses : Int
  time_left : Int
  score : Score
  kana_row : Html[Msg]
  roman_row : Html[Msg]
  footer_button : Html[Msg]?
}

///|
fn screen(props : ScreenProps) -> Html[Msg] {
  div([
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(props.hits.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [
            text("打鍵"),
          ]),
        ]),
        div(class="flex shrink-0 items-center gap-3 w-[150px]", [
          div(
            class="w-[120px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(props.misses.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [
            text("ミス"),
          ]),
        ]),
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(props.time_left.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [
            text("残り時間"),
          ]),
        ]),
      ]),
      div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [props.kana_row],
      ),
      div(
        class="w-full h-[70px] bg-white flex items-center px-[30px] py-5",
        [props.roman_row],
      ),
      div(
        class="w-full h-[60px] bg-[#DDDDDD] flex items-center justify-between px-5",
        [
          div(class="flex items-center gap-5", [
            span(class="text-[18px]", [
              text("Max： \{props.score.max_score}"),
            ]),
            span(class="text-[18px]", [
              text("Min： \{props.score.min_score}"),
            ]),
          ]),
          ..match props.footer_button {
            Some(button) => [button]
            None => []
          },
        ],
      ),
    ]),
  ])
}
