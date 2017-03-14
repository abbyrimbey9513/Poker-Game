
class Card
    attr_reader :value
    attr_reader :suit
    def initialize(val, suit)
        @value = val
        @suit = suit
    end

    def cardToString(card)
        card_string = card.value + card.suit
        return card_string
    end
end
