logger = require 'log4js'
  .getLogger 'strategy'
_ = require 'lodash'
{Readable, Transform} = require 'stream'
Binance = require('binance-api-node').default

class Filter extends Transform
  start: null
  df: []

  constructor: (opts) ->
    super
      readableObjectMode: true
      writableObjectMode: true

  _transform: (data, encoding, callback) ->
    @start ?= data.date
    @df.push data

class Strategy extends Filter
  constructor: (opts) ->
    super opts

  buy: (data) ->
    @emit 'buy', data
    logger.info "buy #{JSON.stringify data}"

  sell: (data) ->
    @emit 'sell', data
    logger.info "sell #{JSON.stringify data}"

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
