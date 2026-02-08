///|
using @tea {none}

///|
using @html {h1, div, text, button}

///|
using @tea {type Cmd}

///|
using @html {type Html}

///|
type Model = Int

///|
enum Msg {
  Increment
  Decrement
}

///|
fn update(msg : Msg, model : Model) -> (Cmd[Msg], Model) {
  match msg {
    Increment => (none(), model + 1)
    Decrement => (none(), model - 1)
  }
}

///|
fn view(model : Model) -> Html[Msg] {
  div([
    h1([text(model.to_string())]),
    button(click=Increment, [text("+")]),
    button(click=Decrement, [text("-")]),
  ])
}

///|
fn main {
  let model = 0
  @tea.startup(model~, update~, view~)
}
