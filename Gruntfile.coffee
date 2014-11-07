module.exports = (grunt) ->
  gruntConfig =
    urequire:
      _all:
        dependencies: imports:
          lodash: ['_']
          # 'when/callbacks': 'whenCallbacks'
        clean: true
        template: banner: true
        #debugLevel: 50
        #verbose:true

      _defaults: #for library only
        name: 'urequire-example'
        main: "my-main"
        path: "source/code"
        filez: [/./, '!uRequireConfig.coffee']
        resources: [
          'inject-version'

          ['less', {$srcMain: 'style/myMainStyle.less', compress: true}]

          ['teacup-js', tags: 'html, doctype, body, div, ul, li']
        ]
        dependencies:
          node: [
            'nodeOnly/*'
            'fileRelative/missing/dep'
          ]
          # add to those already delcared in module it self
          rootExports: 'my-main': 'myMain'
          #locals: 'when' : 'bower_components/when' # auto discovers it with wrong bower's path

        rootExports:
          runtimes: ['AMD', 'node', 'script'] # renamed to `rootExports.runtimes`

      UMD:
        template: 'UMDplain'
        dstPath: "build/UMD"
        resources: [
          ['teacup-js2html', # works only with nodejs/UMD templates
#              deleteJs: true,
              args: #['World!']
                'markup/**/home': ['World!']
                allButHome:
                  isFileIn: ['**/*', '!', (f)-> f is 'markup/home']
                  args: [ ['Michael', 'Angelo' ] ]
          ]
        ]

      dev:
        # dependencies: locals: 'when': [[null], 'bower_components/when/when'] # auto discovers it (with wrong bower's path)
        template:
          name: 'combined'
          moduleName: 'urequire-example-testbed'
        dstPath: "build/minified/urequire-example-testbed-dev.js"

      min:
        derive: ['dev', '_defaults']
        dstPath: "build/minified/urequire-example-testbed-min.js"
        optimize: true # true means 'uglify2'
        rjs: preserveLicenseComments: false
        #rootExports: noConflict: false # makes min fail cause it overrides module's `noConflict` setting

      spec:
        name: 'specs-for-urequire-example' # can be anything
        derive: []
        path: "source/spec"
        copy: [/./]
        dstPath: "build/spec"
        clean: true
        globalWindow: ['urequire-spec']
        rjs: shim:
          lodash: {deps: [], exports: '_'}
          uberscore: {deps: ['lodash'], exports: '_B'} # shims are utilized by `urequire-ab-specrunner`

        dependencies:
          paths: bower: true
          imports:
            chai: 'chai'
            lodash: ['_']
            uberscore: '_B'
            'urequire-example-testbed': ['uEx']
            'specHelpers': 'spH'

        resources: [
          [ '+inject-_B.logger', ['**/*.js'], (m)-> m.beforeBody = "var l = new _B.Logger('#{m.dstFilename}');"]

          ['import-keys',
              'specHelpers': [ 'tru', ['equal', 'eq'], 'fals' ]
              'lodash': [ 'isFunction' ]  # just for test
              'chai': ['expect']
          ]
        ]

      specDev:
        derive: ['spec']
        dstPath: "build/spec_combined/index-combined.js"
        template: name: 'combined'

      specRun:
        derive:['spec']
        afterBuild: require('urequire-ab-specrunner').options
          injectCode: testNoConflict = """
            // test `noConflict()`: create two globals that 'll be 'hijacked' by rootExports
            window.urequireExample = 'Old global `urequireExample`';
            window.uEx = 'Old global `uEx`';
            """

      specDevRun:
        derive:['specDev', 'specRun']

      specWatch:
        derive: ['spec']
        watch: 1444
        afterBuild: require('urequire-ab-specrunner').options
          injectCode: testNoConflict
          mochaOptions: '-R dot'

      specDevWatch:
        derive: ['specDev', 'specWatch']

    watch:
      options: spawn: false
      UMD:
        files: ["source/code/**/*", "source/spec/**/*"]
        tasks: ['min' , 'spec']

  _ = require 'lodash'
  splitTasks = (tasks)-> if _.isArray tasks then tasks else _.filter tasks.split /\s/
  grunt.registerTask shortCut, "urequire:#{shortCut}" for shortCut of gruntConfig.urequire
  grunt.registerTask shortCut, splitTasks tasks for shortCut, tasks of {
    default: "UMD specRun min specDevRun"
    all: "UMD specRun UMD specDevRun dev specDevRun min specRun min specDevRun"
  }
  grunt.loadNpmTasks task for task of grunt.file.readJSON('package.json').devDependencies when task.lastIndexOf('grunt-', 0) is 0
  grunt.initConfig gruntConfig