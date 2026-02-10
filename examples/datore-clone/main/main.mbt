///|
using @tea {none}

///|
using @tea {type Cmd}

///|
enum Msg {
  // ゲームを開始する
  StartGame
  // カウントダウンを進める
  CountdownTick
  // ゲーム中のタイマーを進める
  TimerTick
  // キーが入力される
  KeyPressed(Char)
  // ショートカットが入力される
  UseShortcut(String)
  // ホームに戻る
  BackToHome
}

///|
struct Score {
  max_score : Int
  min_score : Int
}

///|
struct CountdownModel {
  count : Int
}

///|
struct ResultModel {
  hits : Int
  misses : Int
  time_left : Int
  weak_keys : Array[(String, Int)]
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
extern "js" fn enable_shortcut_listener(f : (String) -> Unit) =
  #|(f) => {
  #|  if (window.__shortcutKeyListener) return;
  #|  const handler = (e) => f(e.key);
  #|  window.__shortcutKeyListener = handler;
  #|  window.addEventListener('keydown', handler);
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
fn enable_shortcut_key_handler() -> Cmd[Msg] {
  Cmd(fn(events) {
    enable_shortcut_listener(fn(key_str) {
      if key_str == "Escape" || key_str == "Enter" {
        events.trigger_update(UseShortcut(key_str))
      }
    })
  })
}

///|
fn start_typing() -> Cmd[Msg] {
  @tea.batch([enable_typing_key_handler(), delay(TimerTick, 1000)])
}

///|
fn stop_typing() -> Cmd[Msg] {
  run_effect(disable_key_listener)
}

///|
fn build_typing_model() -> TypingModel raise Error {
  let word = next_word()
  let (kanji_state, apply_key) = @typing.create_kanji_engine(word)
  {
    hits: 0,
    misses: 0,
    time_left: 10,
    typing_state: typing_state_from_kanji(kanji_state),
    apply_key,
    weak_keys: Map::new(),
  }
}

///|
fn build_result_model(typing_model : TypingModel) -> ResultModel {
  let entries = typing_model.weak_keys.iter().to_array()
  entries.sort_by((a, b) => b.1.compare(a.1))
  let weak_keys : Array[(String, Int)] = []
  let limit = if entries.length() < 5 { entries.length() } else { 5 }
  for pair in entries[0:limit] {
    weak_keys.push((pair.0.to_string(), pair.1))
  }
  {
    hits: typing_model.hits,
    misses: typing_model.misses,
    time_left: 0,
    weak_keys,
  }
}

///|
fn update_screen(model : Model, screen : Screen) -> Model {
  { ..model, screen, }
}

///|
fn update(msg : Msg, model : Model) -> (Cmd[Msg], Model) {
  match (msg, model.screen) {
    (StartGame, Home) =>
      (
        // ショートカット登録は、アプリ起動時に行えないためここで行う
        // 1回目はEnterが効かないので、できれば修正したい
        @tea.batch([enable_shortcut_key_handler(), delay(CountdownTick, 1000)]),
        model |> update_screen(Countdown({ count: 3 })),
      )
    (UseShortcut("Enter"), Home) =>
      (
        delay(CountdownTick, 1000),
        model |> update_screen(Countdown({ count: 3 })),
      )
    (CountdownTick, Countdown(countdown_model)) =>
      if countdown_model.count > 1 {
        (
          delay(CountdownTick, 1000),
          model
          |> update_screen(Countdown({ count: countdown_model.count - 1 })),
        )
      } else {
        (
          start_typing(),
          model |> update_screen(Typing(try! build_typing_model())),
        )
      }
    (TimerTick, Typing(typing_model)) =>
      if typing_model.time_left > 1 {
        (
          delay(TimerTick, 1000),
          model
          |> update_screen(
            Typing({ ..typing_model, time_left: typing_model.time_left - 1 }),
          ),
        )
      } else {
        (
          stop_typing(),
          model |> update_screen(Result(build_result_model(typing_model))),
        )
      }
    (KeyPressed(key), Typing(typing_model)) =>
      (none(), { ..model, screen: Typing(apply_typing_key(typing_model, key)) })
    (UseShortcut("Escape"), Typing(_)) =>
      (stop_typing(), model |> update_screen(Home))
    (UseShortcut("Escape"), _) => (none(), model |> update_screen(Home))
    (UseShortcut("Enter"), Result(_)) => (none(), model |> update_screen(Home))
    (BackToHome, _) => (none(), model |> update_screen(Home))
    _ => (none(), model)
  }
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

///|
fn countdown_view(count : Int, score : Score) -> Html[Msg] {
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

///|
fn result_view(model : ResultModel, score : Score) -> Html[Msg] {
  let kana_row = div(class="flex items-center gap-2.5", [
    span(class="text-[20px] font-bold", [
      text("Time Out!! お疲れさまでした"),
    ]),
  ])
  fn weak_keys_to_string(weak_keys : Array[(String, Int)]) -> String {
    weak_keys.map(pair => "\{pair.0}(\{pair.1})").join("　")
  }

  let roman_row = span(class="text-[20px] font-bold", [
    text("苦手キー：\{weak_keys_to_string(model.weak_keys)}"),
  ])
  let footer_button : Html[Msg] = div(
    click=BackToHome,
    class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
    [span(class="text-[16px] font-bold text-white", [text("戻る (Enter)")])],
  )
  screen({
    hits: model.hits,
    misses: model.misses,
    time_left: model.time_left,
    kana_row,
    roman_row,
    score,
    footer_button: Some(footer_button),
  })
}

///|
fn view(model : Model) -> Html[Msg] {
  let score = model.score
  let view : Html[Msg] = match model.screen {
    Home => home_view(score)
    Countdown(model) => countdown_view(model.count, score)
    Typing(typing_model) => typing_view(typing_model, score)
    Result(model) => result_view(model, score)
  }
  div(
    class="bg-gray-100 font-inter p-10 flex flex-col items-center gap-10 min-h-screen",
    [view],
  )
}

///|
fn main {
  let model : Model = { score: { max_score: 0, min_score: 0 }, screen: Home }
  @tea.startup(model~, update~, view~)
}
