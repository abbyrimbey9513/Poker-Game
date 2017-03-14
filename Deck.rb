#Implements Enumerable class to use iterator
#An aggregate card class.
require "./Card.rb"
class Deck
    include Enumerable

    def each(&block)

    end

    def initialize()
        @deck = []
        suits = ["s","h", "c", "d"]
        values = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
        for i in suits
            for ii in values
                new_card = Card.new(ii, i)
                @deck.push(new_card)
            end
        end
    end
    def getDeck()
        return @deck
    end
    def shuffleDeck()
        @deck.shuffle!
    end
    def dealCard()
        shuffleDeck()
        card = @deck.pop()
        hand = card.value.to_s + card.suit.to_s
        return hand
    end
    def burnCard()
        @deck.pop()
    end
    def getFlop()
        flop = String.new()
        for i in 0..2
            flop += dealCard()
        end
        return flop
    end
#Array has a shuffle method
end
