///|
using @tea {none}

///|
using @tea {type Cmd}

///|
enum Msg {
  // Home(HomeMsg)
  // ゲームを開始する
  StartGame
  // カウントダウンを進める
  CountdownTick
  // ゲーム中のタイマーを進める
  TimerTick
  // キーが入力される
  KeyPressed(Char)
  // ゲームをリスタートする
  RestartTyping
}

///|
enum Screen {
  Home
  Countdown(CountdownModel)
  Typing(TypingModel)
  Result(ResultModel)
}

///|
struct Model {
  score : Score
  screen : Screen
}

///|
extern "js" fn set_timeout(f : () -> Unit, ms : Int) =
  #|(f, ms) => setTimeout(f, ms)

///|
extern "js" fn enable_key_listener(f : (String) -> Unit) =
  #|(f) => {
  #|  if (window.__typingKeyListener) return;
  #|  const handler = (e) => f(e.key);
  #|  window.__typingKeyListener = handler;
  #|  window.addEventListener('keydown', handler);
  #|}

///|
extern "js" fn disable_key_listener() =
  #|() => {
  #|  const handler = window.__typingKeyListener;
  #|  if (!handler) return;
  #|  window.removeEventListener('keydown', handler);
  #|  window.__typingKeyListener = null;
  #|}

///|
fn delay(msg : Msg, ms : Int) -> Cmd[Msg] {
  Cmd(fn(events) { set_timeout(fn() { events.trigger_update(msg) }, ms) })
}

///|
fn run_effect(effect : () -> Unit) -> Cmd[Msg] {
  Cmd(fn(_events) { effect() })
}

///|
fn first_char(text : String) -> Char? {
  for ch in text.iter() {
    return Some(ch)
  }
  None
}

///|
fn enable_typing_key_handler() -> Cmd[Msg] {
  Cmd(fn(events) {
    enable_key_listener(fn(key_str) {
      if key_str[:].length() != 1 {
        return
      }
      match first_char(key_str) {
        Some(key) => events.trigger_update(KeyPressed(key))
        None => ()
      }
    })
  })
}

///|
fn start_typing(model : Model) -> (Cmd[Msg], Model) {
  (@tea.batch([enable_typing_key_handler(), delay(TimerTick, 1000)]), model)
}

///|
fn stop_typing(next_model : Model) -> (Cmd[Msg], Model) {
  (run_effect(disable_key_listener), next_model)
}

///|
fn typing_model_from_countdown(
  countdown_model : CountdownModel,
) -> TypingModel raise Error {
  let word = next_word()
  let (kanji_state, apply_key) = @typing.create_kanji_engine(word.items)
  {
    score: countdown_model.score,
    hits: 0,
    misses: 0,
    time_left: 60,
    typing_state: typing_state_from_kanji(kanji_state, word.display),
    apply_key,
    display: word.display,
  }
}

///|
fn result_model_from_typing(typing_model : TypingModel) -> ResultModel {
  {
    hits: typing_model.hits,
    misses: typing_model.misses,
    time_left: 0,
    weak_keys: [("s", 3), ("u", 2), ("k", 1)],
    score: typing_model.score,
  }
}

///|
fn update(msg : Msg, model : Model) -> (Cmd[Msg], Model) {
  match (msg, model.screen) {
    (StartGame, Home) =>
      (
        delay(CountdownTick, 1000),
        { ..model, screen: Countdown({ count: 3, score: model.score }) },
      )
    (CountdownTick, Countdown(countdown_model)) =>
      if countdown_model.count > 1 {
        (
          delay(CountdownTick, 1000),
          {
            ..model,
            screen: Countdown({
              ..countdown_model,
              count: countdown_model.count - 1,
            }),
          },
        )
      } else {
        start_typing({
          ..model,
          screen: Typing(typing_model_from_countdown(countdown_model)),
        }) catch {
          _ => (none(), model)
        }
      }
    (TimerTick, Typing(typing_model)) =>
      if typing_model.time_left > 1 {
        (
          delay(TimerTick, 1000),
          {
            ..model,
            screen: Typing({
              ..typing_model,
              time_left: typing_model.time_left - 1,
            }),
          },
        )
      } else {
        stop_typing({
          ..model,
          screen: Result(result_model_from_typing(typing_model)),
        })
      }
    (KeyPressed(key), Typing(typing_model)) =>
      (none(), { ..model, screen: Typing(apply_typing_key(typing_model, key)) })
    // TODO:
    (RestartTyping, _) => (none(), model)
    _ => (none(), model)
  }
}

///|
fn view(model : Model) -> Html[Msg] {
  let view : Html[Msg] = match model.screen {
    Home => home_view(model.score)
    Countdown(model) => countdown_view(model)
    Typing(model) => typing_view(model)
    Result(model) => result_view(model)
  }
  div(class="bg-gray-100 font-inter p-10 flex flex-col items-center gap-10", [
    view,
  ])
}

///|
fn main {
  let model : Model = { score: { max_score: 0, min_score: 0 }, screen: Home }
  @tea.startup(model~, update~, view~)
}
