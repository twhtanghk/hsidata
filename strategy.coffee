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

  constructor: ({@exchange, @symbol, @capital}) ->
    super()
    @on 'finish', ->
      [..., last] = @df
      trades = await @exchange.listTrade {symbol: @symbol, startTime: @start}
      console.debug "#{trades.length} actions within #{@start} - #{last.date}: #{await @exchange.listProfitLoss {symbol: @symbol, startTime: @start}}"

  buy: (data) ->
    {date, symbol, close} = data
    if date.getTime() > Date.now() and @capital[0].amount * close < @capital[1].amount
      await @exchange.orderTest
        symbol: symbol
        side: 'BUY'
        quantity: @capital[1].amount / close
        price: close
    console.log "buy #{JSON.stringify @capital} #{JSON.stringify data}"

  sell: (data) ->
    {date, symbol, close} = data
    if date.getTime() > Date.now() and @capital[0].amount * close > @capital[1].amount
      await @exchange.orderTest
        symbol: symbol
        side: 'SELL'
        quantity: @capital[0].amount
        price: close
    console.debug "sell #{JSON.stringify @capital} #{JSON.stringify data}"

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

module.exports = {
  Filter
  Strategy
  MongoSrc
}
