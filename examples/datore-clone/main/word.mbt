///|
struct Word {
  display : String
  items : Array[@typing.KanjiOrKana]
}

///|
fn is_hiragana(ch : Char) -> Bool {
  (ch >= 'ぁ' && ch <= 'ゖ') || ch == 'ー'
}

///|
fn is_katakana(ch : Char) -> Bool {
  (ch >= 'ァ' && ch <= 'ヶ')
}

///|
fn katakana_to_hiragana(ch : Char) -> Char {
  if is_katakana(ch) {
    (ch.to_int() - 0x60).unsafe_to_char()
  } else {
    ch
  }
}

///|
fn parse_annotated_word(annotated : String) -> Word {
  let items : Array[@typing.KanjiOrKana] = []
  let display_chars : Array[Char] = []
  let chars : Array[Char] = []
  for ch in annotated.iter() {
    chars.push(ch)
  }
  let mut i = 0
  while i < chars.length() {
    let ch = chars[i]
    if ch == '{' {
      i += 1
      continue
    }
    if ch == '}' {
      i += 1
      continue
    }
    if i + 1 < chars.length() && chars[i + 1] == '{' {
      let mut j = i + 2
      let mut reading = ""
      while j < chars.length() && chars[j] != '}' {
        reading += chars[j].to_string()
        j += 1
      }
      display_chars.push(ch)
      items.push(@typing.kanji(ch, reading))
      i = j + 1
      continue
    }
    display_chars.push(ch)
    if is_hiragana(ch) {
      items.push(@typing.kana(ch))
    } else if is_katakana(ch) {
      items.push(@typing.kana(katakana_to_hiragana(ch)))
    } else {
      items.push(@typing.kanji(ch, ""))
    }
    i += 1
  }
  let mut display = ""
  for ch in display_chars {
    display += ch.to_string()
  }
  { display, items }
}

///|
let words : Array[Word] = {
  let annotated_words : Array[String] = [
    "生{せい}活{かつ}していく中{なか}でインターネットはなくてはならない存{そん}在{ざい}になりました",
    "彼{かれ}なら完{かん}走{そう}する可{か}能{のう}性{せい}はあるがこの調{ちょう}子{し}なら時{じ}間{かん}がかかりそうだ",
    "正{せい}当{とう}な手{しゅ}段{だん}を選{せん}択{たく}するには資{し}料{りょう}の詳{しょう}細{さい}を参{さん}考{こう}にして相{そう}談{だん}しよう",
    "彼{かれ}は商{しょう}業{ぎょう}都{と}市{し}について調{ちょう}査{さ}要{よう}請{せい}を依{い}頼{らい}していたようだ",
    "その少{しょう}量{りょう}の装{そう}置{ち}を調{ちょう}整{せい}したければ課{か}長{ちょう}に相{そう}談{だん}してください",
    "校{こう}長{ちょう}先{せん}生{せい}と教{きょう}頭{とう}先{せん}生{せい}は今{こと}年{し}に定{てい}年{ねん}退{たい}職{しょく}するそうだ",
    "高{こう}速{そく}タイピングはサクサクと楽{らく}勝{しょう}すぎて何{なん}度{ど}も挑{ちょう}戦{せん}する",
    "小{しょう}学{がく}生{せい}は行{ぎょう}政{せい}法{ほう}を解{かい}読{どく}したことにワクワクした",
    "大{だい}学{がく}までの通{つう}学{がく}時{じ}間{かん}が異{い}様{よう}に長{なが}いのは気{き}のせいだろうか",
    "長{ちょう}文{ぶん}で父{とう}さんとの勝{しょう}負{ぶ}に勝{しょう}利{り}するため早{そう}朝{ちょう}から挑{ちょう}戦{せん}する",
    "消{しょう}防{ぼう}士{し}になるためには相{そう}当{とう}な苦{く}労{ろう}が必{ひつ}要{よう}とされています",
    "大{たい}切{せつ}な話{はなし}を伝{つた}えるためにはお互{たが}い相{あい}手{て}の目{め}を見{み}て話{はなし}をしよう",
    "何{なに}気{げ}なく人{にん}間{げん}は暮{くら}らしているが環{かん}境{きょう}は毎{まい}日{にち}汚{お}染{せん}されている",
    "面{めん}接{せつ}対{たい}策{さく}には前{まえ}もってやる擬{ぎ}似{じ}面{めん}接{せつ}を怠{おこた}らないようにしましょう",
    "視{し}力{りょく}が低{てい}下{か}してきた感{かん}じがしたためコンタクトを使{し}用{よう}することにしました",
    "あの映{えい}画{が}を鑑{かん}賞{しょう}したいなら監{かん}督{とく}からの承{しょう}諾{だく}を得{え}た方{ほう}がいいよ",
    "町{ちょう}長{ちょう}さんが市{し}長{ちょう}に相{そう}談{だん}したらそれに市{し}長{ちょう}は応{おう}じてくれなかった",
    "将{しょう}来{らい}の健{けん}康{こう}のためにジョギングをすることはすばらしいと感{かん}じています",
  ]
  let list : Array[Word] = []
  for w in annotated_words {
    list.push(parse_annotated_word(w))
  }
  list
}

///|
fn create_next_word_fn() -> () -> Word {
  let mut word_index = 0
  fn next_word() -> Word {
    let word = words[word_index]
    word_index += 1
    word
  }

  next_word
}

///|
let next_word : () -> Word = create_next_word_fn()
