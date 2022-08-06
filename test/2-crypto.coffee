{Writable} = require 'stream'
{BinanceSrc, EMA, OBV, Volatility, EMACrossover} = require '../strategy'

describe 'binance', ->
  it 'ethbtc in 1m', ->
    new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
      .pipe new EMA()
      .pipe new Volatility()
      .pipe new OBV()
      .pipe new EMACrossover()
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          # console.log JSON.stringify data
          callback()
