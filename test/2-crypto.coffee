{Writable} = require 'stream'
{BinanceSrc, EMA, OBV, VWAP, Volatility, EMACrossover} = require '../strategy'

describe 'binance', ->
  it 'ethbtc in 1m', ->
    new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
      .pipe new EMA()
      .pipe new Volatility()
      .pipe new OBV()
      .pipe new VWAP()
      .pipe new EMACrossover()
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          # console.log data
          callback()
