{EOL} = require 'os'
_ = require 'lodash'
{Transform} = require 'stream'
fs = require 'fs'
{parse, transform, stringify} = require 'csv'
db = require('monk')(process.env.DB)

# download crypto price data in csv format via 
# https://www.cryptodatadownload.com/data/bitstamp/#google_vignette
describe "Cryptocurrency", ->
  it "#{process.env.SYMBOL} price data", (done) ->
    fs
      .createReadStream "#{process.env.SYMBOL}.csv"
      .pipe parse columns: true
      .pipe new Transform
        objectMode: true
        transform: (obj, encoding, cb) ->
          data =
            date: new Date obj.unix * 1000
            symbol: obj.symbol
            open: obj.open
            high: obj.high
            low: obj.low
            close: obj.close
            volume: obj['Volume ETH']
          await db
            .get 'price'
            .insert data
          cb null, JSON.stringify(data) + EOL
      .on 'close', ->
        db.close()
        done()
      .pipe process.stdout
