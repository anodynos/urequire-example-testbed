# specHelpers-imports injected by uRequire:spec task
define ->
  describe """
    uRequire's `rootExports` & `noConflict():`
      (running on #{if __isNode then 'nodejs' else 'Web'} via #{if __isAMD then 'AMD' else 'noAMD/script'}):
    """, ->

      uExLocal = require 'urequire-example'

      it "registers globals 'urequireExample' & 'uEx'", ->
        equal window.urequireExample, uExLocal
        equal window.uEx, uExLocal

      # `window.urequireExample` & `window.uEx` must be set on browser
      # BEFORE loading 'urequire-example' (in SpecRunner_XXX.html)
      it "noConflict() returns module & sets old values to globals 'urequireExample', 'uEx'", ->
        equal window.uEx.noConflict(), uExLocal

        if __isWeb # work only on browser
          equal window.urequireExample, "Old global `urequireExample`"
          equal window.uEx, "Old global `uEx`"

      describe " 'urequire-example' has the right properties:", ->
        it "person.age", ->
          equal uExLocal.person.age, 40

        it "add", ->
          tru _.isFunction uExLocal.add

        it "VERSION", ->
          fals _.isUndefined uExLocal.VERSION