_ = require 'lodash'
db = require('monk')(process.env.DB)
{Stock} = require 'yahoo-stock'
{Readable, Writable} = require 'stream'
{EMAStrategy} = require '../strategy'

class Price extends Readable
  index: 0
  data: null

  constructor: ({symbol, days}) ->
    super objectMode: true
    return do =>
      @data = await db
        .get 'price'
        .find {symbol}, sort: date: 1
      @

  _read: ->
    @push if @index < @data.length then @data[@index++] else null

describe 'hsi', ->
  it 'strategy', ->
    (await new Price symbol: '^hsi')
      .pipe new EMAStrategy {capital: 50, stopLossPercent: 0.05}
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
