exchange = require '../exchange'

describe 'binance', ->
  binance = new exchange.Binance {}

  it 'stream', (cb) ->
    binance
      .stream symbol: 'ETHBUSD', interval: '1m'
      .on 'data', (data) ->
        console.log data
        @destroy()
        cb()

  it 'orderTest', ->
    await binance.orderTest
      symbol: 'ETHBUSD'
      side: 'BUY'
      quantity: '1'
      price: '1985'

  it 'listOrder', ->
    console.log await binance.listOrder symbol: 'ETHBUSD'

  it 'listTrade', ->
    console.log await binance.listTrade symbol: 'ETHBUSD'

  it 'listDeposit', ->
    console.log await binance.listDeposit()

  it 'listWithdrawal', ->
    console.log await binance.listWithdrawal()

  it 'listHolding', ->
    console.log await binance.listHolding()
