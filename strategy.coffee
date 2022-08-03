_ = require 'lodash'
{Readable, Transform} = require 'stream'
{ema} = require 'ta.js'
Binance = require('binance-api-node').default

class Strategy extends Transform
  start: null
  df: []
  action: []

  constructor: ->
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
    @emit 'buy', data

  sellRule: (data) ->
    @action.push
      action: 'sell'
      data: data
    @emit 'sell', data

  analysis: ->
    sum = 0
    for {action, data} in @action
      switch action
        when 'buy'
          sum -= data.close
        when 'sell'
          sum += data.close
    sum

class EMA extends Strategy
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
    _.extend data,
      ema20: ema20[ema20.length - 1]
      ema60: ema60[ema60.length - 1]
      ema120: ema120[ema120.length - 1]
      
    super data, encoding, callback

    # keep last 120 records only
    @df = @df[-120..]

    callback null, data

class EMACrossover extends Strategy
  _transform: (data, encoding, callback) ->
    super data, encoding, callback

    # keep last 2 records only
    @df = @df[-2..]

    curr = @df[@df.length - 1]
    last = @df[@df.length - 2]

    # fire buyRule if current ema20 > ema60 first met
    if last?.ema20 <= last?.ema60 and curr.ema20 > curr.ema60
      @buyRule data

    # fire sellRule if current ema20 < ema60 first met
    if last?.ema20 >= last?.ema60 and curr.ema20 < curr.ema60
      @sellRule data

    callback null, data
  
class BinanceSrc extends Readable
  constructor: ({@symbol, @interval}) ->
    super objectMode: true

    @client = Binance
      apiKey: process.env.BINAPI
      apiSecret: process.env.BINSECRET
    @client.ws.candles @symbol, @interval, (candle) =>
      {eventTime, open, high, low, close, volume} = candle
      @emit 'data',
        date: new Date eventTime
        open: parseFloat open
        high: parseFloat high
        low: parseFloat low
        close: parseFloat close
        volume: parseFloat volume
        symbol: @symbol

  read: (size) ->
    @pause()

module.exports = {
  BinanceSrc
  Strategy
  EMA
  EMACrossover
}
