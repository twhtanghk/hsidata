_ = require 'lodash'
{Transform} = require 'stream'
{ema} = require 'ta.js'

class Strategy extends Transform
  df: []
  action: []

  constructor: ({@capital, @stopLossPercent}) ->
    super
      readableObjectMode: true
      writableObjectMode: true

  _transform: (data, encoding, callback) ->
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
  crossUp: false

  crossDn: false
  
  _transform: (data, encoding, callback) ->

    # keep last 120 records only
    @df = @df[-120..]

    # extract close price
    close = @df.map ({close}) ->
      close

    # get ema 20, 60, 120 
    if @df.length >= 20
      _.extend data, ema20: (await ema(close[-20..], 20))[0]
    if @df.length >= 60
      _.extend data, ema60: (await ema(close[-60..], 60))[0]
    if @df.length >= 120
      _.extend data, ema120: (await ema(close[-120..], 120))[0]

    [..., last] = @df

    # fire buyRule if current ema20 > ema60 first met
    if last?.ema20 <= last?.ema60 and data.ema20 > data.ema60
      @buyRule data

    # fire sellRule if current ema20 < ema60 first met
    if last?.ema20 >= last?.ema60 and data.ema20 < data.ema60
      @sellRule data

    super data, encoding, callback

    callback null, data

module.exports = {Strategy, EMAStrategy}
