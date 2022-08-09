{Strategy} = require './strategy'

class EMA extends Strategy
  _transform: (data, encoding, callback) ->
    super data, encoding, callback
    # keep last record only
    @df = @df[-1..]

    if data.emaCrossover == 1
      @buyRule data
    else if data.emaCrossover == -1
      @sellRule data

    callback null, data

class EMA_VWAP extends Strategy
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

module.exports = {
  EMA
  EMA_VWAP
}
