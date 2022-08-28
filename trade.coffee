{Binance} = require './exchange'
exchange = new Binance {}
[..., symbol, side, quantity, price] = process.argv
quantity = parseFloat quantity
price = parseFloat price
do ->
  console.log await exchange.order {symbol, side, quantity, price}
