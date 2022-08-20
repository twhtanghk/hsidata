exchange = require '../exchange'
addStream = require 'add-stream'

describe 'binance', ->
  binance = new exchange.Binance {}

  it 'historical', (cb) ->
    binance
      .historical
        symbol: 'ETHBUSD'
        interval: '1m'
      .on 'data', console.log
      .on 'end', cb

  it 'stream', (cb) ->
    i = 0
    opts = 
      symbol: 'ETHBUSD'
      interval: '1m'
    historical = binance.historical opts
    realtime = binance.stream opts
    historical
      .pipe addStream.obj realtime
      .on 'data', (data) ->
        console.log data
        if ++i > 60
          realtime.destroy()
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
    console.log await binance.listTrade symbol: 'ETHBUSD', startTime: new Date()

  it 'listDeposit', ->
    console.log await binance.listDeposit()

  it 'listWithdrawal', ->
    console.log await binance.listWithdrawal()

  it 'listHolding', ->
    console.log await binance.listHolding()
