#Contains player’s name, cards, and bankroll
require "./Card.rb"
class Player
    attr_reader :play_style
    attr_reader :name
    attr_accessor :chips
    attr_accessor :playing
    attr_accessor :checking
    attr_accessor :hasBeenDealer
    attr_accessor :numFolds
    attr_accessor :numWins
    attr_accessor :numLoses
    attr_accessor :numGamesPlayed
    def initialize(name, play_style, num_Chips)
        @name = name
        @play_style = play_style
        @chips = num_Chips
        @hand = String.new()
        @playing = true
        @checking
        @hasBeenDealer = false
        @numLoses = 0
        @numWins =0
        @numFolds = 0
        @numGamesPlayed = 0
    end
    def setHand(my_Card)
        #puts my_Card.class()
        @hand += my_Card
    end
    def clearHand()
        @hand = ""
    end

    def determineToPlay(hash)
        #puts @play_style
        if self.play_style == "Loose Passive"
            @checking = false
            if hash["odds"] < 0.5
                playing = true
                return true
            else
                @numFolds += 1
                playing = false
                return false
            end
        elsif self.play_style == "Loose Aggressive"
            @checking = true
            if hash["odds"] > 0.5 #&& @chips < pot_size/2
                playing = true
                return true
            else
                @numFolds += 1
                playing = false
                return false
            end
        elsif self.play_style == "Tight Aggressive"
            @checking = true
            if hash["odds"] < 0.5 #&& @chips > pot_size/2
                playing = true
                return true
            else
                playing = false
                @numFolds += 1
                return false
            end
        elsif self.play_style == "Tight Passive"
            @checking = false
            if hash["odds"] > 0.5 #&& @chips > pot_size/2
                playing = true
                return true
            else
                playing = false
                @numFolds += 1
                return false
            end;
        else
            puts "No play style listed"
        end
    end

    def getBet(bet)
        if(@chips > 0 && @chips - bet >= 0)
            @chips -= bet
            return bet
        else
            @chips = 0
            return 0
        end
    end
    def collectWinnings(winnings)
        @chips += winnings
    end
    def getHand()
        return @hand
    end
end
