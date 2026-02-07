///|
pub struct RomanState {
  typed_roman : String
  remaining_roman : String
  typed_kana : String
  remaining_kana : String
} derive(Show, Eq)

///|
pub enum RomanResult {
  CorrectKey // 正しいキーを入力
  WrongKey // 間違ったキーを入力
  WordCompleted // 正しいキーを入力して、完了
} derive(Show, Eq)

///|
pub type ApplyKeyFn = (RomanState, Char) -> (RomanState, RomanResult) raise Error

///|
priv struct RomanEngine {
  graph : Graph
  dist : Map[NodeId, Int]
  current : NodeId
  goal : NodeId
  guide : Array[Edge]
}

///|
pub fn create_roman_engine(
  kana : String,
) -> (RomanState, ApplyKeyFn) raise Error {
  let (graph, dist) = build_graph_from_kana_with_dist(kana)
  let start_id = get_node_id({ kana_index: 0, buffer: "" })
  let goal_id = get_node_id({ kana_index: kana[:].length(), buffer: "" })
  let guide = shortest_path(graph, dist, start_id, goal_id)
  let mut engine : RomanEngine = {
    graph,
    dist,
    current: start_id,
    goal: goal_id,
    guide,
  }
  let initial_state : RomanState = {
    typed_roman: "",
    remaining_roman: edges_to_string(guide),
    typed_kana: "",
    remaining_kana: kana,
  }
  fn apply_key(
    state : RomanState,
    key : Char,
  ) -> (RomanState, RomanResult) raise Error {

    // keyが正しいかどうか判定
    let mut next_edge = None
    for edge in engine.graph[engine.current] {
      if edge.pressed_key == key {
        next_edge = Some(edge)
      }
    }
    match next_edge {
      None => (state, WrongKey)
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
        let view = kana[:]
        let next_state : RomanState = {
          typed_roman: state.typed_roman + key.to_string(),
          remaining_roman: edges_to_string(guide),
          typed_kana: view[0:next_node.kana_index].to_string(),
          remaining_kana: view[next_node.kana_index:].to_string(),
        }
        let result : RomanResult = if next_id == engine.goal {
          WordCompleted
        } else if next_node.kana_index < kana.length() {
          CorrectKey
        } else {
          WordCompleted
        }
        (next_state, result)
      }
    }
  }

  return (initial_state, apply_key)
}

///|

///|
test "正解かどうかを判定できる きゅう -> kyuuは正解" {
  let kana = "きゅう"
  let (initial_state, apply_key) = create_roman_engine(kana)

  // kyuuと入力する
  let (state, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'y')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(state, 'u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kilyuuは正解" {
  let kana = "きゅう"
  let (initial_state, apply_key) = create_roman_engine(kana)

  // kilyuuと入力する
  let (state, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'i')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'l')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'y')
  assert_eq(result, CorrectKey)
  let (state, result) = apply_key(state, 'u')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(state, 'u')
  assert_eq(result, WordCompleted)
}

///|
test "正解かどうか判定できる きゅう -> kaは不正解" {
  let kana = "きゅう"
  let (initial_state, apply_key) = create_roman_engine(kana)

  // kilyuuと入力する
  let (_, result) = apply_key(initial_state, 'k')
  assert_eq(result, CorrectKey)
  let (_, result) = apply_key(initial_state, 'a')
  assert_eq(result, WrongKey)
}

///|
test "入力したローマ字を取得できる きゅう -> kyuu" {
  let kana = "きゅう"
  let (initial_state, apply_key) = create_roman_engine(kana)

  // kyuuと入力する
  let (state, _result) = apply_key(initial_state, 'k')
  assert_eq(state.typed_roman, "k")
  let (state, _result) = apply_key(state, 'y')
  assert_eq(state.typed_roman, "ky")
  let (state, _result) = apply_key(state, 'u')
  assert_eq(state.typed_roman, "kyu")
  let (state, _result) = apply_key(state, 'u')
  assert_eq(state.typed_roman, "kyuu")
}

///|
test "remaining_romanを取得できる きゅう -> kyuu" {
  let kana = "きゅう"
  let (state, apply_key) = create_roman_engine(kana)
  assert_eq(state.remaining_roman, "kyuu")
  let (state, _) = apply_key(state, 'k')
  assert_eq(state.remaining_roman, "yuu")
  let (state, _) = apply_key(state, 'y')
  assert_eq(state.remaining_roman, "uu")
  let (state, _) = apply_key(state, 'u')
  assert_eq(state.remaining_roman, "u")
  let (state, _) = apply_key(state, 'u')
  assert_eq(state.remaining_roman, "")
}

///|
test "remaining_romanを取得できる きゅう -> kilyuu" {
  let kana = "きゅう"
  let (state, apply_key) = create_roman_engine(kana)
  let (state, _) = apply_key(state, 'k')
  assert_eq(state.remaining_roman, "yuu")
  let (state, _) = apply_key(state, 'i')
  assert_eq(state.remaining_roman, "lyuu")
  let (state, _) = apply_key(state, 'l')
  assert_eq(state.remaining_roman, "yuu")
  let (state, _) = apply_key(state, 'y')
  assert_eq(state.remaining_roman, "uu")
  let (state, _) = apply_key(state, 'u')
  assert_eq(state.remaining_roman, "u")
  let (state, _) = apply_key(state, 'u')
  assert_eq(state.remaining_roman, "")
}
