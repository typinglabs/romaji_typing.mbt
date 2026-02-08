///|
using @tea {none}

///|
using @tea {type Cmd}

///|
using @html {type Html}

///|
using @html {div}

///|
enum Msg {
  Home(HomeMsg)
  Countdown(CountdownMsg)
  Typing(TypingMsg)
  Result(ResultMsg)
}

///|
enum Model {
  Home(HomeViewModel)
  Countdown(CountdownViewModel)
  Typing(TypingViewModel)
  Result(ResultViewModel)
}

///|
extern "js" fn set_timeout(f : () -> Unit, ms : Int) = "(f, ms) => setTimeout(f, ms)"

///|
fn delay(msg : Msg, ms : Int) -> Cmd[Msg] {
  Cmd(fn(events) { set_timeout(fn() { events.trigger_update(msg) }, ms) })
}

///|
fn typing_model_from_countdown(countdown_model : CountdownViewModel) -> TypingViewModel {
  {
    hits: 0,
    misses: 0,
    time_left: 55,
    max_score: countdown_model.max_score,
    min_score: countdown_model.min_score,
    typing_state: {
      typed_romaji: "wagahaihaneko",
      typed_kanji: "吾輩は猫",
      remaining_romaji: "earu.namaehamadanai.",
      remaining_kanji: "である。名前はまだ無い。",
    },
  }
}

///|
fn update(msg : Msg, model : Model) -> (Cmd[Msg], Model) {
  match (msg, model) {
    (Home(HomeMsg::StartGame), Home(home_model)) => (
      delay(Countdown(CountdownMsg::Tick), 1000),
      Countdown({ count: 3, max_score: home_model.max_score, min_score: home_model.min_score }),
    )
    (Countdown(CountdownMsg::StartCountDown), Countdown(_)) =>
      (delay(Countdown(CountdownMsg::Tick), 1000), model)
    (Countdown(CountdownMsg::Tick), Countdown(countdown_model)) =>
      if countdown_model.count > 1 {
        (
          delay(Countdown(CountdownMsg::Tick), 1000),
          Countdown({ ..countdown_model, count: countdown_model.count - 1 }),
        )
      } else {
        (none(), Typing(typing_model_from_countdown(countdown_model)))
      }
    (Typing(_), _) => (none(), model)
    (Result(_), _) => (none(), model)
    _ => (none(), model)
  }
}

///|
fn view(model : Model) -> Html[Msg] {
  let view : @html.Html[Msg] = match model {
    Home(model) => home_view(model).map(Home(_))
    Countdown(model) => countdown_view(model).map(Countdown(_))
    Typing(model) => typing_view(model).map(Typing(_))
    Result(model) => result_view(model).map(Result(_))
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
  let model : Model = Home(initial_model)
  @tea.startup(model~, update~, view~)
}
