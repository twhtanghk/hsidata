_ = require 'lodash'
{Stock} = require 'yahoo-stock'
{Readable, Writable} = require 'stream'
{EMAStrategy} = require '../strategy'

class Price extends Readable
  index: 0

  constructor: ({@data}) ->
    super objectMode: true

  _read: ->
    @push if @index < @data.length then @data[@index++] else null

describe 'hsi', ->
  data = null

  it '365 days data', ->
    hsi = new Stock '^hsi'
    data = _
      .sortBy (await hsi.historicalPrice()), 'date'
      .map (price) ->
        _.extend price, date: new Date price.date * 1000
    console.log data.length

  it 'strategy', (done) ->
    new Price {data}
      .pipe new EMAStrategy {capital: 50, stopLossPercent: 0.05}
      .on 'finish', ->
        for i in @action
          console.log JSON.stringify i
        console.log "sum: #{@analysis()}"
      .pipe new Writable
        objectMode: true
        write: (data, encoding, callback) ->
          console.log JSON.stringify data
          callback()
      .on 'finish', done
