# Software complexity analysis for CoffeeScript projects.
# CoffeeScript-specific wrapper around escomplex.

'use strict'

coffee = require 'coffee-script-redux'
escomplex = require 'escomplex'

# Public function `analyse`.
#
# Returns an object detailing the complexity of CoffeeScript source code.
#
# @param source {object|array}  The source code to analyse for complexity.
# @param [options] {object}     Options to modify the complexity calculation.
analyse = (source, options) ->
  if Array.isArray source
    return escomplex.analyse source.map((s) ->
      { ast: coffee.parse(s.source), path: s.path }
    ), options

  escomplex.analyse coffee.parse(source), options

exports.analyse = analyse

