_ = require 'lodash'
{Readable, Transform} = require 'stream'
Binance = require('binance-api-node').default

class Filter extends Transform
  start: null
  df: []

  constructor: ->
    super
      readableObjectMode: true
      writableObjectMode: true

  _transform: (data, encoding, callback) ->
    @start ?= data.date
    @df.push data

class Strategy extends Filter
  action: []

  constructor: ->
    super()
    @on 'finish', ->
      [..., last] = @df
      console.debug "#{@action.length} actions within #{@start} - #{last.date}: #{@analysis()}"

  buyRule: (data) ->
    @action.push
      action: 'buy'
      data: data
    @emit 'buy', data
    console.debug "buy #{@analysis()} #{JSON.stringify data}"

  sellRule: (data) ->
    @action.push
      action: 'sell'
      data: data
    @emit 'sell', data
    console.debug "sell #{@analysis()} #{JSON.stringify data}"

  analysis: ->
    sum = 0
    for {action, data} in @action
      switch action
        when 'buy'
          sum -= data.close
        when 'sell'
          sum += data.close
    sum

class MongoSrc extends Readable
  constructor: ({symbol}) ->
    super objectMode: true
    db = require('monk')(process.env.DB)
    @query = db
      .get 'price'
      .find {symbol}, sort: date: 1
      .each (row, cursor) =>
        @cursor = cursor
        @emit 'data', row
      .then =>
        @emit 'end'
        @cursor.close()
        db.close()

  _read: ->
    @cursor.resume()

  pause: ->
    @cursor?.pause()

  resume: ->
    @cursor?.resume()

class BinanceSrc extends Readable
  constructor: ({@symbol, @interval, @capital}) ->
    super objectMode: true

    @client = Binance
      apiKey: process.env.BINAPI
      apiSecret: process.env.BINSECRET
    @client.ws.candles @symbol, @interval, (candle) =>
      {eventTime, open, high, low, close, volume, isFinal} = candle
      @rate = parseFloat close
      if isFinal
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

  holding: ->
    @rate ?= parseFloat (await @client.avgPrice symbol: @symbol).price
    [src, dst] = @capital
    if src.amount * @rate > dst.amount
      src
    else
      dst
    
  allOrders: (opts) ->
    await @client.allOrders _.defaults(symbol: @symbol, opts)

  myTrades: (opts) ->
    await @client.myTrades _.defaults(symbol: @symbol, opts)

  orderTest: (opts) ->
    await @client.orderTest _.defaults(symbol: @symbol, opts)

module.exports = {
  Filter
  Strategy
  MongoSrc
  BinanceSrc
}
