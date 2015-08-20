axis            = require 'axis'
rupture         = require 'rupture'
autoprefixer    = require 'autoprefixer-stylus'
jeet            = require 'jeet'
browserify      = require 'roots-browserify'
css_pipeline    = require 'css-pipeline'
dynamic_content = require 'dynamic-content'

module.exports =
  ignores: ['readme.md', '**/layout.*', '**/_*', '.gitignore', 'ship.*conf']

  extensions: [
    dynamic_content(),
    browserify(files: 'assets/js/main.coffee', out: 'js/build.js'),
    css_pipeline(files: 'assets/css/*.styl')
  ]

  stylus:
    use: [ axis(), rupture(), autoprefixer(), jeet()  ]
    sourcemap: true

  'coffee-script':
    sourcemap: true

  jade:
    pretty: true

  server:
    clean_urls: true
