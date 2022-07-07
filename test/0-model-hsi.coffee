_ = require 'lodash'
req = require 'supertest'
{browser, stockMqtt, Peers} = require 'aastocks'

describe 'model', ->

  it 'create hsi', ->
    peers = new Peers
      browser: await browser()
      mqtt: stockMqtt()
    list = await peers.constituent process.env.HSI
    for stock in list
      _.extend stock,
        symbol: stock.symbol.padStart 5, '0'
        type: 'Buy'
        quantity: 1
        notes: 'created by hsidata'
        tags: ['hsi']
      await req '172.17.0.1:8080/portfolio'
        .post'/api/portfolio'
        .set 'Authorization', "Bearer #{process.env.TOKEN}"
        .set 'Content-Type', 'application/json'
        .send stock
        .expect 200
        .then (res) ->
          console.log res.body
        .catch console.error
    peers.mqtt.end()
