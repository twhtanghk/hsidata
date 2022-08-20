class Order
  # capital: [
  #   {amount: 0, unit: 'ETH'}
  #   {amount: 100, unit: 'BUSD'}
  # ]
  constructor: ({@exchange, @capital, @bus}) ->
    @bus
      .on 'buy', (data) =>
        @buy data
      .on 'sell', (data) =>
        @sell data

  usd: ->
    {price} = await exchange.price()
    price = parseFloat price
    capital[0].amount * price + capital[1].amount

  buy: ({symbol, open, high, low, close, date}) ->
    ret = null
    price = (high + low + close) / 3
    if @capital[0].amount * price < @capital[1].amount
      try
        {orderId} = ret = await @exchange.order
          symbol: symbol
          side: 'BUY'
          quantity: @capital[1].amount / price
          price: price
        poll = null
        isFilled = =>
          {status} = order = await @getOrder {symbol, orderId}
          if status in ['FILLED', 'CANCELLED']
            clearInterval poll
            @bus.emit 'order', order
          if status == 'FILLED'
            @capital[0].amount = @capital[1].amount / price
            @capital[1].amount = 0
            console.log "busd: #{await @usd()}"
        poll = setInterval isFilled, 3000
      catch err
        console.error err
    ret
     
  sell: ({symbol, open, high, low, close, date}) ->
    ret = null
    price = (high + low + close) / 3
    if @capital[0].amount * price > @capital[1].amount
      try
        {orderId} = ret = await @exchange.order
          symbol: symbol
          side: 'SELL'
          quantity: @capital[0].amount
          price: price
        poll = null
        isFilled = =>
          {status} = order = await @getOrder {symbol, orderId}
          if status in ['FILLED', 'CANCELLED']
            clearInterval poll
            @bus.emit 'order', order
          if status == 'FILLED'
            @capital[1].amount = @capital[0].amount * price
            @capital[0].amount = 0
            console.log "busd: #{await @usd()}"
        poll = setInterval isFilled, 3000
      catch err
        console.error err
    ret

module.exports = {Order}
