# All specHelper imports are injected via `urequire-rc-import`
# See 'specHelpers' imports in uRequire:spec task

# `uEx` var injected by `dependencies: imports`

describe " 'urequire-example-testbed' has:", ->

  it "person.fullName()", ->
    eq uEx.person.fullName(), 'John Doe'

  it "person.age", ->
    eq uEx.person.age, 40

  it "add function", ->
    tru _.isFunction uEx.add
    eq uEx.add(20, 18), 38
    eq uEx.calc.add(20, 8), 28

  it "calc.multiply", ->
    tru _.isFunction uEx.calc.multiply
    eq uEx.calc.multiply(18, 2), 36

  it "person.eat food", ->
    eq uEx.person.eat('food'), 'ate food'

  it "has some VERSION", ->
    fals _.isEmpty uEx.VERSION

  it "has the correct homeHTML", ->
    eq uEx.homeHTML, '<html><body><div id="Hello,">Universe!</div><ul><li>Leonardo</li><li>Da Vinci</li></ul></body></html>'