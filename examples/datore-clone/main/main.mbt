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
struct HomeViewModel {
  hits : Int
  misses : Int
  time_left : Int
  max_score : Int
  min_score : Int
}

///|
struct TypingViewModel {
  hits : Int
  misses : Int
  time_left : Int
  typing_state : TypingState
  max_score : Int
  min_score : Int
}

///|
struct TypingState {
  typed_romaji : String
  remaining_romaji : String
  typed_kanji : String
  remaining_kanji : String
}

///|
struct CountdownViewModel {
  count : Int
  max_score : Int
  min_score : Int
}

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
fn start_view(model : HomeViewModel) -> Html[Msg] {
  div([
    h2(class="text-lg font-bold mb-2", [text("スタート画面")]),
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.hits.to_string()),
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
                text(model.misses.to_string()),
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
                text(model.time_left.to_string()),
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
      div(
        class="w-full h-[60px] bg-[#DDDDDD] flex items-center justify-between px-5",
        [
          div(class="flex items-center gap-5", [
            span(class="text-[18px]", [text("Max： \{model.max_score}")]),
            span(class="text-[18px]", [text("Min： \{model.min_score}")]),
          ]),
          div(
            class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
            [
              span(class="text-[16px] font-bold text-white", [
                text("スタート (Enter)"),
              ]),
            ],
          ),
        ],
      ),
    ]),
  ])
}

///|
fn typing_view(model : TypingViewModel) -> Html[Msg] {
  let typing_state = model.typing_state
  div([
    h2(class="text-lg font-bold mb-2", [text("タイピング画面")]),
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.hits.to_string()),
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
                text(model.misses.to_string()),
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
                text(model.time_left.to_string()),
              ]),
            ],
          ),
          span(class="text-[22px] whitespace-nowrap", [text("残り時間")]),
        ]),
      ]),
      div(
        class="w-full h-[70px] bg-white flex flex-col justify-center px-[30px]",
        [
          div(class="flex items-center", [
            span(class="text-[28px] font-bold text-[#999999]", [
              text(typing_state.typed_kanji),
            ]),
            span(class="text-[28px] font-bold text-black", [
              text(typing_state.remaining_kanji),
            ]),
          ]),
        ],
      ),
      div(class="w-full h-[70px] bg-white flex items-center px-[30px] py-5", [
        div(class="flex items-center", [
          span(class="text-[24px] text-[#999999]", [
            text(typing_state.typed_romaji),
          ]),
          // TODO:
          span(class="text-[28px] font-bold text-red-500", [text("d")]),
          span(class="text-[24px] text-[#333333]", [
            text(typing_state.remaining_romaji),
          ]),
        ]),
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

///|
fn result_view(model : ResultViewModel) -> Html[Msg] {
  div([
    h2(class="text-lg font-bold mb-2", [text("終了画面")]),
    div(class="w-[950px] bg-[#CCCCCC] p-5 flex flex-col gap-5", [
      div(class="flex justify-around items-center h-[80px] px-5", [
        div(class="flex shrink-0 items-center gap-3 w-[200px]", [
          div(
            class="w-[150px] h-[60px] bg-white rounded-lg flex items-center justify-center shrink-0",
            [
              span(class="text-[36px] font-bold text-gray-500", [
                text(model.hits.to_string()),
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
                text(model.misses.to_string()),
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
                text(model.time_left.to_string()),
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
            span(class="text-[20px] font-bold", [
              text("Time Out!! お疲れさまでした"),
            ]),
          ]),
        ],
      ),
      div(class="w-full h-[70px] bg-white flex items-center px-[30px] py-5", [
        span(class="text-[20px] font-bold", [
          text("苦手キー：\{weak_keys_to_string(model.weak_keys)}"),
        ]),
      ]),
      div(
        class="w-full h-[60px] bg-[#DDDDDD] flex items-center justify-between px-5",
        [
          div(class="flex items-center gap-5", [
            span(class="text-[18px]", [text("Max： \{model.max_score}")]),
            span(class="text-[18px]", [text("Min： \{model.min_score}")]),
          ]),
          div(
            class="w-[200px] h-[40px] bg-[#4B5563] rounded-md flex items-center justify-center cursor-pointer",
            [
              span(class="text-[16px] font-bold text-white", [
                text("リスタート (Esc)"),
              ]),
            ],
          ),
        ],
      ),
    ]),
  ])
}

///|
fn view(model : Model) -> Html[Msg] {
  let view = match model {
    Home(model) => start_view(model)
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
