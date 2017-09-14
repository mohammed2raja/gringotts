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
        src: ['tmp/*', 'tmp/test/*']

    coffee:
      compile:
        expand: yes
        cwd: '/'
        src: ['*.coffee', '**/*.coffee']
        dest: 'public/'
        ext: '.js'
      # For Mocha tests in browser.
      test:
        expand: yes
        cwd: 'test/'
        src: ['*.coffee', '**/*.coffee']
        dest: 'public/test'
        ext: '.js'

    handlebars:
      prod:
        options:
          amd: yes
          namespace: 'Handlebars'
          processName: (file) ->
            file
              .replace('templates/', '')
              .replace('.hbs', '')
        files:
          'public/templates.js': [
            'templates/**/*.hbs'
          ]
      dev:
        options:
          amd: yes
          namespace: 'Handlebars'
          processName: (file) ->
            file
              .replace('templates/', '')
              .replace('test/templates/', '')
              .replace('.hbs', '')
        files:
          'public/templates.js': [
            'templates/**/*.hbs'
            'test/templates/**/*.hbs'
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
        modulePattern : './(.*?)/'
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
          base: 'public'
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
          {'tmp/': 'templates/**/*.hbs'}
          {'tmp/': 'test/templates/**/*.hbs'}
        ]
        options:
          replacements:
            [{pattern: /{{.*}}/g, replacement: ''}]

    htmlhint:
      options:
        htmlhintrc: '.htmlhintrc'
      html:
        src: ['tmp/templates/**/*.hbs', 'tmp/test/templates/**/*.hbs']

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
      'copy-package':
        command: 'cp package.json public/'
      'publish':
        command: 'npm publish public'
      localBuild:
        command: ->
          buildPath = grunt.option 'target'
          return '' unless buildPath
          "rm -r #{buildPath};" +
          "cp -R -v public #{buildPath};"

    connect:
      server:
        options:
          base: ['public', 'test']
          port: 8000
          useAvailablePort: true

    checkDependencies:
      this: {}

    # Only run tasks on modified files.
    watch:
      options:
        spawn: no
        interrupt: yes
        dateFormat: (time) ->
          grunt.log
            .writeln("Compiled in #{time}ms @ #{(new Date).toString()} 💪\n")

      coffee_hbs:
        files: ['{src,test}/**/*.coffee', '{src,test}/templates/**/*.hbs']
        tasks: [
          'newer:handlebars:dev'
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
    'checkDependencies'
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
    'build'
    'lint'
    'force:blanket_mocha:report_spec'
    'blanket_mocha:report_xunit'
  ]

  grunt.registerTask 'release', 'Create release branch', (version='') ->
    version = ":#{version}" if version
    grunt.option 'env', 'prod'
    grunt.task.run [
      'build'
      "bump-only#{version}"
      'shell:copy-package'
      'gh-pages:release'
      'bump-commit'
      'shell:publish'
    ]

  grunt.registerTask 'compile', ->
    grunt.task.run [
      "handlebars:#{grunt.option('env') || 'dev'}"
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
