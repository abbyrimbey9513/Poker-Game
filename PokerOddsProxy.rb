#Concrete class that derives from APIProxy and makes a call the the supplied holdemdapi

require "json"
require 'open-uri'
require "./APIProxy.rb"

class PokerOddsProxy < APIProxy
    def initialize()
        @url = "http://stevenamoore.me/projects/holdemapi?"
    end
    def setUpAndMakeCall(cards, board, players)
        #cards=AsKs&board=Ts9sJs&num_players=4"
        # puts cards.class()
        # puts board.class()
        # puts players.class()
        @url = "http://stevenamoore.me/projects/holdemapi?"
        @url = @url + "cards=" + cards + "&board=" + board + "&num_players=" + players
        #puts @url
        begin
            @response = open(@url).read
            #puts @response
            return @response
        rescue OpenURI::HTTPError => error
            @response = error.io
            @response.status
            return @response = "error"
        end

    end
#Then user can call parseJSON with the response
end
