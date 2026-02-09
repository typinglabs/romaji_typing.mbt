///|
struct ResultModel {
  hits : Int
  misses : Int
  time_left : Int
  weak_keys : Array[(String, Int)]
  score : Score
}

///|
fn weak_keys_to_string(weak_keys : Array[(String, Int)]) -> String {
  weak_keys.map(pair => "\{pair.0}(\{pair.1})").join(" ")
}

///|
fn result_view(model : ResultModel) -> Html[Msg] {
  let kana_row = div(class="flex items-center gap-2.5", [
    span(class="text-[20px] font-bold", [
      text("Time Out!! お疲れさまでした"),
    ]),
  ])
  let roman_row = span(class="text-[20px] font-bold", [
    text("苦手キー：\{weak_keys_to_string(model.weak_keys)}"),
  ])
  let footer_button : Html[Msg] = div(
    class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
    [
      span(class="text-[16px] font-bold text-white", [
        text("リスタート (Esc)"),
      ]),
    ],
  )
  screen({
    hits: model.hits,
    misses: model.misses,
    time_left: model.time_left,
    kana_row,
    roman_row,
    score: model.score,
    footer_button: Some(footer_button),
  })
}
