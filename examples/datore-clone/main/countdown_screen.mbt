///|
struct CountdownModel {
  score : Score
  count : Int
}

///|
fn countdown_view(model : CountdownModel) -> Html[Msg] {
  let { count, score } = model
  screen({
    hits: count,
    misses: count,
    time_left: count,
    kana_row: div([]),
    roman_row: div([]),
    score,
    footer_button: None,
  })
}
