_ = require 'lodash'
{Stock} = require 'yahoo-stock'
db = require('monk')(process.env.DB)

symbol = '^hsi'
days = 365

describe "get #{symbol} price data", ->
  it "for #{days} days", ->
    stock = new Stock symbol
    data = (await stock.historicalPrice())
      .map (price) ->
        db.insert _.extend price, date: new Date price.date * 1000
