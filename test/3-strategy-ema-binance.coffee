{Writable} = require 'stream'
{BinanceSrc} = require '../strategy'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'

describe 'binance', ->
  it 'ethbtc in 1m', ->
    new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
      .on 'data', console.log
      .pipe new EMA()
      .pipe new EMACrossover()
      .pipe new Volatility()
      .pipe new action.EMA()
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log data
          callback()
      .on 'error', console.error
