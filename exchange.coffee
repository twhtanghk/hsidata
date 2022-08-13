{Readable} = require 'stream'

class Exchange
  stream: (opts) ->
    return
  
  price: (symbol) ->
    return

  orderTest: ({symbol, side, quantity, price}) ->
    return

  order: ({symbol, side, quantity, price}) ->
    return

  cancelOrder: (opts) ->
    return

  getOrder: ({symbol, orderId}) ->
    return

  listOrder: (opts) ->
    return

  listTrade: (opts) ->
    return

  listDeposit: (opts) ->
    return

  listWithdrawal: (opts) ->
    return

  listHolding: ->
    return

  capital: ->
    return

class Binance extends Exchange
  constructor: ({@connection}) ->
    super()

  stream: ({symbol, interval}) ->
    closeWS = null
    ret = new Readable
      objectMode: true
      construct: (cb) =>
        closeWS = @connection.ws.candles symbol, interval, (candle) ->
          {eventTime, open, high, low, close, volume, isFinal} = candle
          if isFinal
            ret.emit 'data',
              date: new Date eventTime
              open: parseFloat open
              high: parseFloat high
              low: parseFloat low
              close: parseFloat close
              volume: parseFloat volume
              symbol: symbol
        cb() 
      destroy: (err, cb) ->
        closeWS()
        cb()
      read: ->
        @pause()

  price: ({symbol}) ->
    await @connection.avgPrice {symbol}

  orderTest: ({symbol, side, quantity, price}) ->
    await @connection.orderTest {symbol, side, quantity, price}

  order: ({symbol, side, quantity, price}) ->
    await @connection.order {symbol, side, quantity, price}

  cancelOrder: ({symbol, orderId}) ->
    await @connection.cancelOrder {symbol, orderId}

  getOrder: ({symbol, orderId}) ->
    await @connection.getOrder {symbol, orderId}

  listOrder: ({symbol}) ->
    await @connection.allOrders {symbol}

  listTrade: ({symbol}) ->
    await @connection.myTrades {symbol}

  listDeposit: ->
    await @connection.depositHistory status: 1

  listWithdrawal: ->
    await @connection.withdrawHistory status: 6

  listHolding: ->
    (await @connection.accountCoins())
      .map ({coin, free}) ->
        {coin, free}
      .filter ({coin, free}) ->
        free != '0'

module.exports = {
  Exchange
  Binance
}
