_ = require 'lodash'
db = require('monk')(process.env.DB)
{Stock} = require 'yahoo-stock'
{Readable, Writable} = require 'stream'
{MongoSrc, EMA, EMACrossover} = require '../strategy'

describe 'hsi', ->
  it 'strategy', ->
    (new MongoSrc symbol: 'ETH/USD')
      .pipe new EMA()
      .pipe new EMACrossover()
      .on 'finish', ->
        for i in @action
          console.log JSON.stringify i
        [..., last] = @df
        console.log "sum of #{@action.length} actions within #{@start} - #{last.date} : #{@analysis()}"
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log JSON.stringify data
          callback()
      .on 'finish', ->
        db.close()
