exchange = require '../exchange'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require '../filter'
action = require '../action'
{Order} = require '../order'

describe 'binance', ->
  binance = new exchange.Binance {}
  symbol = 'ETHBUSD'
  opts = 
    symbol: symbol
    interval: '15m'
  capital = [
    {amount: 0.05, unit: 'ETH'}
    {amount: 0, unit: 'BUSD'}
  ]

  it 'historical', (cb) ->
    historical = binance.historical opts
    bus = new action.EMA symbol: symbol
    order = new Order
      exchange: binance
      capital: JSON.parse JSON.stringify capital
      bus: bus
    historical
      .pipe new EMA()
      .pipe new EMACrossover()
      .pipe new Volatility()
      .pipe new VWAP()
      .pipe new VWAPCrossover()
      .pipe bus
      .on 'data', ->
      .on 'end', ->
        {price} = await binance.price {symbol}
        if order.capital[1].amount != 0
          order.capital[0].amount = order.capital[1].amount / price
          order.capital[1].amount = 0
        percent = 100 * order.capital[0].amount / capital[0].amount
        console.log order.capital
        console.log "#{order.capital[0].amount}/#{capital[0].amount}: #{percent}%"
        cb()
