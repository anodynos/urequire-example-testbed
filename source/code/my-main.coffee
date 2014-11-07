# uRequire Module Configuration
(urequire: rootExports: ["urequireExample", "uEx"], noConflict: true)

define ["models/Person"], (Person) ->
  add = require("calc/add")
  person = new Person("John", "Doe")
  person.age = 18
  person.age = add(person.age, 2)

  # load 'calc/index.js' like node does, but works on AMD also
  calc = require './calc'
  # Again './' resolves to './index' which in turn loads 'calc/index.js'
  calc2 = require './'
  throw "requiring `./index` as './' failed" if calc isnt calc2

  person.age = calc.multiply(person.age, 2)
  homeTemplate = require("markup/home")

  if __isNode
    nodeOnlyVar = require("nodeOnly/runsOnlyOnNode")
    console.log "Runs only on node:", require("util").inspect(nodeOnlyVar)

  # lodash `_` is injected whole bundle using `dependencies: imports`
  _.clone
    person: person
    add: add
    calc: calc
    homeHTML: homeTemplate("Universe!")
    # `var VERSION = 'xx';` injected by 'inject-version' RC
    VERSION: VERSION