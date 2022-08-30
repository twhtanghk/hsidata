log4js = require 'log4js'
log4js
  .configure
    appenders:
      order:
        type: 'file'
        filename: 'log/order.log'
      macd:
        type: 'file'
        filename: 'log/macd.log'
      strategy:
        type: 'file'
        filename: 'log/strategy.log'
      console:
        type: 'console'
    categories:
      order:
        appenders: ['order']
        level: 'debug'
      macd:
        appenders: ['macd']
        level: 'debug'
      strategy:
        appenders: ['strategy']
        level: 'debug'
      default:
        appenders: ['console']
        level: 'info'
logger = log4js.getLogger 'macd'

{Binance} = require '../exchange'
{Transform} = require 'stream'
filter = require '../filter'
action = require '../action'
{Order} = require '../order'

describe 'swing trade', ->
  exchange = new Binance {}
  symbol = 'ETHBUSD'
  opts =
    symbol: symbol
    interval: '1m'

  it 'macd', (done) ->
    historical = exchange.historical opts
    bus = new action.MACD()
    order = new Order
      exchange: exchange
      capital: [
        {amount: 0.1, unit: 'ETH'}
        {amount: 0, unit: 'BUSD'}
      ]
      bus: bus
    historical
      .pipe new filter.RSI()
      .pipe new filter.Range()
      .pipe new filter.MACD()
      .pipe bus
      .on 'data', (data) ->
        logger.debug data
      .on 'end', ->
        logger.info await order.value()
        logger.info order.capital
        done()
