exchange = require '../exchange'
{EMA, EMACrossover, Range} = require '../filter'
action = require '../action'
{Order} = require '../order'

describe 'binance', ->
  binance = new exchange.Binance {}
  symbol = 'ETHBUSD'
  opts = 
    symbol: symbol
    interval: '15m'
  capital = [
    {amount: 0.1, unit: 'ETH'}
    {amount: 0, unit: 'BUSD'}
  ]

  it 'ema crossover', (cb) ->
    historical = binance.historical opts
    bus = new action.EMA symbol: symbol
    order = new Order
      exchange: binance
      capital: JSON.parse JSON.stringify capital
      bus: bus
    historical
      .pipe new EMA()
      .pipe new EMACrossover()
      .pipe bus
      .on 'data', ->
      .on 'end', ->
        console.log "result: #{await order.value symbol}"
        console.log order.capital
        cb()

  it 'range', (cb) ->
    historical = binance.historical opts
    bus = new action.Range symbol: symbol
    order = new Order
      exchange: binance
      capital: JSON.parse JSON.stringify capital
      bus: bus
    historical
      .pipe new Range()
      .pipe bus
      .on 'data', ->
      .on 'end', ->
        console.log "result: #{await order.value symbol}"
        console.log order.capital
        cb()
