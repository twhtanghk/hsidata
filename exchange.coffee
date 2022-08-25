{Readable} = require 'stream'

class Exchange
  stream: (opts) ->
    return
  
  historical: (opts) ->
    return

  price: (symbol) ->
    return

  orderTest: ({symbol, side, quantity, price}) ->
    return

  order: ({symbol, side, quantity, price}) ->
    return

  cancelOrder: (opts) ->
    return

  getOrder: (opts) ->
    return

  listOrder: (opts) ->
    return

  listTrade: (opts) ->
    return

  listProfitLoss: (opts) ->
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
  ws: {}

  constructor: (opts) ->
    super()
    {apiKey, apiSecret} = opts ?= {}
    apiKey ?= process.env.BINAPI
    apiSecret ?= process.env.BINSECRET
    client = require('binance-api-node').default
    @connection = client {apiKey, apiSecret}

  # realtime data stream
  stream: ({symbol, interval}) ->
    @ws[symbol] = 
      close: null
      stream: new Readable
        objectMode: true
        construct: (cb) =>
          @ws[symbol].close = @connection.ws.candles symbol, interval, (candle) =>
            {eventTime, open, high, low, close, volume, isFinal} = candle
            if isFinal
              @ws[symbol].stream.emit 'data',
                date: new Date eventTime
                open: parseFloat open
                high: parseFloat high
                low: parseFloat low
                close: parseFloat close
                volume: parseFloat volume
                symbol: symbol
          cb() 
        destroy: (err, cb) =>
          @ws[symbol].close()
          cb()
        read: ->
          @pause()
    @ws[symbol].stream

  # historical stream
  historical: ({symbol, interval}) ->
    ret = new Readable
      objectMode: true
      construct: (cb) =>
        for i in (await @connection.candles {symbol, interval})
          {openTime, open, high, low, close, volume} = i
          ret.emit 'data',
            date: new Date openTime
            open: parseFloat open
            high: parseFloat high
            low: parseFloat low
            close: parseFloat close
            volume: parseFloat volume
            symbol: symbol
        ret.emit 'end'
        cb()
      read: ->
        @pause()

  price: ({symbol}) ->
    await @connection.avgPrice {symbol}

  orderTest: ({symbol, side, quantity, price}) ->
    await @connection.orderTest {symbol, side, quantity, price}

  order: ({symbol, side, quantity, price}) ->
    ret = await @connection.order {symbol, side, quantity, price}
    {orderId} = ret
    poll = null
    isFilled = =>
      order = await @getOrder {symbol, orderId}
      {status} = order
      if status in ['FILLED', 'CANCELLED']
        clearInterval poll
        @ws[symbol].emit 'orderFilled', order
    poll = setInterval isFilled, 3000
    ret

  cancelOrder: ({symbol, orderId}) ->
    await @connection.cancelOrder {symbol, orderId}

  getOrder: ({symbol, orderId}) ->
    await @connection.getOrder {symbol, orderId}

  listOrder: ({symbol}) ->
    await @connection.allOrders {symbol}

  listTrade: (opts) ->
    {symbol, startTime} = opts
    startTime = startTime.getTime()
    await @connection.myTrades {symbol, startTime}

  listProfitLoss: (opts) ->
    {symbol, startTime} = opts
    sum = 0
    for trade in await @listTrade {symbol, startTime}
      {orderId, price, qty} = trade
      {side} = await @connection.getOrder {symbol, orderId}
      switch side
        when 'BUY'
          sum -= price * qty
        when 'SELL'
          sum += price * qty
    sum

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
