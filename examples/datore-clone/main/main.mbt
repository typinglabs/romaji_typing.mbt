///|
using @tea {none}

///|
using @html {div, h2, span, text}

///|
using @tea {type Cmd}

///|
using @html {type Html}

///|
enum Msg {
  // Increment
  // Decrement
}

///|
fn update(_msg : Msg, model : Model) -> (Cmd[Msg], Model) {
  (none(), model)
}

///|
enum Model {
  Home(HomeViewModel)
  Typing(TypingViewModel)
  Countdown(CountdownViewModel)
  Result(ResultViewModel)
}

///|
fn weak_keys_to_string(weak_keys : Array[(String, Int)]) -> String {
  weak_keys.map(pair => "\{pair.0}(\{pair.1})").join(" ")
}

///|
fn view(model : Model) -> Html[Msg] {
  let view = match model {
    Home(model) => home_view(model)
    Typing(model) => typing_view(model)
    Countdown(model) => countdown_view(model)
    Result(model) => result_view(model)
  }
  div(class="bg-gray-100 font-inter p-10 flex flex-col items-center gap-10", [
    view,
  ])
}

///|
fn main {
  let initial_model : HomeViewModel = {
    hits: 0,
    misses: 0,
    time_left: 0,
    max_score: 0,
    min_score: 0,
  }
  let typing_model : TypingViewModel = {
    hits: 45,
    misses: 3,
    time_left: 55,
    max_score: 0,
    min_score: 0,
    typing_state: {
      typed_romaji: "wagahaihaneko",
      typed_kanji: "吾輩は猫",
      remaining_romaji: "earu.namaehamadanai.",
      remaining_kanji: "である。名前はまだ無い。",
    },
  }
  let countdown_model : CountdownViewModel = {
    count: 3,
    max_score: 0,
    min_score: 0,
  }
  let result_model : ResultViewModel = {
    hits: 97,
    misses: 6,
    time_left: 0,
    weak_keys: [("s", 3), ("u", 2), ("k", 1)],
    max_score: 0,
    min_score: 0,
  }
  // let model : Model = Home(initial_model)
  // let model : Model = Model::Typing(typing_model)
  // let model : Model = Model::Countdown(countdown_model)
  let model : Model = Model::Result(result_model)
  @tea.startup(model~, update~, view~)
}
