#$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib/workers"
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib/big_earth/blockchain"
require 'sinatra/base'
require "sinatra/config_file"
require 'sinatra/json'
require 'json'
#require 'resque'
require 'blockchain'
module BigEarth
  module Blockchain
    class BlockchainProxy < Sinatra::Base

      register Sinatra::ConfigFile
      config_file './config.yml'
      
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        # Use a *very* strong user/pass
        # TODO: Consider more robust solution than Basic HTTP Auth
        username == ENV['BLOCKCHAIN_PROXY_USERNAME'] and password == ENV['BLOCKCHAIN_PROXY_PASSWORD']
      end
      
      get '/ping.json' do
        content_type :json
        { status: 'pong' }.to_json
        #Resque.enqueue BigEarth::Blockchain::BootstrapChefClient, config
      end
      
      get '/get_best_block_hash.json' do
        blockchain = BigEarth::Blockchain::Blockchain.new
        { hash: blockchain.get_best_block_hash }.to_json
      end
      
      get '/get_block.json/:hash/:verbose' do
        # Parse data into ruby hash
        data = JSON.parse request.body.read
        config = data['config']
        
        blockchain = BigEarth::Blockchain::Blockchain.new
        blockchain.get_block params['hash'], params['verbose']
      end
      
      get '/get_info.json' do
        content_type :json
        blockchain = BigEarth::Blockchain::Blockchain.new
        blockchain.get_info
      end
    end
  end
end