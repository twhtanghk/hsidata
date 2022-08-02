_ = require 'lodash'
{Transform} = require 'stream'
{ema} = require 'ta.js'

class Strategy extends Transform
  df: []

  constructor: ({@capital, @stopLossPercent}) ->
    super
      readableObjectMode: true
      writableObjectMode: true

  _transform: (data, encoding, callback) ->
    @df.push data

  buyRule: (data) ->
    console.debug "buy at #{data.date}"

  sellRule: (data) ->
    console.debug "sell at #{data.date}"

class EMAStrategy extends Strategy
  crossUp: false

  crossDn: false
  
  _transform: (data, encoding, callback) ->
    super data, encoding, callback
    @df = @df[-120..]
    close = @df.map ({close}) ->
      close
    if @df.length >= 20
      data = _.extend data, ema20: (await ema(close[-20..], 20))[0]
    if @df.length >= 60
      data = _.extend data, ema60: (await ema(close[-60..], 60))[0]
    if @df.length >= 120
      data = _.extend data, ema120: (await ema(close[-120..], 120))[0]
    {ema20, ema60, ema120} = data
    if ema20 > ema60 and not @crossUp
      @crossUp = true
      @crossDn = false
      @buyRule data
    if ema20 < ema60 and not @crossDn
      @crossDn = true
      @crossUp = false
      @sellRule data
    callback null, data

module.exports = {Strategy, EMAStrategy}
