moment = require 'moment'
exchange = require './exchange'

binance = new exchange.Binance {}
symbol = 'ETHBUSD'
startTime = moment()
  .subtract 12, 'd'
  .toDate()
do ->
  sum =
    ETH: 0
    BUSD: 0
  for i in await binance.listTrade {symbol, startTime}
    {isBuyer, price, qty, time} = i
    price = parseFloat price
    qty = parseFloat qty
    time = new Date time
    console.log {isBuyer, price, qty, time}
    if isBuyer 
      sum.ETH += qty
      sum.BUSD -= price * qty
    else
      sum.ETH -= qty
      sum.BUSD += price * qty
  console.log sum
  {price} = await binance.price {symbol}
  price = parseFloat price
  console.log sum.ETH * price + sum.BUSD
