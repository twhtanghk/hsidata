{Filter} = require './strategy'
_ = require 'lodash'
{ema, obv, vwap, recent_low, recent_high} = require 'ta.js'
volatility = require 'volatility'

class EMA extends Filter
  _transform: (data, encoding, callback) ->

    # extract close price
    close = @df.map ({close}) ->
      close
    close.push data.close

    # get ema 20, 60, 120 
    [ema20, ema60, ema120] = [
      await ema close, 20
      await ema close, 60
      await ema close, 120
    ]
    _.extend data,
      ema20: ema20[ema20.length - 1]
      ema60: ema60[ema60.length - 1]
      ema120: ema120[ema120.length - 1]
      
    super data, encoding, callback

    # keep last 120 records only
    @df = @df[-120..]

    callback null, data

class OBV extends Filter
  _transform: (data, encoding, callback) ->

    # extract volume
    ind = @df.map ({close, volume}) ->
      [volume, close]
    ind.push [
      data.volume
      data.close
    ]

    [..., lastobv]  =  await obv ind[-20..]
    _.extend data, obv: lastobv

    super data, encoding, callback

    # keep last 20 records only
    @df = @df[-20..]

    callback null, data

# volume weighted average price
class VWAP extends Filter
  _transform: (data, encoding, callback) ->

    # extract average price, volume
    ind = @df.map ({high, low, close, volume}) ->
      [
        (high + low + close) / 3
        volume
      ]
    {high, low, close, volume} = data
    ind.push [
      (high + low + close) / 3
      volume
    ]

    # get vwap 20, 60, 120
    [vwap20, vwap60, vwap120] = [
      await vwap ind, 20
      await vwap ind, 60
      await vwap ind, 120
    ]
    _.extend data,
      vwap20: vwap20[vwap20.length - 1]
      vwap60: vwap60[vwap60.length - 1]
      vwap120: vwap120[vwap120.length - 1]

    super data, encoding, callback

    # keep last 120 records only
    @df = @df[-120..]

    callback null, data

class Volatility extends Filter
  _transform: (data, encoding, callback) ->

    # extract close price
    close = @df.map ({close}) ->
      close
    close.push data.close

    # get ema 20, 60, 120 
    [vol20, vol60, vol120] = [
      volatility close[-20..]
      volatility close[-60..]
      volatility close[-120..]
    ]
    _.extend data, {vol20, vol60, vol120}

    super data, encoding, callback

    # keep last 120 records only
    @df = @df[-120..]

    callback null, data

class EMACrossover extends Filter
  _transform: (data, encoding, callback) ->
    super data, encoding, callback

    # keep last 2 records only
    @df = @df[-2..]

    curr = @df[@df.length - 1]
    last = @df[@df.length - 2]

    if last?.ema20 <= last?.ema60 and curr.ema20 > curr.ema60
      # fire buyRule if current ema20 > ema60 first met
      _.extend data, emaCrossover: 1
    else if last?.ema20 >= last?.ema60 and curr.ema20 < curr.ema60
      # fire sellRule if current ema20 < ema60 first met
      _.extend data, emaCrossover: -1
    else
      _.extend data, emaCrossover: 0

    callback null, data
  
class VWAPCrossover extends Filter
  _transform: (data, encoding, callback) ->
    super data, encoding, callback

    # keep last 2 records only
    @df = @df[-2..]

    curr = @df[@df.length - 1]
    last = @df[@df.length - 2]

    if last.close >= last.vwap20 and curr.close < curr.vwap20
      # if last.close >= last.vwap20 and curr.close < curr.vwap20 buy undervalue
      _.extend data, vwapCrossover: 1
    else if last.close <= last.vwap20 and curr.close > curr.vwap20
      # if last.close <= last.vwap20 and curr.close > curr.vwap20 sell overvalue
      _.extend data, vwapCrossover: -1
    else
      _.extend data, vwapCrossover: 0

    callback null, data
    
class Range extends Filter
  _transform: (data, encoding, callback) ->
    close = @df.map ({close}) ->
      close
    close.push data.close

    low = (await recent_low close, 20).value
    high = (await recent_high close, 20).value
    percent = (100 * (high - low) / data.close).toFixed(2)
    _.extend data, range: {low, high, percent}

    super data, encoding, callback

    @df = @df[-20..]

    callback null, data

module.exports = {
  EMA
  OBV # On-balance volume
  VWAP # volume weighted average price
  Volatility
  EMACrossover
  VWAPCrossover
  Range
}
