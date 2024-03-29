{Writable} = require 'stream'
{Strategy, BinanceSrc, EMA, VWAP, EMACrossover, VWAPCrossover} = require '../strategy'

class EMAAction extends Strategy
  _transform: (data, encoding, callback) ->
    super data, encoding, callback
    # keep last 20 records only
    @df = @df[-20..]

    ind = @df.map ({emaCrossover, vwapCrossover}) ->
      {emaCrossover, vwapCrossover}
    [..., curr] = ind
    if curr.emaCrossover + curr.vwapCrossover != 0
      res = 0
      for {emaCrossover, vwapCrossover} in ind by -1
        res += emaCrossover + vwapCrossover
        console.log "res=#{res}"
        # res should fall between [-2..2]
        if res == 2
          @buyRule data
          break
        else if res == -2
          @sellRule data
          break
        else if res in [1, -1]
          continue
        else
          break

    callback null, data

describe 'binance', ->
  it 'ethbtc in 1m', ->
    new BinanceSrc {symbol: 'ETHBUSD', interval: '1m'}
      .pipe new EMA()
      .pipe new VWAP()
      .pipe new EMACrossover()
      .pipe new VWAPCrossover()
      .pipe new EMAAction()
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log data
          callback()
      .on 'error', console.error
