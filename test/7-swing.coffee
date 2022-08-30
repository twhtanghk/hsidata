log4js = require 'log4js'
log4js
  .configure
    appenders:
      order:
        type: 'file'
        filename: 'log/order.log'
      backtest:
        type: 'file'
        filename: 'log/backtest.log'
      strategy:
        type: 'file'
        filename: 'log/strategy.log'
      console:
        type: 'console'
    categories:
      order:
        appenders: ['order']
        level: 'debug'
      backtest:
        appenders: ['backtest']
        level: 'debug'
      strategy:
        appenders: ['strategy']
        level: 'debug'
      default:
        appenders: ['console']
        level: 'info'
logger = log4js.getLogger 'backtest'

addStream = require 'add-stream'
{support, resistance, recent_low, recent_high} = require 'ta.js'
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
  count = 20
###
  it 'range filter', (done) ->
    i = 0
    data = []
    historical = exchange.historical opts
    realtime = exchange.stream opts
    historical
      .pipe addStream.obj realtime
      .pipe new Transform 
        readableObjectMode: true
        writableObjectMode: true
        transform: (chunk, encoding, cb) ->
          {date, close} = chunk
          data.push close
          data = data[-count..]
          low = (await recent_low data, count).value
          high = (await recent_high data, count).value
          logger.info
            date: date
            close: close
            recent_low: low
            recent_high: high
            percent: 100 * (high - low) / close
          cb null, chunk
      .on 'data', ->
        if ++i > 500
          historical.destroy()
          realtime.destroy()
          done()
###
  it 'range action', (done) ->
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
      .pipe new filter.Range()
      .pipe bus
      .on 'data', (data) ->
        logger.debug data
      .on 'end', ->
        logger.info await order.value()
        logger.info order.capital
        realtime.destroy()
        done()
