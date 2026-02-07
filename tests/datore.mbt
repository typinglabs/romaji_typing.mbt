///|
priv struct Word {
  kana : String
  roman : String
}

///|
let datore_words : ReadOnlyArray[Word] = [
  {
    kana: "せいかつしていくなかでいんたーねっとはなくてはならないそんざいになりました",
    roman: "seikatusiteikunakadeinta-nettohanakutehanaranaisonzaininarimasita",
  },
  {
    kana: "かれならかんそうするかのうせいがあるがこのちょうしならじかんがかかりそうだ",
    roman: "karenarakansousurukanouseigaarugakonotyousinarajikangakakarisouda",
  },
  {
    kana: "せいとうなしゅだんをせんたくするにはしりょうのしょうさいをさんこうにしてそうだんしよう",
    roman: "seitounasyudanwosentakusurunihasiryounosyousaiwosankounisitesoudansiyou",
  },
  {
    kana: "かれはしょうぎょうとしについてちょうさようせいをいらいしていたようだ",
    roman: "karehasyougyoutosinituitetyousayouseiwoiraisiteitayouda",
  },
  {
    kana: "そのしょうりょうのそうちをちょうせいしたければかちょうにそうだんしてください",
    roman: "sonosyouryounosoutiwotyouseisitakerebakatyounisoudansitekudasai",
  },
  {
    kana: "こうちょうせんせいときょうとうせんせいはことしにていねんたいしょくするそうだ",
    roman: "koutyousenseitokyoutousenseihakotosiniteinentaisyokusurusouda",
  },
  {
    kana: "こうそくたいぴんぐはさくさくとらくしょうすぎてなんどもちょうせんする",
    roman: "kousokutaipinguhasakusakutorakusyousugitenandomotyousensuru",
  },
  {
    kana: "しょうがくせいはぎょうせいほうをかいどくしたことにわくわくした",
    roman: "syougakuseihagyouseihouwokaidokusitakotoniwakuwakusita",
  },
  {
    kana: "だいがくまでのつうがくじかんがいようにながいのはきのせいだろうか",
    roman: "daigakumadenotuugakuzikangaiyouninagainohakinoseidarouka",
  },
  {
    kana: "ちょうぶんでとうさんとのしょうぶにしょうりするためそうちょうからちょうせんする",
    roman: "tyoubundetousantonosyoubunisyourisurutamesoutyoukaratyousensuru",
  },
  {
    kana: "しょうぼうしになるためにはそうとうなくろうがひつようとされています",
    roman: "syoubousininarutamenihasoutounakurougahituyoutosareteimasu",
  },
  {
    kana: "たいせつなはなしをつたえるためにはおたがいあいてのめをみてはなしをしよう",
    roman: "taisetunahanasiwotutaerutamenihaotagaiaitenomewomitehanasiwosiyou",
  },
  {
    kana: "なにげなくにんげんはくらしているがかんきょうはまいにちおせんされている",
    roman: "nanigenakuningenhakurasiteirugakankyouhamainitiosensareteiru",
  },
  {
    kana: "めんせつたいさくにはまえもってやるぎじめんせつをおこたらないようにしよう",
    roman: "mensetutaisakunihamaemotteyarugizimensetuwookotaranaiyounisiyou",
  },
  {
    kana: "しりょくがていかしてきたかんじがしたためこんたくとをしようすることにしました",
    roman: "siryokugateikasitekitakanjigasitatamekontakutowosiyousurukotonisimasita",
  },
  {
    kana: "あのえいがをかんしょうしたいならかんとくからのしょうだくをえたほうがいいよ",
    roman: "anoeigawokansyousitainarakantokukaranosyoudakuwoetahougaiiyo",
  },
  {
    kana: "ちょうちょうさんがしちょうにそうだんしたらしちょうはそれにおうじてくれなかった",
    roman: "tyoutyousangasityounisoudansitarasityouhasoreniouzitekurenakatta",
  },
  {
    kana: "しょうらいのけんこうのためにじょぎんぐをすることはすばらしいとかんじています",
    roman: "syourainokenkounotamenizyoginguwosurukotohasubarasiitokanjiteimasu",
  },
]

///|
test "打鍵トレーナーのワードの正誤判定ができること" {
  for word in datore_words {
    let (_initial_state, apply_key) = @typing.create_roman_engine(word.kana)
    for key in word.roman {
      let (_, result) = apply_key(key)
      let is_correct = match result {
        @typing.WrongKey => false
        _ => true
      }
      if !is_correct {
        fail("word=\{word.kana}")
      }
      assert_true(is_correct)
    }
  }
}
