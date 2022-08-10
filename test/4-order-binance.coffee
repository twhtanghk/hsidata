{BinanceSrc} = require '../strategy'

describe 'binance', ->
  binance = new BinanceSrc 
    symbol: 'ETHBUSD'
    interval: '1m'
    capital: [
      {amount: 0, unit: 'ETH'}
      {amount: 100, unit: 'BUSD'}
    ]
  
  it 'get all orders', ->
    console.log await binance.allOrders()

  it 'get all trades (sucess orders)', ->
    console.log await binance.myTrades()

  it 'holding', ->
    console.log await binance.holding()

  it 'order test', ->
    console.log (await binance
      .orderTest
        side: 'BUY'
        quantity: '1'
        price: '1780'
    )
