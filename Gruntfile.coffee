_ = require 'lodash'

lastLibBB = null # store the bundleBuilder of the last lib build (`source/code`)

module.exports = gruntFunction = (grunt) ->
  grunt.loadNpmTasks task for task of grunt.file.readJSON('package.json').devDependencies when task.lastIndexOf('grunt-', 0) is 0

  gruntConfig =
    urequire:
      _defaults:
        path: "source/code"
        resources: [
          'inject-version'
          ['less', {$srcMain: 'style/myMainStyle.less', compress: true}]
          ['teacup-js', tags: 'html, doctype, body, div, ul, li']
        ]
        main: "my-main"
        dependencies:
          imports:
            lodash: ['_']
            'when/callbacks': 'whenCallbacks'
          node: ['nodeOnly/*']
          paths: bower: true
          rootExports: 'my-main': 'myMain'
          locals: 'when' : 'bower_components/when'

        clean: true
        template: banner: true
        afterBuild :(err, bb)-> lastLibBB = if err then null else bb

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

      min:
        template:
          name: 'combined'
          moduleName: 'urequire-example'
        dstPath: "build/minified/urequire-example-min.js"
        optimize: true # true means 'uglify2'
        rjs: preserveLicenseComments: false

      spec:
        derive: []
        path: "source/spec"
        copy: [/./]
        dstPath: "build/spec"
        clean: true
        rjs: shim: lodash: {deps: [], exports: '_'}

        dependencies:
          paths: bower: true
          imports:
            chai: 'chai'
            lodash: ['_']
            uberscore: '_B'
            'urequire-example': ['uEx']
            'specHelpers': 'spH'

        resources: [
          [ '+inject-_B.logger', ['**/*.js'], (m)-> m.beforeBody = "var l = new _B.Logger('#{m.dstFilename}');"]
          ['import-keys',
              'specHelpers': [ 'tru', ['equal', 'eq'], 'fals' ]
              'lodash': [ 'isFunction' ]  # just for test
              'chai': ['expect']
          ]
        ]
        afterBuild: (err, specBB)->
          require('urequire-ab-specrunner') lastLibBB, specBB, # options {}
            injectCode: """
              // test `noConflict()`: create two globals that 'll be 'hijacked' by rootExports
              window.urequireExample = 'Old global `urequireExample`';
              window.uEx = 'Old global `uEx`';
              """
            mochaOptions: '-R dot'
            debugLevel: 40

      specWatch: derive: ['spec'], watch: 1000

      specMin:
        derive: ['spec']
        dstPath: "build/spec_combined/index-combined.js"
        template: name: 'combined'

  splitTasks = (tasks)-> if !_.isString tasks then tasks else _.filter tasks.split /\s/
  for task in ['urequire']
    for cmd of gruntConfig[task]
      grunt.registerTask cmd, splitTasks "#{task}:#{cmd}"

  grunt.registerTask shortCut, splitTasks tasks for shortCut, tasks of {
    default: "UMD spec min specMin"
  }
  grunt.initConfig gruntConfig