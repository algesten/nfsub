gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
gutil      = require 'gulp-util'
browserify = require 'gulp-browserify'
uglify     = require 'gulp-uglify'
webserver  = require 'gulp-webserver'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'

paths =
  coffee: './src/**/*.coffee'
  header: './header.js'

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

# concat header file with minified
gulp.task 'tampermonkey', ['minify'], ->
  gulp.src [paths.header, './lib/nfsub.min.js']
    .pipe concat('tamper.js')
    .pipe gulp.dest './'

# make it a single standalone file
gulp.task 'package', ['tampermonkey'], ->

gulp.task 'default', ['package']

gulp.task 'watch', ['default'], ->
  # watch to rebuild
  sources = (v for k, v of paths)
  gulp.watch sources, ['default']
  gulp.src '.'
    .pipe webserver
      livereload: false
      directoryListing: true
