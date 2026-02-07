///|
priv struct Rule {
  input : String
  output : String
  nextInput : String?
}

///|
struct ProcessOutput {
  buffer : String
  output : String
} derive(Eq, Show)

///|
fn build_rules_by_input() -> Map[String, Array[Rule]] {
  let rules_by_input : Map[String, Array[Rule]] = Map::new()
  for rule in table {
    match rules_by_input.get(rule.input) {
      None => rules_by_input.set(rule.input, [rule])
      Some(rules) => rules.push(rule)
    }
  }
  rules_by_input
}

///|
fn build_rules_by_prefix() -> Map[String, Array[Rule]] {
  let rules_by_prefix : Map[String, Array[Rule]] = Map::new()
  for rule in table {
    let mut prefix = ""
    for ch in rule.input.iter() {
      prefix += ch.to_string()
      match rules_by_prefix.get(prefix) {
        None => rules_by_prefix.set(prefix, [rule])
        Some(rules) => rules.push(rule)
      }
    }
  }
  rules_by_prefix
}

///|
let rules_by_input : Map[String, Array[Rule]] = build_rules_by_input()

///|
let rules_by_prefix : Map[String, Array[Rule]] = build_rules_by_prefix()

///|
fn findRules(input : String) -> Array[Rule] {
  match rules_by_input.get(input) {
    None => []
    Some(rules) => rules
  }
}

///|
fn findRulesByPrefix(input : String) -> Array[Rule] {
  match rules_by_prefix.get(input) {
    None => []
    Some(rules) => rules
  }
}

///|
fn optionToString(option : String?) -> String {
  match option {
    Some(x) => x
    None => ""
  }
}

///|
fn process(buffer : String, key : Char) -> ProcessOutput {
  // 現在の入力バッファーがbufferで、keyを押したときの処理を書く
  let newBuffer = buffer + key.to_string()
  let rules = findRules(newBuffer)
  if rules.length() > 0 {
    // バッファーに合致するルールがある場合
    let prefixRules = findRulesByPrefix(newBuffer)
    if prefixRules.length() > rules.length() {
      // 完全一致だけでなく前方一致もある場合は保留する（例: "n" -> "na" 等）
      return { output: "", buffer: newBuffer }
    }
    if rules.length() == 1 {
      // 合致するルールが1つだけ→それを使って変換する
      let rule = rules[0]
      return { output: rule.output, buffer: optionToString(rule.nextInput) }
    } else {
      // それ以外の場合→保留する
      return { output: "", buffer: newBuffer }
    }
  } else {
    // バッファーに合致するルールがない場合
    let prefixRules = findRulesByPrefix(newBuffer)
    if prefixRules.length() > 0 {
      // 前方一致するルールがある場合→保留する
      return { output: "", buffer: newBuffer }
    } else {
      // 完全一致、前方一致がともにない場合は、変換する
      // nk → んk のような場合
      let mut output = ""
      let mut buffer = ""
      match newBuffer[:] {
        [] => return { buffer: newBuffer, output: "" }
        [first, .. rest] => {
          let buffer_left = first.to_string()
          let buffer_right = rest.to_string()
          let rules = findRules(buffer_left)
          if rules.length() > 0 {
            let rule = rules[0]
            output += rule.output
            buffer += optionToString(rule.nextInput)
          } else {
            output += newBuffer
          }
          buffer += buffer_right
          return { buffer, output }
        }
      }
    }
  }
}

///|
fn process_keys(keys : String) -> ProcessOutput {
  let mut buffer = ""
  let mut output = ""
  for key in keys.iter() {
    let result = process(buffer, key)
    output += result.output
    buffer = result.buffer
  }
  return { buffer, output }
}

///|
test "process / aiueo -> あいうえお" {
  assert_eq(process_keys("aiueo"), { output: "あいうえお", buffer: "" })
}

///|
test "process / kakikukeko -> かきくけこ" {
  assert_eq(process_keys("kakikukeko"), {
    output: "かきくけこ",
    buffer: "",
  })
}

///|
test "process / sanka -> さんか" {
  assert_eq(process_keys("sanka"), { output: "さんか", buffer: "" })
}

///|
test "process / si, shi -> し" {
  assert_eq(process_keys("si"), { output: "し", buffer: "" })
  assert_eq(process_keys("shi"), { output: "し", buffer: "" })
}

///|
test "process / tu, tsu -> つ" {
  assert_eq(process_keys("tu"), { output: "つ", buffer: "" })
  assert_eq(process_keys("tsu"), { output: "つ", buffer: "" })
}

///|
test "process / sya, sha, sixya, silya -> しゃ" {
  assert_eq(process_keys("sya"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("sha"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("sixya"), { output: "しゃ", buffer: "" })
  assert_eq(process_keys("silya"), { output: "しゃ", buffer: "" })
}

///|
test "process / u, wu, whu -> う" {
  assert_eq(process_keys("u"), { output: "う", buffer: "" })
  assert_eq(process_keys("wu"), { output: "う", buffer: "" })
  assert_eq(process_keys("whu"), { output: "う", buffer: "" })
}

///|
test "process / i, yi -> い" {
  assert_eq(process_keys("i"), { output: "い", buffer: "" })
  // assert_eq(process_keys("yi"), { output: "い", buffer: "" })
}

///|
test "process / tta, ltuta, xtuta -> った" {
  assert_eq(process_keys("tta"), { output: "った", buffer: "" })
  assert_eq(process_keys("ltuta"), { output: "った", buffer: "" })
  assert_eq(process_keys("xtuta"), { output: "った", buffer: "" })
}

///|
let table : Array[Rule] = [
  { input: "-", output: "ー", nextInput: None },
  { input: "va", output: "ゔぁ", nextInput: None },
  { input: "va", output: "ゔぁ", nextInput: None },
  { input: "vi", output: "ゔぃ", nextInput: None },
  { input: "vu", output: "ゔ", nextInput: None },
  { input: "ve", output: "ゔぇ", nextInput: None },
  { input: "vo", output: "ゔぉ", nextInput: None },
  { input: "vya", output: "ゔゃ", nextInput: None },
  { input: "vyi", output: "ゔぃ", nextInput: None },
  { input: "vyu", output: "ゔゅ", nextInput: None },
  { input: "vye", output: "ゔぇ", nextInput: None },
  { input: "vyo", output: "ゔょ", nextInput: None },
  { input: "qq", output: "っ", nextInput: Some("q") },
  { input: "vv", output: "っ", nextInput: Some("v") },
  { input: "ll", output: "っ", nextInput: Some("l") },
  { input: "xx", output: "っ", nextInput: Some("x") },
  { input: "kk", output: "っ", nextInput: Some("k") },
  { input: "gg", output: "っ", nextInput: Some("g") },
  { input: "ss", output: "っ", nextInput: Some("s") },
  { input: "zz", output: "っ", nextInput: Some("z") },
  { input: "jj", output: "っ", nextInput: Some("j") },
  { input: "tt", output: "っ", nextInput: Some("t") },
  { input: "tch", output: "っ", nextInput: Some("ch") },
  { input: "dd", output: "っ", nextInput: Some("d") },
  { input: "hh", output: "っ", nextInput: Some("h") },
  { input: "ff", output: "っ", nextInput: Some("f") },
  { input: "bb", output: "っ", nextInput: Some("b") },
  { input: "pp", output: "っ", nextInput: Some("p") },
  { input: "mm", output: "っ", nextInput: Some("m") },
  { input: "yy", output: "っ", nextInput: Some("y") },
  { input: "rr", output: "っ", nextInput: Some("r") },
  { input: "ww", output: "っ", nextInput: Some("w") },
  { input: "www", output: "w", nextInput: Some("ww") },
  { input: "cc", output: "っ", nextInput: Some("c") },
  { input: "kya", output: "きゃ", nextInput: None },
  { input: "kyi", output: "きぃ", nextInput: None },
  { input: "kyu", output: "きゅ", nextInput: None },
  { input: "kye", output: "きぇ", nextInput: None },
  { input: "kyo", output: "きょ", nextInput: None },
  { input: "gya", output: "ぎゃ", nextInput: None },
  { input: "gyi", output: "ぎぃ", nextInput: None },
  { input: "gyu", output: "ぎゅ", nextInput: None },
  { input: "gye", output: "ぎぇ", nextInput: None },
  { input: "gyo", output: "ぎょ", nextInput: None },
  { input: "sya", output: "しゃ", nextInput: None },
  { input: "syi", output: "しぃ", nextInput: None },
  { input: "syu", output: "しゅ", nextInput: None },
  { input: "sye", output: "しぇ", nextInput: None },
  { input: "syo", output: "しょ", nextInput: None },
  { input: "sha", output: "しゃ", nextInput: None },
  { input: "shi", output: "し", nextInput: None },
  { input: "shu", output: "しゅ", nextInput: None },
  { input: "she", output: "しぇ", nextInput: None },
  { input: "sho", output: "しょ", nextInput: None },
  { input: "zya", output: "じゃ", nextInput: None },
  { input: "zyi", output: "じぃ", nextInput: None },
  { input: "zyu", output: "じゅ", nextInput: None },
  { input: "zye", output: "じぇ", nextInput: None },
  { input: "zyo", output: "じょ", nextInput: None },
  { input: "tya", output: "ちゃ", nextInput: None },
  { input: "tyi", output: "ちぃ", nextInput: None },
  { input: "tyu", output: "ちゅ", nextInput: None },
  { input: "tye", output: "ちぇ", nextInput: None },
  { input: "tyo", output: "ちょ", nextInput: None },
  { input: "cha", output: "ちゃ", nextInput: None },
  { input: "chi", output: "ち", nextInput: None },
  { input: "chu", output: "ちゅ", nextInput: None },
  { input: "che", output: "ちぇ", nextInput: None },
  { input: "cho", output: "ちょ", nextInput: None },
  { input: "cya", output: "ちゃ", nextInput: None },
  { input: "cyi", output: "ちぃ", nextInput: None },
  { input: "cyu", output: "ちゅ", nextInput: None },
  { input: "cye", output: "ちぇ", nextInput: None },
  { input: "cyo", output: "ちょ", nextInput: None },
  { input: "dya", output: "ぢゃ", nextInput: None },
  { input: "dyi", output: "ぢぃ", nextInput: None },
  { input: "dyu", output: "ぢゅ", nextInput: None },
  { input: "dye", output: "ぢぇ", nextInput: None },
  { input: "dyo", output: "ぢょ", nextInput: None },
  { input: "tsa", output: "つぁ", nextInput: None },
  { input: "tsi", output: "つぃ", nextInput: None },
  { input: "tse", output: "つぇ", nextInput: None },
  { input: "tso", output: "つぉ", nextInput: None },
  { input: "tha", output: "てゃ", nextInput: None },
  { input: "thi", output: "てぃ", nextInput: None },
  { input: "t'i", output: "てぃ", nextInput: None },
  { input: "thu", output: "てゅ", nextInput: None },
  { input: "the", output: "てぇ", nextInput: None },
  { input: "tho", output: "てょ", nextInput: None },
  { input: "t'yu", output: "てゅ", nextInput: None },
  { input: "dha", output: "でゃ", nextInput: None },
  { input: "dhi", output: "でぃ", nextInput: None },
  { input: "d'i", output: "でぃ", nextInput: None },
  { input: "dhu", output: "でゅ", nextInput: None },
  { input: "dhe", output: "でぇ", nextInput: None },
  { input: "dho", output: "でょ", nextInput: None },
  { input: "d'yu", output: "でゅ", nextInput: None },
  { input: "twa", output: "とぁ", nextInput: None },
  { input: "twi", output: "とぃ", nextInput: None },
  { input: "twu", output: "とぅ", nextInput: None },
  { input: "twe", output: "とぇ", nextInput: None },
  { input: "two", output: "とぉ", nextInput: None },
  { input: "t'u", output: "とぅ", nextInput: None },
  { input: "dwa", output: "どぁ", nextInput: None },
  { input: "dwi", output: "どぃ", nextInput: None },
  { input: "dwu", output: "どぅ", nextInput: None },
  { input: "dwe", output: "どぇ", nextInput: None },
  { input: "dwo", output: "どぉ", nextInput: None },
  { input: "d'u", output: "どぅ", nextInput: None },
  { input: "nya", output: "にゃ", nextInput: None },
  { input: "nyi", output: "にぃ", nextInput: None },
  { input: "nyu", output: "にゅ", nextInput: None },
  { input: "nye", output: "にぇ", nextInput: None },
  { input: "nyo", output: "にょ", nextInput: None },
  { input: "hya", output: "ひゃ", nextInput: None },
  { input: "hyi", output: "ひぃ", nextInput: None },
  { input: "hyu", output: "ひゅ", nextInput: None },
  { input: "hye", output: "ひぇ", nextInput: None },
  { input: "hyo", output: "ひょ", nextInput: None },
  { input: "bya", output: "びゃ", nextInput: None },
  { input: "byi", output: "びぃ", nextInput: None },
  { input: "byu", output: "びゅ", nextInput: None },
  { input: "bye", output: "びぇ", nextInput: None },
  { input: "byo", output: "びょ", nextInput: None },
  { input: "pya", output: "ぴゃ", nextInput: None },
  { input: "pyi", output: "ぴぃ", nextInput: None },
  { input: "pyu", output: "ぴゅ", nextInput: None },
  { input: "pye", output: "ぴぇ", nextInput: None },
  { input: "pyo", output: "ぴょ", nextInput: None },
  { input: "fa", output: "ふぁ", nextInput: None },
  { input: "fi", output: "ふぃ", nextInput: None },
  { input: "fu", output: "ふ", nextInput: None },
  { input: "fe", output: "ふぇ", nextInput: None },
  { input: "fo", output: "ふぉ", nextInput: None },
  { input: "fya", output: "ふゃ", nextInput: None },
  { input: "fyu", output: "ふゅ", nextInput: None },
  { input: "fyo", output: "ふょ", nextInput: None },
  { input: "hwa", output: "ふぁ", nextInput: None },
  { input: "hwi", output: "ふぃ", nextInput: None },
  { input: "hwe", output: "ふぇ", nextInput: None },
  { input: "hwo", output: "ふぉ", nextInput: None },
  { input: "hwyu", output: "ふゅ", nextInput: None },
  { input: "mya", output: "みゃ", nextInput: None },
  { input: "myi", output: "みぃ", nextInput: None },
  { input: "myu", output: "みゅ", nextInput: None },
  { input: "mye", output: "みぇ", nextInput: None },
  { input: "myo", output: "みょ", nextInput: None },
  { input: "rya", output: "りゃ", nextInput: None },
  { input: "ryi", output: "りぃ", nextInput: None },
  { input: "ryu", output: "りゅ", nextInput: None },
  { input: "rye", output: "りぇ", nextInput: None },
  { input: "ryo", output: "りょ", nextInput: None },
  { input: "n'", output: "ん", nextInput: None },
  { input: "nn", output: "ん", nextInput: None },
  { input: "n", output: "ん", nextInput: None },
  { input: "xn", output: "ん", nextInput: None },
  { input: "a", output: "あ", nextInput: None },
  { input: "i", output: "い", nextInput: None },
  { input: "u", output: "う", nextInput: None },
  { input: "wu", output: "う", nextInput: None },
  { input: "e", output: "え", nextInput: None },
  { input: "o", output: "お", nextInput: None },
  { input: "xa", output: "ぁ", nextInput: None },
  { input: "xi", output: "ぃ", nextInput: None },
  { input: "xu", output: "ぅ", nextInput: None },
  { input: "xe", output: "ぇ", nextInput: None },
  { input: "xo", output: "ぉ", nextInput: None },
  { input: "la", output: "ぁ", nextInput: None },
  { input: "li", output: "ぃ", nextInput: None },
  { input: "lu", output: "ぅ", nextInput: None },
  { input: "le", output: "ぇ", nextInput: None },
  { input: "lo", output: "ぉ", nextInput: None },
  { input: "lyi", output: "ぃ", nextInput: None },
  { input: "xyi", output: "ぃ", nextInput: None },
  { input: "lye", output: "ぇ", nextInput: None },
  { input: "xye", output: "ぇ", nextInput: None },
  { input: "ye", output: "いぇ", nextInput: None },
  { input: "ka", output: "か", nextInput: None },
  { input: "ki", output: "き", nextInput: None },
  { input: "ku", output: "く", nextInput: None },
  { input: "ke", output: "け", nextInput: None },
  { input: "ko", output: "こ", nextInput: None },
  { input: "xka", output: "ヵ", nextInput: None },
  { input: "xke", output: "ヶ", nextInput: None },
  { input: "lka", output: "ヵ", nextInput: None },
  { input: "lke", output: "ヶ", nextInput: None },
  { input: "ga", output: "が", nextInput: None },
  { input: "gi", output: "ぎ", nextInput: None },
  { input: "gu", output: "ぐ", nextInput: None },
  { input: "ge", output: "げ", nextInput: None },
  { input: "go", output: "ご", nextInput: None },
  { input: "sa", output: "さ", nextInput: None },
  { input: "si", output: "し", nextInput: None },
  { input: "su", output: "す", nextInput: None },
  { input: "se", output: "せ", nextInput: None },
  { input: "so", output: "そ", nextInput: None },
  { input: "ca", output: "か", nextInput: None },
  { input: "ci", output: "し", nextInput: None },
  { input: "cu", output: "く", nextInput: None },
  { input: "ce", output: "せ", nextInput: None },
  { input: "co", output: "こ", nextInput: None },
  { input: "qa", output: "くぁ", nextInput: None },
  { input: "qi", output: "くぃ", nextInput: None },
  { input: "qu", output: "く", nextInput: None },
  { input: "qe", output: "くぇ", nextInput: None },
  { input: "qo", output: "くぉ", nextInput: None },
  { input: "kwa", output: "くぁ", nextInput: None },
  { input: "kwi", output: "くぃ", nextInput: None },
  { input: "kwu", output: "くぅ", nextInput: None },
  { input: "kwe", output: "くぇ", nextInput: None },
  { input: "kwo", output: "くぉ", nextInput: None },
  { input: "gwa", output: "ぐぁ", nextInput: None },
  { input: "gwi", output: "ぐぃ", nextInput: None },
  { input: "gwu", output: "ぐぅ", nextInput: None },
  { input: "gwe", output: "ぐぇ", nextInput: None },
  { input: "gwo", output: "ぐぉ", nextInput: None },
  { input: "swa", output: "すぁ", nextInput: None },
  { input: "swi", output: "すぃ", nextInput: None },
  { input: "swu", output: "すぅ", nextInput: None },
  { input: "swe", output: "すぇ", nextInput: None },
  { input: "swo", output: "すぉ", nextInput: None },
  { input: "zwa", output: "ずぁ", nextInput: None },
  { input: "zwi", output: "ずぃ", nextInput: None },
  { input: "zwu", output: "ずぅ", nextInput: None },
  { input: "zwe", output: "ずぇ", nextInput: None },
  { input: "zwo", output: "ずぉ", nextInput: None },
  { input: "za", output: "ざ", nextInput: None },
  { input: "zi", output: "じ", nextInput: None },
  { input: "zu", output: "ず", nextInput: None },
  { input: "ze", output: "ぜ", nextInput: None },
  { input: "zo", output: "ぞ", nextInput: None },
  { input: "ja", output: "じゃ", nextInput: None },
  { input: "ji", output: "じ", nextInput: None },
  { input: "ju", output: "じゅ", nextInput: None },
  { input: "je", output: "じぇ", nextInput: None },
  { input: "jo", output: "じょ", nextInput: None },
  { input: "jya", output: "じゃ", nextInput: None },
  { input: "jyi", output: "じぃ", nextInput: None },
  { input: "jyu", output: "じゅ", nextInput: None },
  { input: "jye", output: "じぇ", nextInput: None },
  { input: "jyo", output: "じょ", nextInput: None },
  { input: "ta", output: "た", nextInput: None },
  { input: "ti", output: "ち", nextInput: None },
  { input: "tu", output: "つ", nextInput: None },
  { input: "tsu", output: "つ", nextInput: None },
  { input: "te", output: "て", nextInput: None },
  { input: "to", output: "と", nextInput: None },
  { input: "da", output: "だ", nextInput: None },
  { input: "di", output: "ぢ", nextInput: None },
  { input: "du", output: "づ", nextInput: None },
  { input: "de", output: "で", nextInput: None },
  { input: "do", output: "ど", nextInput: None },
  { input: "xtu", output: "っ", nextInput: None },
  { input: "xtsu", output: "っ", nextInput: None },
  { input: "ltu", output: "っ", nextInput: None },
  { input: "ltsu", output: "っ", nextInput: None },
  { input: "na", output: "な", nextInput: None },
  { input: "ni", output: "に", nextInput: None },
  { input: "nu", output: "ぬ", nextInput: None },
  { input: "ne", output: "ね", nextInput: None },
  { input: "no", output: "の", nextInput: None },
  { input: "ha", output: "は", nextInput: None },
  { input: "hi", output: "ひ", nextInput: None },
  { input: "hu", output: "ふ", nextInput: None },
  { input: "fu", output: "ふ", nextInput: None },
  { input: "he", output: "へ", nextInput: None },
  { input: "ho", output: "ほ", nextInput: None },
  { input: "ba", output: "ば", nextInput: None },
  { input: "bi", output: "び", nextInput: None },
  { input: "bu", output: "ぶ", nextInput: None },
  { input: "be", output: "べ", nextInput: None },
  { input: "bo", output: "ぼ", nextInput: None },
  { input: "pa", output: "ぱ", nextInput: None },
  { input: "pi", output: "ぴ", nextInput: None },
  { input: "pu", output: "ぷ", nextInput: None },
  { input: "pe", output: "ぺ", nextInput: None },
  { input: "po", output: "ぽ", nextInput: None },
  { input: "ma", output: "ま", nextInput: None },
  { input: "mi", output: "み", nextInput: None },
  { input: "mu", output: "む", nextInput: None },
  { input: "me", output: "め", nextInput: None },
  { input: "mo", output: "も", nextInput: None },
  { input: "xya", output: "ゃ", nextInput: None },
  { input: "lya", output: "ゃ", nextInput: None },
  { input: "ya", output: "や", nextInput: None },
  { input: "wyi", output: "ゐ", nextInput: None },
  { input: "xyu", output: "ゅ", nextInput: None },
  { input: "lyu", output: "ゅ", nextInput: None },
  { input: "yu", output: "ゆ", nextInput: None },
  { input: "wye", output: "ゑ", nextInput: None },
  { input: "xyo", output: "ょ", nextInput: None },
  { input: "lyo", output: "ょ", nextInput: None },
  { input: "yo", output: "よ", nextInput: None },
  { input: "ra", output: "ら", nextInput: None },
  { input: "ri", output: "り", nextInput: None },
  { input: "ru", output: "る", nextInput: None },
  { input: "re", output: "れ", nextInput: None },
  { input: "ro", output: "ろ", nextInput: None },
  { input: "xwa", output: "ゎ", nextInput: None },
  { input: "lwa", output: "ゎ", nextInput: None },
  { input: "wa", output: "わ", nextInput: None },
  { input: "wi", output: "うぃ", nextInput: None },
  { input: "we", output: "うぇ", nextInput: None },
  { input: "wo", output: "を", nextInput: None },
  { input: "wha", output: "うぁ", nextInput: None },
  { input: "whi", output: "うぃ", nextInput: None },
  { input: "whu", output: "う", nextInput: None },
  { input: "whe", output: "うぇ", nextInput: None },
  { input: "who", output: "うぉ", nextInput: None },
]
