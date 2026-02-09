///|
struct Score {
  max_score : Int
  min_score : Int
}

///|
fn home_view(score : Score) -> Html[Msg] {
  let footer_button = div(
    click=StartGame,
    class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
    [
      span(class="text-[16px] font-bold text-white", [
        text("スタート (Enter)"),
      ]),
    ],
  )
  screen({
    hits: 0,
    misses: 0,
    time_left: 0,
    kana_row: div([]),
    roman_row: div([]),
    score,
    footer_button: Some(footer_button),
  })
}
