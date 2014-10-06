extend = require 'extend'

module.exports = ( grunt ) ->

	###
	This would take a src object of the form:
	{
		something:
			totally: "else"
		and: "this"
	}
	And extend the dest object with the following:
	{
		something_totally: "else"
		and: "this"
	}
	###
	flatExtend = ( dest, src, keyPath ) ->
		if typeof src is 'object'
			for key, value of src
				flatExtend( dest, value, ( keyPath and "#{ keyPath }_" or '' ) + key )
		else
			dest[ keyPath ] = src

		dest

	packageJsonDefaults =
		name             : "app"
		prefix           : "my"
		# dashedPrefix   : "my-" # this is calculated
		# ngApp          : "myApp" # this is calculated
		liveReloadPort   : "35729"
		htmlTarget       : "*.html"
		report           : "min"
		coffeeDir        : "coffee"
		scssDir          : "scss"
		jsDir            : "js"
		cssDir           : "css"
		fontsDir         : "fonts"
		imagesDir        : "images"
		templatesDir     : "templates"
		directivesDir    : "directives"
		viewsDir         : "views"
		taxonomyDir      : "bower_components/angoolar-css-taxonomy"
		headSuffix       : "head"
		tailSuffix       : "tail"
		karmaSuffix      : "karma"
		protractorSuffix : "protractor"
		phantomcssSuffix : "phantomcss"
		environment      : "development"
		buildDir         : "build"
		almostBuiltDir   : "almost_built"
		builtDir         : "built"
		documentationDir : "documentation"
		coverageDir      : "karma_coverage"
		protractorBaseUrl: "http://localhost"
		phantomcssDir    : "phantomcss"
		phantomcss       :
			screenshotsDir: "screenshots"
			resultsDir    : "results"
		applicationConfig:
			development:
				type               : "development"
				defaultScheme      : "http://"
				apiDomain          : "localhost"
				staticFileDomain   : ""
				staticFileDirectory: ""
				staticFileSuffix   : ""
			production:
				type               : "production"
				defaultScheme      : "http://"
				apiDomain          : "localhost"
				staticFileDomain   : ""
				staticFileDirectory: ""
				staticFileSuffix   : ""

	packageJson = extend(
		yes # this means this'll be a deep/recursive extend
		packageJsonDefaults
		grunt.file.readJSON( 'package.json' )
		if grunt.file.exists 'angoolar.json'
			grunt.file.readJSON 'angoolar.json'
		else
			null
	)

	packageJson.dashedPrefix = packageJson.dashedPrefix or if packageJson.prefix then "#{ packageJson.prefix }-" else ''
	packageJson.ngApp        = packageJson.ngApp        or if packageJson.prefix then "#{ packageJson.prefix }#{ packageJson.name.slice( 0, 1 ).toUpperCase() + packageJson.name.slice( 1 ) }" else ''

	prepHtmlTarget =
		expand : yes
		flatten: yes
		src    : [ '<%= pkg.htmlTarget %>' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/'

	prepCoffee =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.coffeeDir %>/**/*.coffee', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.coffeeDir %>/'

	prepJs =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.jsDir %>/**/*.js', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.jsDir %>/'

	prepCss =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.cssDir %>/**/*.css', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.cssDir %>/'

	prepFonts =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.fontsDir %>/**/*', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.fontsDir %>/'

	prepImages =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.imagesDir %>/**/*', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.imagesDir %>/'

	prepDirectiveTemplates =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.templatesDir %>/<%= pkg.directivesDir %>/*.html', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.templatesDir %>/<%= pkg.directivesDir %>/'

	prepViewTemplates =
		expand : yes
		flatten: yes
		src    : [ '**/<%= pkg.templatesDir %>/<%= pkg.viewsDir %>/*.html', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.templatesDir %>/<%= pkg.viewsDir %>/'

	prepScss =
		expand : yes
		src    : [ '**/<%= pkg.scssDir %>/**/*.scss', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.scssDir %>'

	buildCoffee = 
		expand : yes
		flatten: yes
		src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.coffeeDir %>/*.coffee'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>/'
		ext    : '.js'
		extDot : 'last'

	buildJs =
		expand : yes
		flatten: yes
		src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.jsDir %>/*.js'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>/'

	buildCss =
		expand : yes
		flatten: yes
		src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.cssDir %>/*.css'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>/'

	buildFonts =
		expand : yes
		flatten: yes
		src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.fontsDir %>/*'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.fontsDir %>/'

	buildImages =
		expand : yes
		flatten: yes
		src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.imagesDir %>/*'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.imagesDir %>/'

	buildTemplates =
		expand : yes
		cwd    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.templatesDir %>/'
		src    : '**/*.html'
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.templatesDir %>/'

	buildScssHead =
		expand : yes
		flatten: yes
		src    : [ '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.scssDir %>/**/!(_)*.<%= pkg.headSuffix %>.scss' ]
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>/'
		ext    : '.<%= pkg.headSuffix %>.css'

	builtTemplatesJs = '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>/9991_templates.<%= pkg.tailSuffix %>.js'

	builtJsHead    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.headSuffix }.js"
	builtJsHeadMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.headSuffix }-*.js"
	builtJsTail    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.tailSuffix }.js"
	builtJsTailMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.tailSuffix }-*.js"

	uglyJsHead    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/#{ packageJson.headSuffix }.js"
	uglyJsHeadMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/#{ packageJson.headSuffix }-*.js"
	uglyJsTail    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/#{ packageJson.tailSuffix }.js"
	uglyJsTailMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/#{ packageJson.tailSuffix }-*.js"

	prettyJsHead    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_head.js"
	prettyJsHeadMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_head-*.js"
	prettyJsTail    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_tail.js"
	prettyJsTailMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_tail-*.js"

	allPrettyJs    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_all.js"
	allPrettyJsMD5 = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/pretty_all-*.js"
	allJs          = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/all.js"
	allJsMD5       = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/all-*.js"

	builtCssHead    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.cssDir }/*.#{ packageJson.headSuffix }.css"
	builtCssHeadMD5 = "#{ packageJson.cssDir }/*.#{ packageJson.headSuffix }-*.css"

	allCss      = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.cssDir }/all.css"
	allCssMD5   = "#{ packageJson.cssDir }/all-*.css"
	allCssIE    = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.cssDir }/all_ie.css"
	allCssIEMD5 = "#{ packageJson.cssDir }/all_ie-*.css"

	builtJsKarma      = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.karmaSuffix }.js"
	builtJsProtractor = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.protractorSuffix }.js"
	builtJsPhantomcss = "#{ packageJson.buildDir }/#{ packageJson.builtDir }/#{ packageJson.jsDir }/*.#{ packageJson.phantomcssSuffix }.js"

	md5Js =
		expand : yes
		flatten: yes
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>/'
		src    : [
			builtJsHead,
			builtJsTail,
			uglyJsHead,
			uglyJsTail,
			prettyJsHead,
			prettyJsTail,
			allPrettyJs,
			allJs
		]

	md5Css =
		expand : yes
		flatten: yes
		dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>/'
		src    : [
			builtCssHead,
			allCss,
			allCssIE
		]

	preprocessContext = flatExtend {}, packageJson
	preprocessContext = flatExtend preprocessContext, packageJson.applicationConfig[ packageJson.environment ], 'applicationConfig'

	karmaPreprocessors = {}
	karmaPreprocessors[ builtJsHead ] = [ 'coverage' ]
	karmaPreprocessors[ builtJsTail ] = [ 'coverage' ]

	protractorConfJs = 'protractor.conf.js'
	unless grunt.file.exists protractorConfJs
		grunt.file.write protractorConfJs, "exports.config = {};"

	grunt.initConfig
		pkg: packageJson

		clean: 
			all       : [ '<%= pkg.buildDir %>/' ]
			karma     : packageJson.coverageDir
			docco     : packageJson.documentationDir
			phantomcss: [ "#{ packageJson.phantomcssDir }/desktop/#{ packageJson.phantomcss.resultsDir }/" ]
			coffee    : [
				'<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.coffeeDir %>'
				'<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.jsDir %>'
				'<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>'
			]
			scss: [
				'<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.scssDir %>'
				'<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>'
			]

		preprocess:
			options       : context: preprocessContext
			htmlTarget    : files: [ prepHtmlTarget ]
			prepCoffee    : files: [ prepCoffee ]
			prepScss      : files: [ prepScss ]
			prepJs        : files: [ prepJs ]
			prepCss       : files: [ prepCss ]
			prepTemplates : files: [ prepDirectiveTemplates, prepViewTemplates ]

		modernizr:
			outputFile: '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.jsDir %>/modernizr.<%= pkg.headSuffix %>.js'
			uglify    : yes
			parseFiles: no
			extra     :
				shiv      : yes
				printshiv : no
				load      : no
				mq        : no
				cssclasses: yes
			extensibility:
				addtest     : no
				prefixed    : no
				teststyles  : yes
				testprops   : yes
				testallprops: yes
				hasevents   : no
				prefixes    : yes
				domprefixes : yes
			tests: [
				"a_download"
				"backgroundsize"
				"flexbox"
				"rgba"
				"cssanimations"
				"csstransforms"
				"csstransforms3d"
				"cssgradients"
				"csstransitions"
				"input"
				"inputtypes"
				"css_backgroundsizecover"
				"css_boxsizing"
				"boxshadow"
				"forms_placeholder"
			]

		copy: 
			prepFonts     : files: [ prepFonts ]
			prepImages    : files: [ prepImages ]
			buildJs       : files: [ buildJs ]
			buildCss      : files: [ buildCss ]
			buildFonts    : files: [ buildFonts ]
			buildImages   : files: [ buildImages ]
			buildTemplates: files: [ buildTemplates ]

		coffee: coffee: buildCoffee

		ngtemplates:
			ngApp:
				cwd : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.templatesDir %>'
				src : '**/*.html'
				dest: builtTemplatesJs

				options:
					module: packageJson.ngApp
					url: ( url ) ->
						grunt.config.process "#{
							packageJson.applicationConfig[ packageJson.environment ].defaultScheme
						}#{
							packageJson.applicationConfig[ packageJson.environment ].staticFileDomain
						}#{
							if packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory then '/' + packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory else ''
						}/#{
							packageJson.templatesDir
						}/#{
							url
						}#{
							packageJson.applicationConfig[ packageJson.environment ].staticFileSuffix
						}"
					htmlmin:
						collapseBooleanAttributes: no
						collapseWhitespace       : yes
						removeAttributeQuotes    : yes
						removeComments           : yes
						removeEmptyAttributes    : yes
						removeRedundantAttributes: yes

		sass:
			options:
				compass : yes
				loadPath: [
					'<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/**/<%= pkg.scssDir %>'
					'<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.scssDir %>/<%= pkg.taxonomyDir %>/<%= pkg.scssDir %>'
				]
				style   : 'condensed'
				require : 'animation'
			dist: files: [ buildScssHead ]

		concat:
			prettyHead:
				options: separator: ';'
				dest   : prettyJsHead
				src    : [ builtJsHead ]
			prettyTail:
				options: separator: ';'
				dest   : prettyJsTail
				src    : [ builtJsTail ]
			allPrettyJs:
				options: separator: ';'
				dest   : allPrettyJs
				src    : [
					prettyJsHead
					prettyJsTail
				]
			allCss:
				src: [ builtCssHead ]
				dest: allCss

		uglify:
			options:
				report: packageJson.report
			headJs:
				src : builtJsHead
				dest: uglyJsHead
			tailJs:
				src : builtJsTail
				dest: uglyJsTail
			allJs:
				src: [ builtJsHead, builtJsTail ]
				dest: allJs

		cssmin:
			options:
				report: packageJson.report
			allCss:
				src : [ builtCssHead ]
				dest: allCss

		bless:
			options:
				cleanup: yes
			files:
				expand: yes
				cwd : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>'
				src : 'all.css'
				dest: '<%= pkg.buildDir %>/<%= pkg.builtDir %>/<%= pkg.cssDir %>'
				ext : '_ie.css'

		md5:
			js     : md5Js
			css    : md5Css
			options:
				keepBasename : yes
				keepExtension: yes

		htmlbuild:
			development:
				src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.htmlTarget %>'
				dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/'
				options:
					prefix : "#{
							packageJson.applicationConfig[ packageJson.environment ].defaultScheme
						}#{
							packageJson.applicationConfig[ packageJson.environment ].staticFileDomain
						}#{
							if packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory then '/' + packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory else ''
						}/"
					scripts:
						head: [ builtJsHead ]
						tail: [ builtJsTail ]
					styles:
						head  : [ builtCssHead ]
						headIE: [ allCssIE ]

			production:
				src    : '<%= pkg.buildDir %>/<%= pkg.almostBuiltDir %>/<%= pkg.htmlTarget %>'
				dest   : '<%= pkg.buildDir %>/<%= pkg.builtDir %>/'
				options:
					prefix : "#{
							packageJson.applicationConfig[ packageJson.environment ].defaultScheme
						}#{
							packageJson.applicationConfig[ packageJson.environment ].staticFileDomain
						}#{
							if packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory then '/' + packageJson.applicationConfig[ packageJson.environment ].staticFileDirectory else ''
						}/"
					scripts:
						head: [ allJsMD5 ]
						tail: []
					styles:
						head  : [ allCssMD5 ]
						headIE: [ allCssIEMD5 ]

		protractor: protractor: options:
			configFile: protractorConfJs
			args      :
				specs            : [ builtJsProtractor ]
				framework        : 'jasmine'
				jasmineNodeOpts  : defaultTimeoutInterval: 30000
				allScriptsTimeout: 30000
				baseUrl          : '<%= pkg.protractorBaseUrl %>'

		karma: karma: options:
			basePath     : './'
			autoWatch    : no
			singleRun    : yes
			frameworks   : [ 'jasmine' ]
			browsers     : [ 'Chrome' ]
			reporters    : [ 'progress', 'coverage' ]
			preprocessors: karmaPreprocessors
			files        : [
				builtJsHead
				builtJsTail
				builtJsKarma
			]
			plugins: [
				'karma-chrome-launcher'
				'karma-jasmine'
				'karma-mocha-reporter'
				'karma-coverage'
			]
			coverageReporter:
				type: 'html'
				dir : "#{ packageJson.coverageDir }/"

		docco: docco:
			src: [
				'**/<%= pkg.coffeeDir %>/**/*.coffee'
				'**/<%= pkg.jsDir %>/**/*.js'
				'**/<%= pkg.cssDir %>/**/*.css'
				'**/<%= pkg.templatesDir %>/<%= pkg.directivesDir %>/*.html'
				'**/<%= pkg.templatesDir %>/<%= pkg.viewsDir %>/*.html'
				'**/<%= pkg.scssDir %>/**/*.scss'
				'<%= pkg.htmlTarget %>'
				'!node_modules/**/*'
				'!<%= pkg.buildDir %>/**/*'
			]
			options:
				layout: 'parallel'
				output: packageJson.documentationDir

		phantomcss:
			desktop:
				src    : [ builtJsPhantomcss ]
				options:
					screenshots : "#{ packageJson.phantomcssDir }/desktop/#{ packageJson.phantomcss.screenshotsDir }/"
					results     : "#{ packageJson.phantomcssDir }/desktop/#{ packageJson.phantomcss.resultsDir }/"
					viewportSize: [ 1024, 1024 ]

		watch:
			options:
				livereload       : yes # packageJson.liveReloadPort
				verbose          : yes
				interrupt        : yes
				livereloadOnError: no
			scss:
				files: [ '**/<%= pkg.scssDir %>/**/*.scss', '**/<%= pkg.cssDir %>/**/*.css', '!<%= pkg.buildDir %>/**/*' ]
				tasks: [ 'scss_<%= pkg.applicationConfig[ pkg.environment ].type %>', 'postwatch' ]
			coffee:
				files: [ '**/<%= pkg.coffeeDir %>/**/*.coffee', '**/<%= pkg.templatesDir %>/**/*.html', '!<%= pkg.buildDir %>/**/*' ]
				tasks: [ 'coffee_<%= pkg.applicationConfig[ pkg.environment ].type %>', 'postwatch' ]
			statics:
				files: [ '**/<%= pkg.jsDir %>/**/*.js', '**/<%= pkg.cssDir %>/**/*.css', '**/<%= pkg.fontsDir %>/**/*', '**/<%= pkg.imagesDir %>/**/*', '!node_modules/**/*', '!<%= pkg.buildDir %>/**/*' ]
				tasks: [ 'copy:prepFonts', 'copy:prepImages', 'copy:buildJs', 'copy:buildCss', 'copy:buildFonts', 'copy:buildImages', 'copy:buildTemplates', 'ngtemplates', 'concat', 'htmlbuild:<%= pkg.applicationConfig[ pkg.environment ].type %>', 'postwatch' ]
			htmlTarget:
				files: [ '<%= pkg.htmlTarget %>' ]
				tasks: [ 'preprocess', 'htmlbuild:<%= pkg.applicationConfig[ pkg.environment ].type %>', 'postwatch' ]

		shell: postwatch: command: packageJson.postwatch

	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-html-build'
	grunt.loadNpmTasks 'grunt-preprocess'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-angular-templates'
	grunt.loadNpmTasks 'grunt-modernizr'
	grunt.loadNpmTasks 'grunt-bless'
	grunt.loadNpmTasks 'grunt-md5'
	grunt.loadNpmTasks 'grunt-protractor-runner'
	grunt.loadNpmTasks 'grunt-karma'
	grunt.loadNpmTasks 'grunt-docco'
	grunt.loadNpmTasks 'grunt-phantomcss'
	grunt.loadNpmTasks 'grunt-debug-task'
	grunt.loadNpmTasks 'grunt-shell'

	tasksByType = 
		development: [ 
			'clean:all'
			'preprocess'
			'modernizr'
			'copy'
			'coffee'
			'ngtemplates'
			# 'uglify'
			'sass'
			'concat'
			'cssmin'
			'bless'
			'preprocess:htmlTarget'
			'md5'
			'htmlbuild:development'
		]
		production: [ 
			'clean:all'
			'preprocess'
			'modernizr'
			'copy'
			'coffee'
			'ngtemplates'
			'uglify'
			'sass'
			'concat'
			'cssmin'
			'bless'
			'preprocess:htmlTarget'
			'md5'
			'htmlbuild:production'
		]

	grunt.registerTask environment, tasksByType[ applicationConfig.type ] for environment, applicationConfig of packageJson.applicationConfig

	grunt.registerTask 'default', tasksByType[ packageJson.applicationConfig[ packageJson.environment ].type ]

	watchTasks =
		scss_development: [ 'clean:scss', 'preprocess:prepScss', 'preprocess:prepCss', 'copy:buildCss', 'sass', 'concat:allCss', 'cssmin', 'bless', 'md5', 'htmlbuild:development' ]
		scss_production : [ 'clean:scss', 'preprocess:prepScss', 'preprocess:prepCss', 'copy:buildCss', 'sass', 'concat:allCss', 'cssmin', 'bless', 'md5', 'htmlbuild:production'  ]

		coffee_development: [ 'clean:coffee', 'preprocess:prepCoffee', 'preprocess:prepJs', 'preprocess:prepTemplates', 'copy:buildJs', 'copy:buildTemplates', 'coffee', 'ngtemplates', 'concat:prettyHead', 'concat:prettyTail', 'concat:allPrettyJs',           'md5', 'htmlbuild:development' ]
		coffee_production : [ 'clean:coffee', 'preprocess:prepCoffee', 'preprocess:prepJs', 'preprocess:prepTemplates', 'copy:buildJs', 'copy:buildTemplates', 'coffee', 'ngtemplates', 'concat:prettyHead', 'concat:prettyTail', 'concat:allPrettyJs', 'uglify', 'md5', 'htmlbuild:production'  ]

	grunt.registerTask watchTasksName, tasks for watchTasksName, tasks of watchTasks

	grunt.registerTask 'run-docco',      [ 'clean:docco', 'docco' ]
	grunt.registerTask 'run-karma',      watchTasks.coffee_development.concat [ 'karma' ]
	grunt.registerTask 'run-protractor', watchTasks.coffee_development.concat [ 'protractor' ]
	grunt.registerTask 'run-phantomcss', watchTasks.coffee_development.concat [ 'phantomcss' ]

	grunt.registerTask 'postwatch', if packageJson.postwatch then [ 'shell:postwatch' ] else []

	grunt.log.writeln "Build environment: #{ packageJson.environment }, Build type: #{ packageJson.applicationConfig[ packageJson.environment ].type }"
