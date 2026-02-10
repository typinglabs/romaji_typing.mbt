///|
test "example" {
  let (state, apply) = @typing.create_kana_engine("りんご")
  inspect(
    state,
    content=(
    #|{typed_romaji: "", remaining_romaji: "ringo", typed_kana_len: 0}
    ),
  )
  let results = []
  for key in "rimngo" {
    let (_state, result) = apply(key)
    match result {
      @typing.CorrectKey => results.push("正解")
      @typing.WrongKey => results.push("不正解")
      @typing.WordCompleted => results.push("完了")
    }
  }
  inspect(
    results,
    content=(
      #|["正解", "正解", "不正解", "正解", "正解", "完了"]
    ),
  )
}
