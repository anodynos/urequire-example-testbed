# for more uRequire comments & examples see uBerscore https://github.com/anodynos/uBerscore/blob/bb6fa0ae60105bec381eae64b8a96d1579450f22/Gruntfile_CommentsExamples.coffee
startsWith = (string, substring) -> string.lastIndexOf(substring, 0) is 0
S = if process.platform is 'win32' then '\\' else '/'
nodeBin       = "node_modules#{S}.bin#{S}"
_ = require 'lodash'

#require 'coffee-script/register' # make sure the latest cofffe-script is used instead of grunt's

urequireGruntSpecRunner = require 'urequire-grunt-spec-runner'
lastLibBB = null # store the bundleBuilder of the last library build (source/code)

sourceDir     = "source/code"
buildDir      = "build"
sourceSpecDir = "source/spec"
buildSpecDir  = "build/spec"

module.exports = gruntFunction = (grunt) ->
  pkg = grunt.file.readJSON('package.json')
  grunt.loadNpmTasks task for task of pkg.devDependencies when startsWith(task, 'grunt-')

  gruntConfig =
    urequire:
      _defaults:
        bundle:
          path: "#{sourceDir}"
          resources: [
            'inject-version'
            ['less', {$srcMain: 'style/myMainStyle.less', compress: true}]
            ['teacup-js', tags: 'html, doctype, body, div, ul, li']
          ]
          main: "urequire-example"
          dependencies:
            imports:
              lodash: ['_']
            node: ['nodeOnly/*']
            paths:
              bower: true

        build:
          template: banner: true
          afterBuild :(err, bb)-> lastLibBB = if err then null else bb
#          verbose: false
#          debugLevel: 100
#          clean: true

      UMD:
        template: 'UMDplain'
        dstPath: "#{buildDir}/UMD"
        optimize: uglify2:
          output: beautify: true
          compress: false
          mangle: false

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
        dstPath: "#{buildDir}/minified/urequire-example-min.js"
#        optimize: true # true equals 'uglify2'
        rjs: preserveLicenseComments: false

      spec:
#        debugLevel: 100
        derive: []
        path: "#{sourceSpecDir}"
        copy: [/./]
        dstPath: "#{buildSpecDir}/some/nested/long/path"

        dependencies:
          imports:
            chai: 'chai'
            lodash: ['_']
            uberscore: '_B'
            'urequire-example': ['uEx']
            'specHelpers': 'spH'

          paths:
            override:
              teacup: ["node_modules/teacup/lib/teacup"] # missing from bower

            bower: true

        resources: [
          [ '+inject-_B.logger', ['**/*.js'], (m)-> m.beforeBody = "var l = new _B.Logger('#{m.dstFilename}');"]

          ['import',
              'specHelpers': [ 'tru', ['equal', 'eq'], 'fals' ]
              'lodash': [ 'isFunction' ]  # just for test
              'chai': ['expect']
          ]
        ]

        afterBuild: (err, specBB)->
          if not err
            urequireGruntSpecRunner(lastLibBB, specBB, grunt,
              setupCode: """
                // test `noConflict()`: create two globals that 'll be 'hijacked' by rootExports
                window.urequireExample = 'Old global `urequireExample`';
                window.uEx = 'Old global `uEx`';
              """
              debugLevel: 100
            )

      specMin:
        derive: ['spec']
        dstPath: "#{buildSpecDir}_combined/some/nested/long/path/index-combined.js"
        template:
          name: 'combined'
          moduleName: "index-combined"

    watch:
      options: spawn: false
      UMD:
        files: ["#{sourceDir}/**/*", "#{sourceSpecDir}/**/*"]
        tasks: ['urequire:UMD' , 'urequire:spec', 'mochaCmd'] #'mocha:UMD']
      min:
        files: ["#{sourceDir}/**/*", "#{sourceSpecDir}/**/*"]
        tasks: ['urequire:min', 'urequire:specMin', 'concat:specCombinedFakeModuleMin', 'mochaCmdDev', 'mocha:min']

    shell:
      mochaCmd: command: "#{nodeBin}mocha #{buildSpecDir}/index --recursive --reporter spec"
      mochaCmdDev: command: "#{nodeBin}mocha #{buildSpecDir}_combined/index-combined --recursive --reporter spec"
      run: command: "#{nodeBin}coffee source/examples/runExample.coffee"
      options: {verbose: true, failOnError: true, stdout: true, stderr: true}


    mocha:
      min:
        src: ["#{buildSpecDir}_combined/SpecRunner_almondJs_noAMD_plainScript_min.html"]
        options: run: true

      mingen:
        src: ["#{buildSpecDir}_combined/SpecRunner_Generated.html"]
        options: run: true

      UMD: src: ["#{buildSpecDir}/SpecRunner_unoptimized_UMD.html"]

      UMDgen: src: ["#{buildSpecDir}/SpecRunner_Generated.html"]

    concat:
      specCombinedFakeModuleMin:
        options: banner: '{"name":"urequire-example", "main":"../../../minified/urequire-example-min.js"}'
        src:[]
        dest: "#{buildSpecDir}_combined/node_modules/urequire-example/package.json"

    clean: files: [buildDir]

  splitTasks = (tasks)-> if !_.isString tasks then tasks else (_.filter tasks.split(/\s/), (v)-> v)
  for task in ['shell', 'urequire']
    for cmd of gruntConfig[task]
      grunt.registerTask cmd, splitTasks "#{task}:#{cmd}"

  grunt.registerTask shortCut, splitTasks tasks for shortCut, tasks of {
    default:   "clean build test min testMin mocha run"
    build:     "urequire:UMD"
    test:      "urequire:spec mochaCmd"
    testMin:   "urequire:specMin concat:specCombinedFakeModuleMin mochaCmdDev"
  }

  grunt.initConfig gruntConfig