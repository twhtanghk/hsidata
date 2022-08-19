{Writable} = require 'stream'
db = require('monk')(process.env.DB)
{MongoSrc} = require '../strategy'
{EMA, VWAP, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'
exchange = require '../exchange'

describe 'hsi', ->
  it 'strategy', ->
    (new MongoSrc symbol: 'ETH/USD')
      .pipe new EMA()
      .pipe new VWAP()
      .pipe new EMACrossover()
      .pipe new VWAPCrossover()
      .pipe new action.EMA 
        exchange: new exchange.Binance {}
        symbol: 'ETHUSD', 
        capital: [
          {amount: 0, unit: 'ETH'}
          {amount: 100, unit: 'USD'}
        ]
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          # console.log data
          callback()
      .on 'finish', ->
        db.close()
      .on 'error', console.error
