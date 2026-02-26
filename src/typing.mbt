///|
/// Typing state for a kana input and its romaji progress.
pub struct TypingState {
  typed_romaji : String
  remaining_romaji : String
  typed_kana_len : Int
} derive(Show, Eq)

///|
/// Result of a key input.
pub enum TypingResult {
  CorrectKey // 正しいキーを入力
  WrongKey // 間違ったキーを入力
  WordCompleted // 正しいキーを入力して、完了
} derive(Show, Eq)

///|
pub struct TypingOptions {
  allow_single_n_at_word_end : Bool
} derive(Show, Eq)

///|
pub let default_typing_options : TypingOptions = {
  allow_single_n_at_word_end: false,
}

///|
/// Function that applies a key and returns next state and result.
pub type ApplyKeyFn = (Char) -> (TypingState, TypingResult) raise Error

///|
priv struct TypingEngine {
  graph : Graph
  dist : Map[NodeId, Int]
  current : NodeId
  goal : NodeId
  guide : Array[Edge]
}

///|
/// Create a typing engine for a kana string.
///
/// # Example
///
/// ```mbt check
/// test {
///   let (state, apply) = create_kana_engine("りんご")
///   inspect(state.remaining_romaji, content="ringo")
///   let (state, _result) = apply('r')
///   inspect(state.remaining_romaji, content="ingo")
/// }
/// ```
pub fn create_kana_engine(
  kana : String,
  options? : TypingOptions = default_typing_options,
) -> (TypingState, ApplyKeyFn) raise Error {
  let (graph, dist) = build_graph_from_kana_with_dist(kana, options~)
  let start_id = get_node_id({ kana_index: 0, buffer: "" })
  let goal_id = get_node_id({ kana_index: kana[:].length(), buffer: "" })
  let guide = shortest_path(graph, dist, start_id, goal_id)
  let mut engine : TypingEngine = {
    graph,
    dist,
    current: start_id,
    goal: goal_id,
    guide,
  }
  let initial_state : TypingState = {
    typed_romaji: "",
    remaining_romaji: edges_to_string(guide),
    typed_kana_len: 0,
  }
  let mut current_state = initial_state
  fn apply_key(key : Char) -> (TypingState, TypingResult) raise Error {

    // keyが正しいかどうか判定
    let mut next_edge = None
    let mut best_dist = 1_000_000_000
    for edge in engine.graph[engine.current] {
      if edge.pressed_key == key {
        let next_dist = match engine.dist.get(edge.to) {
          Some(value) => value
          None => continue
        }
        if next_dist < best_dist {
          best_dist = next_dist
          next_edge = Some(edge)
        }
      }
    }
    match next_edge {
      None => (current_state, WrongKey)
      Some(edge) => {
        let next_node = from_node_id(edge.to)
        let next_id = edge.to
        let mut guide = engine.guide
        if guide.length() > 0 &&
          guide[0].pressed_key == key &&
          guide[0].to == next_id {
          guide = guide[1:guide.length()].to_array()
        } else {
          guide = shortest_path(engine.graph, engine.dist, next_id, engine.goal)
        }
        engine = { ..engine, current: next_id, guide }

        // stateを更新する
        let next_state : TypingState = {
          typed_romaji: current_state.typed_romaji + key.to_string(),
          remaining_romaji: edges_to_string(guide),
          typed_kana_len: next_node.kana_index,
        }
        let result : TypingResult = if next_id == engine.goal {
          WordCompleted
        } else if next_node.kana_index < kana.length() {
          CorrectKey
        } else {
          WordCompleted
        }
        current_state = next_state
        (current_state, result)
      }
    }
  }

  return (initial_state, apply_key)
}

///|

///|
test "正解かどうかを判定できる きゅう -> kyuuは正解" {
  let kana = "きゅう"
  let (_initial_state, apply_key) = create_kana_engine(kana)

  // kyuuと入力する
  let (_state, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('y')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key('u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kilyuuは正解" {
  let kana = "きゅう"
  let (_initial_state, apply_key) = create_kana_engine(kana)

  // kilyuuと入力する
  let (_state, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('i')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('l')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('y')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key('u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kaは不正解" {
  let kana = "きゅう"
  let (_initial_state, apply_key) = create_kana_engine(kana)

  // kilyuuと入力する
  let (_, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key('a')
  assert_eq(result, WrongKey)
}

///|
test "入力したローマ字を取得できる きゅう -> kyuu" {
  let kana = "きゅう"
  let (_initial_state, apply_key) = create_kana_engine(kana)

  // kyuuと入力する
  let (state, _result) = apply_key('k')
  assert_eq(state.typed_romaji, "k")
  let (state, _result) = apply_key('y')
  assert_eq(state.typed_romaji, "ky")
  let (state, _result) = apply_key('u')
  assert_eq(state.typed_romaji, "kyu")
  let (state, _result) = apply_key('u')
  assert_eq(state.typed_romaji, "kyuu")
}

///|
test "remaining_romajiを取得できる きゅう -> kyuu" {
  let kana = "きゅう"
  let (state, apply_key) = create_kana_engine(kana)
  assert_eq(state.remaining_romaji, "kyuu")
  let (state, _) = apply_key('k')
  assert_eq(state.remaining_romaji, "yuu")
  let (state, _) = apply_key('y')
  assert_eq(state.remaining_romaji, "uu")
  let (state, _) = apply_key('u')
  assert_eq(state.remaining_romaji, "u")
  let (state, _) = apply_key('u')
  assert_eq(state.remaining_romaji, "")
}

///|
test "remaining_romajiを取得できる きゅう -> kilyuu" {
  let kana = "きゅう"
  let (_state, apply_key) = create_kana_engine(kana)
  let (state, _) = apply_key('k')
  assert_eq(state.remaining_romaji, "yuu")
  let (state, _) = apply_key('i')
  assert_eq(state.remaining_romaji, "lyuu")
  let (state, _) = apply_key('l')
  assert_eq(state.remaining_romaji, "yuu")
  let (state, _) = apply_key('y')
  assert_eq(state.remaining_romaji, "uu")
  let (state, _) = apply_key('u')
  assert_eq(state.remaining_romaji, "u")
  let (state, _) = apply_key('u')
  assert_eq(state.remaining_romaji, "")
}

///|
test "末尾のんをn1回で入力できる（option=true）" {
  let options = { allow_single_n_at_word_end: true }
  let (_state, apply_key) = create_kana_engine("かん", options~)
  let (_state, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('a')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('n')
  assert_eq(result, WordCompleted)
}

///|
test "末尾のんをn1回で入力できない（option=false）" {
  let (_state, apply_key) = create_kana_engine("かん")
  let (_state, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('a')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('n')
  assert_eq(result, CorrectKey)
}

///|
test "option=trueでも中間のんはn1回で確定しない" {
  let options = { allow_single_n_at_word_end: true }
  let (_state, apply_key) = create_kana_engine("かんい", options~)
  let (_state, result) = apply_key('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('a')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_key('n')
  assert_eq(result, CorrectKey)
}

///|
test "option=trueでも末尾のんをnn/xnで入力できる" {
  let options = { allow_single_n_at_word_end: true }

  // option=true では単一 n 完了経路が優先されるため、
  // nn はローマ字変換ルールとして維持されていることを確認する。
  assert_eq(process_keys("kann"), { output: "かん", buffer: "" })

  let (_state, apply_xn) = create_kana_engine("かん", options~)
  let (_state, result) = apply_xn('k')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_xn('a')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_xn('x')
  assert_eq(result, CorrectKey)
  let (_state, result) = apply_xn('n')
  assert_eq(result, WordCompleted)
}
