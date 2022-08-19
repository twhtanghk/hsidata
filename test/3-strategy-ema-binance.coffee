{Writable} = require 'stream'
exchange = require '../exchange'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'

describe 'binance', ->
  exchange = new exchange.Binance {}

  it 'ethbtc in 1m', ->
    symbol = 'ETHBUSD'
    exchange
      .stream symbol: symbol, interval: '1m'
      .pipe new EMA()
      .pipe new EMACrossover()
      .pipe new Volatility()
      .pipe new action.EMA 
        exchange: exchange
        symbol: symbol
        capital: [
          {amount: 0, unit: 'ETH'}
          {amount: 100, unit: 'BUSD'}
        ]
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log data
          callback()
      .on 'error', console.error
