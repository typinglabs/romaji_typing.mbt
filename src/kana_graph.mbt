///|
priv struct Node {
  // どこまで入力したか
  kana_index : Int
  // 未変換の文字列
  buffer : String
}

///|
type NodeId = String

///|
fn get_node_id(node : Node) -> NodeId {
  return "\{node.kana_index}|\{node.buffer}"
}

///|
priv suberror NodeIdParseError

///|
fn from_node_id(node_id : String) -> Node raise Error {
  match node_id.split("|").collect() {
    [kana_index_str, buffer] =>
      {
        kana_index: @strconv.parse_int(kana_index_str),
        buffer: buffer.to_string(),
      }
    _ => raise NodeIdParseError
  }
}

///|
struct Edge {
  to : NodeId
  pressed_key : Char
} derive(Show)

///|
type Graph = Map[NodeId, Array[Edge]]

///|
fn build_graph_from_kana_with_dist(
  kana : String,
) -> (Graph, Map[NodeId, Int]) raise Error {
  let graph : Graph = Map::new()
  let start_node : Node = { kana_index: 0, buffer: "" }
  let view = kana[:]
  let len = view.length()

  // 幅優先探索する
  let queue = @queue.new()
  let visited : Map[NodeId, Bool] = Map::new()
  queue.push(start_node)
  while queue.pop() is Some(node) {
    let node_id = get_node_id(node)
    if visited.contains(node_id) {
      continue
    }
    visited[node_id] = true

    // 遷移
    for key = 'a'; key <= 'z'; key = Int::unsafe_to_char(key.to_int() + 1) {
      let result = process(node.buffer, key)

      // result.outputが、kanaに一致していることが必要条件
      guard node.kana_index <= len else {
        abort("kana_index out of range: \{node.kana_index} > \{len}")
      }
      let ok = view[node.kana_index:].has_prefix(result.output)
      if !ok {
        continue
      }

      // 逆向きに辺を張る next_node -> node
      let advance = result.output[:].length()
      let next_node : Node = {
        buffer: result.buffer,
        kana_index: node.kana_index + advance,
      }
      let next_node_id = get_node_id(next_node)
      let edge : Edge = { to: node_id, pressed_key: key }
      match graph.get(next_node_id) {
        None => graph.set(next_node_id, [edge])
        Some(edges) => edges.push(edge)
      }

      // next_nodeをキューに追加
      if !visited.contains(next_node_id) {
        queue.push(next_node)
      }
    }
  }

  // ゴールから逆向きに辿って、有効な頂点のみを残す + 最短距離を計算
  let graph_normal : Graph = Map::new()
  let start_node : Node = { kana_index: len, buffer: "" }
  let queue = @queue.new()
  let visited_reverse : Map[NodeId, Bool] = Map::new()
  let dist : Map[NodeId, Int] = Map::new()
  dist[get_node_id(start_node)] = 0
  queue.push(start_node)
  while queue.pop() is Some(node) {
    let from = get_node_id(node)
    if visited_reverse.contains(from) {
      continue
    }
    visited_reverse[from] = true
    let edges = match graph.get(from) {
      None => continue
      Some(edges) => edges
    }
    let from_dist = match dist.get(from) {
      None => abort("distance missing for node: \{from}")
      Some(value) => value
    }
    for edge in edges {
      // edge.to -> node
      let reverse_edge : Edge = { ..edge, to: from }
      match graph_normal.get(edge.to) {
        None => graph_normal.set(edge.to, [reverse_edge])
        Some(edges) => edges.push(reverse_edge)
      }
      if !dist.contains(edge.to) {
        dist[edge.to] = from_dist + 1
      }
      queue.push(from_node_id(edge.to))
    }
  }
  return (graph_normal, dist)
}

///|
fn shortest_path(
  graph : Graph,
  dist : Map[NodeId, Int],
  start : NodeId,
  goal : NodeId,
) -> Array[Edge] {
  let path : Array[Edge] = []
  let mut current = start
  while current != goal {
    let current_dist = match dist.get(current) {
      None => abort("distance missing for node: \{current}")
      Some(value) => value
    }
    let edges = match graph.get(current) {
      None => abort("graph missing node: \{current}")
      Some(edges) => edges
    }
    let mut moved = false
    for edge in edges {
      match dist.get(edge.to) {
        Some(next_dist) if next_dist == current_dist - 1 => {
          path.push(edge)
          current = edge.to
          moved = true
          break
        }
        _ => ()
      }
    }
    guard moved else { abort("no shortest edge found from: \{current}") }
  }
  path
}

///|
fn edges_to_string(edges : Array[Edge]) -> String {
  let mut result = ""
  for edge in edges {
    result += edge.pressed_key.to_string()
  }
  result
}

///|
test "build_kana_graph" {
  let (graph, dist) = build_graph_from_kana_with_dist("きゅう")
  inspect(
    graph,
    content=(
      #|{"2|": [{to: "3|", pressed_key: 'u'}, {to: "2|w", pressed_key: 'w'}], "2|w": [{to: "3|", pressed_key: 'u'}, {to: "2|wh", pressed_key: 'h'}], "2|wh": [{to: "3|", pressed_key: 'u'}], "0|ky": [{to: "2|", pressed_key: 'u'}], "1|ly": [{to: "2|", pressed_key: 'u'}], "1|xy": [{to: "2|", pressed_key: 'u'}], "0|k": [{to: "0|ky", pressed_key: 'y'}, {to: "1|", pressed_key: 'i'}], "1|l": [{to: "1|ly", pressed_key: 'y'}], "1|x": [{to: "1|xy", pressed_key: 'y'}], "0|": [{to: "0|k", pressed_key: 'k'}], "1|": [{to: "1|l", pressed_key: 'l'}, {to: "1|x", pressed_key: 'x'}]}
    ),
  )
  inspect(
    dist,
    content=(
      #|{"3|": 0, "2|": 1, "2|w": 1, "2|wh": 1, "0|ky": 2, "1|ly": 2, "1|xy": 2, "0|k": 3, "1|l": 3, "1|x": 3, "0|": 4, "1|": 4}
    ),
  )
  let path = shortest_path(graph, dist, "0|", "3|")
  let roman = edges_to_string(path)
  inspect(
    path,
    content=(
      #|[{to: "0|k", pressed_key: 'k'}, {to: "0|ky", pressed_key: 'y'}, {to: "2|", pressed_key: 'u'}, {to: "3|", pressed_key: 'u'}]
    ),
  )
  inspect(roman, content="kyuu")
}
