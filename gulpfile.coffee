gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
gutil      = require 'gulp-util'
browserify = require 'gulp-browserify'
uglify     = require 'gulp-uglify'
webserver  = require 'gulp-webserver'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'
replace    = require 'gulp-replace'
moment     = require 'moment'

pkg    = require './package.json'

paths =
  coffee: './src/**/*.coffee'
  header: './header.js.orig'
  infopl: './NFSub.safariextension/Info.plist.orig'

out = 'lib'

# compile coffeescript
gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe coffee().on 'error', gutil.log
    .pipe gulp.dest './lib/'

# minify and make standalone
gulp.task 'minify', ['coffee'], ->
  gulp.src './lib/nfsub.js'
    .pipe browserify
      standalone: 'nfsub'
    .pipe uglify()
    .pipe rename 'nfsub.min.js'
    .pipe gulp.dest './lib/'


orig = (s) -> s.replace '.orig', ''

# substitute versions into place
gulp.task 'substitute', ->

  version = "#{pkg.version}.#{moment().format('YYYYMMDDHHmmssSSS')}"

  gulp.src paths.header
    .pipe replace '@@@VERSION@@@', version
    .pipe rename orig(paths.header)
    .pipe gulp.dest './'

  gulp.src paths.infopl
    .pipe replace '@@@VERSION@@@', version
    .pipe rename orig(paths.infopl)
    .pipe gulp.dest './'


# concat header file with minified
gulp.task 'concat', ['substitute', 'minify'], ->
  gulp.src ['./header.js', './lib/nfsub.min.js']
    .pipe concat 'nfsub.user.js'
    .pipe gulp.dest './'
    .pipe gulp.dest './NFSub.safariextension'

# make it a single standalone file
gulp.task 'package', ['concat'], ->

gulp.task 'default', ['package']

gulp.task 'watch', ['default'], ->
  # watch to rebuild
  sources = (v for k, v of paths)
  gulp.watch sources, ['default']
  gulp.src '.'
    .pipe webserver
      livereload: false
      directoryListing: true
