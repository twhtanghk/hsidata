_ = require 'lodash'
{Transform} = require 'stream'
{ema} = require 'ta.js'

class Strategy extends Transform
  start: null
  df: []
  action: []

  constructor: ({@capital, @stopLossPercent}) ->
    super
      readableObjectMode: true
      writableObjectMode: true

  _transform: (data, encoding, callback) ->
    @start ?= data.date
    @df.push data

  buyRule: (data) ->
    @action.push
      action: 'buy'
      data: data

  sellRule: (data) ->
    @action.push
      action: 'sell'
      data: data

  analysis: ->
    sum = 0
    for {action, data} in @action
      switch action
        when 'buy'
          sum -= data.close
        when 'sell'
          sum += data.close
    sum

class EMAStrategy extends Strategy
  _transform: (data, encoding, callback) ->

    # extract close price
    close = @df.map ({close}) ->
      close
    close.push data.close

    # get ema 20, 60, 120 
    [ema20, ema60, ema120] = [
      await ema close, 20
      await ema close, 60
      await ema close, 120
    ]
    curr =
      ema20: ema20[ema20.length - 1]
      ema60: ema60[ema60.length - 1]
      ema120: ema120[ema120.length - 1]
    last =
      ema20: ema20[ema20.length - 2]
      ema60: ema60[ema60.length - 2]
      ema120: ema120[ema120.length - 2]

    # fire buyRule if current ema20 > ema60 first met
    if last.ema20 <= last.ema60 and curr.ema20 > curr.ema60
      @buyRule data

    # fire sellRule if current ema20 < ema60 first met
    if last?.ema20 >= last?.ema60 and curr.ema20 < curr.ema60
      @sellRule data

    _.extend data, ema: curr
    super data, encoding, callback

    # keep last 120 records only
    @df = @df[-120..]

    callback null, data

module.exports = {Strategy, EMAStrategy}
