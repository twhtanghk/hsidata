class Order
  # capital: [
  #   {amount: 0, unit: 'ETH'}
  #   {amount: 100, unit: 'BUSD'}
  # ]
  constructor: ({@exchange, @capital, @bus}) ->
    @dryRun = not (process.env.DRYRUN? && process.env.DRYRUN == 'false')
    @bus
      .on 'buy', (data) =>
        if @dryRun || (Date.now() - data.date.getTime() < 1000 and not @dryRun)
          @buy data
      .on 'sell', (data) =>
        if @dryRun || (Date.now() - data.date.getTime() < 1000 and not @dryRun)
          @sell data

  usd: ->
    {price} = await exchange.price()
    price = parseFloat price
    capital[0].amount * price + capital[1].amount

  updateCapital: (opts) ->
    {symbol, side, quantity, price} = opts
    switch side
      when 'BUY'
        @capital[0].amount = quantity
        @capital[1].amount = 0
      when 'SELL'
        @capital[0].amount = 0
        @capital[1].amount = quantity * price

  order: (opts) ->
    {symbol, side, quantity, price} = opts
    if @dryRun
      @updateCapital opts
    else
      try
        {orderId} = ret = await @exchange.order opts
        poll = null
        isFilled = =>
          {status} = order = await @exchange.getOrder {symbol, orderId}
          if status in ['FILLED', 'CANCELLED']
            clearInterval poll
          if status == 'FILLED'
            @updateCapital opts
        poll = setInterval isFilled, 3000
      catch err
        console.error err
    console.log @capital
          
  buy: ({symbol, open, high, low, close, date}) ->
    price = (high + low + close) / 3
    if @capital[0].amount * price < @capital[1].amount
      await @order
        symbol: symbol
        side: 'BUY'
        quantity: @capital[1].amount / price
        price: price
     
  sell: ({symbol, open, high, low, close, date}) ->
    price = (high + low + close) / 3
    if @capital[0].amount * price > @capital[1].amount
      await @order
        symbol: symbol
        side: 'SELL'
        quantity: @capital[0].amount
        price: price

module.exports = {Order}
