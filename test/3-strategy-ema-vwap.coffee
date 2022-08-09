{Writable} = require 'stream'
db = require('monk')(process.env.DB)
{MongoSrc} = require '../strategy'
{EMA, VWAP, EMACrossover, VWAPCrossover} = require '../filter'
{EMA_VWAP} = require '../action'

describe 'hsi', ->
  it 'strategy', ->
    (new MongoSrc symbol: 'ETH/USD')
      .pipe new EMA()
      .pipe new VWAP()
      .pipe new EMACrossover()
      .pipe new VWAPCrossover()
      .pipe new EMA_VWAP()
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          # console.log data
          callback()
      .on 'finish', ->
        db.close()
      .on 'error', console.error
