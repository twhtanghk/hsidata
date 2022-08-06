{Writable} = require 'stream'
{BinanceSrc, EMA, OBV, Volatility, EMACrossover} = require '../strategy'

describe 'binance', ->
  it 'ethbtc in 1m', ->
    new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
      .pipe new EMA()
      .pipe new Volatility()
      .pipe new OBV()
      .pipe new EMACrossover()
      .on 'buy', (data) ->
        console.debug "buy #{@analysis()} #{JSON.stringify data}"
      .on 'sell', (data) ->
        console.debug "sell #{@analysis()} #{JSON.stringify data}"
      .on 'finish', ->
        for i in @action
          console.log JSON.stringify i
        [..., last] = @df
        console.log "sum of #{@action.length} actions within #{@start} - #{last.date} : #{@analysis()}"
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          # console.log JSON.stringify data
          callback()
