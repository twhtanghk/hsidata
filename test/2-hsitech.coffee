_ = require 'lodash'
{browser, stockMqtt, Peers} = require 'aastocks'
{breadth} = require 'analysis'

describe 'hsi', ->
  data = []

  it 'hsi tech constituents', ->
    peers = new Peers
      browser: await browser()
      mqtt: stockMqtt()
    list = await peers.constituent 'http://www.aastocks.com/en/stocks/market/index/hk-index-con.aspx?index=HSTECH'
    for stock in list
      data.push stock['symbol']
    console.log data
    breadth = await breadth data
    console.log breadth
    console.log 
      max: _.maxBy breadth, 'percent'
      min:_.minBy breadth, 'percent'
      mean: _.meanBy breadth, 'percent'
    peers.mqtt.end()
