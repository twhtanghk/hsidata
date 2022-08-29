_ = require 'lodash'
log4js = require 'log4js'
log4js
  .configure
    appenders:
      order:
        type: 'file'
        filename: 'log/order.log'
      swing:
        type: 'file'
        filename: 'log/swing.log'
      strategy:
        type: 'file'
        filename: 'log/strategy.log'
      console:
        type: 'console'
    categories:
      order:
        appenders: ['order']
        level: 'debug'
      swing:
        appenders: ['swing']
        level: 'debug'
      strategy:
        appenders: ['strategy']
        level: 'debug'
      default:
        appenders: ['console']
        level: 'info'
logger = log4js.getLogger 'swing'

addStream = require 'add-stream'
{support, resistance, recent_low, recent_high} = require 'ta.js'
{Binance} = require './exchange'
{Transform} = require 'stream'
filter = require './filter'
action = require './action'
{Order} = require './order'

exchange = new Binance {}
symbol = 'ETHBUSD'
opts =
  symbol: symbol
  interval: '1m'

historical = exchange.historical opts
realtime = exchange.stream opts
bus = new action.Range {symbol}
order = new Order
  exchange: exchange
  capital: [
    {amount: 0.1, unit: 'ETH'}
    {amount: 0, unit: 'BUSD'}
  ]
  bus: bus
historical
  .pipe addStream.obj realtime
  .pipe new filter.Range()
  .pipe bus
  .on 'data', (data) ->
     logger.debug data
  .on 'end', ->
     logger.info await order.value()
     logger.info order.capital
     realtime.destroy()
