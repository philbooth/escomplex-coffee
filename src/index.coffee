# Software complexity analysis for CoffeeScript projects.
# CoffeeScript-specific wrapper around escomplex.

'use strict'

coffee = require 'coffee-script'
escomplex = require 'escomplex'
walker = require './walker'

# Public function `analyse`.
#
# Returns an object detailing the complexity of CoffeeScript source code.
#
# @param source {object|array}  The source code to analyse for complexity.
# @param [options] {object}     Options to modify the complexity calculation.
analyse = (source, options) ->
  if Array.isArray source
    return escomplex.analyse source.map((s) ->
      { ast: coffee.nodes(s.source), path: s.path }
    ), walker, options

  escomplex.analyse coffee.nodes(source), walker, options

exports.analyse = analyse

if module == require.main
  s = '''
  require.config({
    paths: {
      one: "code/one",
      two: "code/two"
    }
  })
  require ['one', 'code/three'], (one, three) ->
    stuff = require './thing'
    res = stuff.run() if stuff.name == "hello"
    a = [1, 2, 3, 4]
    o = {
      foo: 'bar'
      oh: 'no'

    }

    doit = ->
      console.log('done')

    res.process 1234, (err, res) ->
      throw err if err
      console.log(res.code)

  '''
  console.log(JSON.stringify(analyse(s), 0, 2))
