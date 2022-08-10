{Writable} = require 'stream'
{BinanceSrc} = require '../strategy'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'

describe 'binance', ->
  it 'order test', ->
    binance = new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
    console.log await binance
      .orderTest
        side: 'BUY'
        quantity: '1'
        price: '1780'
