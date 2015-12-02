require 'sinatra'
require 'net/http'
require 'erb'
require 'json'

module Sinatra
  class Base
    set :server, %w(thin mongrel webrick)
    set :bind, '0.0.0.0'
    set :port, 8080
    set :views, File.dirname('.') + '/views'
  end
end

host=ENV['INFLUXDB_PORT_8086_TCP_ADDR']
username=ENV['INFLUXDB_USERNAME']
password=ENV['INFLUXDB_PASSWORD']
port=ENV['INFLUXDB_PORT_8086_TCP_PORT']
database="db"

$create_database_uri = "http://#{host}:#{port}/query?u=#{username}&p=#{password}&q=create database #{database}"
$query_uri = "http://#{host}:#{port}/query?u=#{username}&p=#{password}&db=#{database}&q=select * from sin"
$write_uri = "http://#{host}:#{port}/write?u=#{username}&p=#{password}&db=#{database}"

get '/' do
  n = 0
  Net::HTTP.get(URI($create_database_uri))
  Array(1..90).each do |e|
    Net::HTTP.start(URI($write_uri).host, URI($write_uri).port) do |http|
      http.request_post($write_uri, "sin,val=#{e} value=#{Math.sin(Math::PI / 180 * e)}")
      n += 1
    end
  end
  erb :index, locals: { n: n }
end

get '/info' do
  res = JSON.parse(Net::HTTP.get(URI($query_uri)))
  erb :info, locals: { info: res }
end
