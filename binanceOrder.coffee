exchange = require './exchange'
addStream = require 'add-stream'
{EMA, VWAP, Volatility, EMACrossover, VWAPCrossover} = require './filter'
action = require './action'
{Order} = require './order'

binance = new exchange.Binance {}
symbol = 'ETHBUSD'
opts = 
  symbol: symbol
  interval: '15m'
historical = binance.historical opts
realtime = binance.stream opts
bus = new action.EMA symbol: symbol
order = new Order
  exchange: binance
  capital: [
    {amount: 0.05, unit: 'ETH'}
    {amount: 0, unit: 'BUSD'}
  ]
  bus: bus
historical
  .pipe addStream.obj realtime
  .pipe new EMA()
  .pipe new EMACrossover()
  .pipe new Volatility()
  .pipe new VWAP()
  .pipe new VWAPCrossover()
  .pipe bus
  .on 'data', ->
