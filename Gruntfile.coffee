module.exports = (grunt) ->
  # Load all grunt tasks matching the `grunt-*` pattern
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    verbosity:
      hide:
        tasks: ['string-replace']

    clean:
      public:
        src: 'public/*'
      'hbs-strip':
        src: ['tmp/src/*', 'tmp/test/*']

    coffee:
      compile:
        expand: yes
        cwd: 'src/'
        src: ['*.coffee', '**/*.coffee']
        dest: 'public/src/'
        ext: '.js'
      # For Mocha tests in browser.
      test:
        expand: yes
        cwd: 'test/'
        src: ['*.coffee', '**/*.coffee']
        dest: 'public/src/test'
        ext: '.js'

    handlebars:
      compile_test:
        options:
          amd: yes
          namespace: 'Handlebars'
          processName: (file) ->
            file.replace('.hbs', '')
                .replace('test/templates/', '')
        files:
          'public/src/test/templates.js': [
            'test/templates/**/*.hbs'
          ]
      compile:
        options:
          amd: yes
          namespace: 'Handlebars'
          processName: (file) ->
            file.replace('src/templates/', '')
                .replace('.hbs', '')
        files:
          'public/src/templates.js': [
            'src/templates/**/*.hbs'
          ]

    copy:
      test:
        src: [
          'test/*.html'
        ]
        dest: 'public/'

    blanket_mocha:
      options:
        threshold : 50
        globalThreshold : 65
        log : yes
        logErrors: yes
        moduleThreshold : 60
        modulePattern : './src/(.*?)/'
      test:
        src: 'public/test/index-phantomjs.html'
      report_spec:
        src: 'public/test/index-phantomjs.html'
        options:
          reporter: 'spec'
      report_xunit:
        src: 'public/test/index-phantomjs.html'
        options:
          reporter: 'XUnit'
          reporterOptions: output: 'test-results.xml'

    'gh-pages':
      release:
        options:
          base: 'public/src'
          branch: 'release'
          message: 'Release v<%= pkg.version %>'
          tag: 'v<%= pkg.version %>'
        src: [
          '**/*.js*'
          '!test/**'
        ]

    bump:
      options:
        # Tag will be created via gh-pages:release
        createTag: no
        commitFiles: '<%= bump.options.files %>'
        files: ['package.json']
        pushTo: 'origin'
        updateConfigs: ['pkg']

    coffeelint:
      app:
        src: ['{src,test}/**/*.coffee', 'Gruntfile.coffee']
      options:
        configFile: 'coffeelint.json'

    'string-replace':
      'hbs-strip':
        files: [
          {'tmp/': 'src/templates/**/*.hbs'}
          {'tmp/': 'test/templates/**/*.hbs'}
        ]
        options:
          replacements:
            [{pattern: /{{.*}}/g, replacement: ''}]

    htmlhint:
      options:
        htmlhintrc: '.htmlhintrc'
      html:
        src: ['tmp/src/templates/**/*.hbs', 'tmp/test/templates/**/*.hbs']

    shell:
      options:
        failOnError: yes
        stderr: yes
        stdout: yes
      specs:
        command: 'find test -regex ".*-test\.coffee" > public/testSpecs.txt'
      link:
        command: 'cd public; ln -sf ../node_modules node_modules'
      # Keep copy task clean.
      release:
        command: 'cp package.json public/src/'
      localBuild:
        command: ->
          buildPath = grunt.option 'target'
          return '' unless buildPath
          "rm -r #{buildPath};" +
          "cp -R -v public/src #{buildPath};"

    connect:
      server:
        options:
          base: ['public', 'test']
          port: 8000
          useAvailablePort: true

    # Only run tasks on modified files.
    watch:
      options:
        spawn: no
        interrupt: yes
        dateFormat: (time) ->
          grunt.log
            .writeln("Compiled in #{time}ms @ #{(new Date).toString()} 💪\n")

      coffee_hbs:
        files: ['{src,test}/**/*.coffee', 'src/templates/**/*.hbs']
        tasks: [
          'newer:handlebars'
          'newer:coffee'
          'force:newer:coffeelint'
          'force:htmllint'
          'force:blanket_mocha:test'
          'shell:localBuild'
        ]

      grunt:
        files: 'Gruntfile.coffee'
        tasks: 'force:newer:coffeelint'

      test:
        files: 'test/index.html'
        tasks: 'copy:test'

  # Create aliased tasks.
  grunt.registerTask 'default', [
    'build'
    'force:lint'
    'connect'
    'test'
    'watch'
  ]

  grunt.registerTask 'test', [
    'force:blanket_mocha:test'
  ]

  grunt.registerTask 'test-ci', [
    'compile'
    'copy'
    'shell:link'
    'lint'
    'force:blanket_mocha:report_spec'
    'blanket_mocha:report_xunit'
  ]

  grunt.registerTask 'release', 'Create release branch', (version='') ->
    version = ":#{version}" if version
    grunt.task.run [
      "bump-only#{version}"
      'shell:release'
      'gh-pages:release'
      'bump-commit'
    ]

  grunt.registerTask 'compile', [
    'handlebars'
    'coffee'
    'shell:specs'
  ]

  grunt.registerTask 'htmllint', [
    'verbosity'
    'string-replace:hbs-strip'
    'htmlhint'
    'clean:hbs-strip'
  ]

  grunt.registerTask 'lint', [
    'coffeelint'
    'htmllint'
  ]

  grunt.registerTask 'build', [
    'clean'
    'compile'
    'copy'
    'shell:link'
  ]

  ###*
   * Useful to locally test changes you make to Gringotts within the app.
   * Recursively overwrites anything in the passed in path.
   * @param  {string} path - Relative pathname of where Gringotts fits
   *                         within your app
  ###
  grunt.registerTask 'release-local',
    'Release a local build of Gringotts to a given path',
    (path) ->
      buildPath = grunt.option 'target'
      if buildPath
        grunt.log.writeln "Building gringotts into #{buildPath}..."
        grunt.task.run [
          'build'
          'connect'
          'test'
          'shell:localBuild'
          'watch'
        ]
      else
        grunt.log.writeln(
          'Target parameter (i.e. --target="...") is required'
        )
