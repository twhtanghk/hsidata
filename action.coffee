{Strategy} = require './strategy'

class Range extends Strategy
  _transform: (data, encoding, callback) ->
    super data, encoding, callback
    @df = @df[-2..]
    [last, curr] = @df
    {low, high, percent} = curr.range
    if percent > 1
      limit = (high - low) * 0.25
      if last.close <= last.range.low and curr.close > low
        @buy data
      if last.close >= last.range.high and curr.close < high
        @sell data

    callback null, data
  
class EMA extends Strategy
  _transform: (data, encoding, callback) ->
    super data, encoding, callback
    # keep last record only
    @df = @df[-1..]

    if data.emaCrossover == 1
      @buy data
    else if data.emaCrossover == -1
      @sell data

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
          @buy data
          break
        else if res == -2
          @sell data
          break
        else if res in [1, -1]
          continue
        else
          break

    callback null, data

module.exports = {
  EMA
  EMA_VWAP
  Range
}
