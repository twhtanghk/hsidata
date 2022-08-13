{Writable} = require 'stream'
{BinanceSrc} = require '../strategy'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'

describe 'binance', ->
  it 'ethbtc in 1m', ->
    binance = new BinanceSrc 
      symbol: 'ETHBUSD'
      interval: '1m'
      capital: [
        {unit: 'ETH', amount: 0.005}
        {unit: 'BUSD', amount: 0}
      ]
    binance
      .pipe new EMA()
      .pipe new EMACrossover()
      .pipe new Volatility()
      .pipe new action.EMA()
      .on 'buy', (data) ->
        {amount, unit} = await binance.holding()
        if unit == 'BUSD'
          binance.orderTest
            symbol: binance.symbol
            side: 'BUY'
            quantity: amount / data.close
            price: data.close
      .on 'sell', (data) ->
        {amount, unit} = await binance.holding()
        if unit == 'ETH'
          binance.orderTest
            symbol: binance.symbol
            side: 'SELL'
            quantity: amount
            price: data.close
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log data
          callback()
      .on 'error', console.error
