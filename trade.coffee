{Binance} = require './exchange'
exchange = new Binance {}
[..., symbol, side, quantity, price] = process.argv
quantity = parseFloat quantity
price = parseFloat price
console.log exchange.order {symbol, side, quantity, price}
