require "./PokerOddsProxy.rb"
require "./Deck.rb"

class Table
    attr_reader :players_at_table
    attr_accessor :board
    attr_accessor :numPlaying
    attr_reader :winner

    include Enumerable

    def each(&block)
        @players_at_table.each {|player|
        yield player
        }
    end

    def initialize()
        @pokerProxy = PokerOddsProxy.new()
        @players_at_table = []
        @board = String.new()
        @num_Playing = 0
        @pot_size = 0
        @deck = Deck.new()
        @user #= Player.new()
        @dealer #= Player.new()
        @bet = 5
        @winner = String.new()
    end
    def setUser(user)
        @user = user
        puts @user.class()
    end
    def addPlayer(player)
        @players_at_table << player
        @num_Playing += 1
    end
    def setDealer()
        weHaveANewDealer = false
        @players_at_table.each{|player|
            if (player.playing)
                if(!player.hasBeenDealer)
                    player.hasBeenDealer = true
                    @dealer = player
                    weHaveANewDealer = true
                end
            end
        }
        if(!weHaveANewDealer)
            #puts"We do not have a new dealer"
            @players_at_table.each{|player|
                if (player.playing)
                    player.hasBeenDealer = false
                end
            }
            @players_at_table.each{|player|
                if (player.playing)
                    player.hasBeenDealer = true
                    @dealer = player
                end
                break
            }
        end
        #@dealer = @players_at_table[ @players_at_table.size() - 1]
        print ("Dealer: " + @dealer.name + "\n")
    end
    def removePlayer(player_name)
        @players_at_table.each{ |player|
            if(player.name == player_name)
                @players_at_table.delete(player)
            end
            }
    end
    def playGame()
        @deck.shuffleDeck()
        if(createAroundTableArray())
            return true
        end
        dealHands()
        dealHands()
        getOdds()
        if(checkIfAutomaticWinner())
            return true
        end
        placeBetOrCheck()
        @deck.burnCard()
        @board += @deck.getFlop
        print("Board: " + @board + "\n" + "Pot size: " + @pot_size.to_s + "\n")
        @bet = @pot_size/2
        getOdds()
        if(checkIfAutomaticWinner())
            return true
        end
        placeBetOrCheck()
        @deck.burnCard()
        @board += @deck.dealCard
        print("Board: " + @board + "\n" + "Pot size: " + @pot_size.to_s + "\n")
        @bet = @pot_size/2
        getOdds()
        if(checkIfAutomaticWinner())
            return true
        end
        placeBetOrCheck()
        @deck.burnCard()
        @board += @deck.dealCard
        print("Board: " + @board + "\n"+ "Pot size: " + @pot_size.to_s + "\n")
        determineWinner()
        return updatePlayersAtTable()
    end

    def createAroundTableArray()
        @aroundTable = Array.new()
        startingIDX = -1
        for i in 0..@players_at_table.size()-1
            if(@players_at_table[i].chips > 0)
                if (@players_at_table[i].name == @dealer.name)
                    startingIDX = i
                end
            end
        end
        count = 0
        for i in startingIDX..@players_at_table.size()-1
            if(@players_at_table[i].chips > 0)
                @aroundTable << @players_at_table[i]
                #puts @players_at_table[i]
                #puts @aroundTable[0]
                @aroundTable[0].playing = true
                count += 1
            end
        end
        for i in 0..startingIDX-1
            if(@players_at_table[i].chips > 0)
                @aroundTable << @players_at_table[i]
                #puts @aroundTable[count].class
                @aroundTable[count].playing = true
                count += 1
            end
        end
        if(@aroundTable.size() == 1)
            updatePlayersAtTable()
            @winner = @aroundTable[0].name
            return true
        else
            return false
        end
    end
    def dealHands()
        @aroundTable.each{|player|
            temp_hand = @deck.dealCard()
            player.setHand(temp_hand)
            #print("Here are cards: " + player.getHand() + "\n")
            if(player.name == @user.name)
                print("Here are your cards: " + player.getHand() + "\n")
            end
        }
    end
    def getOdds();
        @aroundTable.each{|player|
            if(player.playing)
                print(player.name, "'s thinking..\n" )
                if(player.name != @user.name)
                    cards = player.getHand()
                    from_API = @pokerProxy.setUpAndMakeCall(cards, @board, @aroundTable.size().to_s)
                    if(from_API != "error")
                        hash = @pokerProxy.parseJSON(from_API)
                        playing = player.determineToPlay(hash)
                        player.playing = playing
                    end
                    #Need to add a playing field to player
                    #and set if they are playing the round.
                end
            end
        }
    end
    def checkIfAutomaticWinner()
        num_playing = 0
        @aroundTable.each{|player|
            if(player.playing)
                num_playing += 1
                @winner = player.name
            end
        }
        if(num_playing <= 1)
            puts"There's an automatic winner"
            puts @winner

            updatePlayersAtTable()
            return true
        end
        return false
    end
    #Everyone is going to bet the same amount if they are playing
    #if they can check want to see if they will check.
    #if they are checking then dont get bet ow. do get bet

    def placeBetOrCheck()
        playersChecking = []
        canCheck = true
        @aroundTable.each{|player|
            if(player.name == @user.name)
                if(player.playing)
                    if(canCheck)
                        puts "Do you want to 1: bet, 2: check, or 3: fold?"
                        answer = gets().chomp()
                        if(answer == "1")
                            player.playing = true
                        elsif (answer == "2")
                            player.checking = true
                            playersChecking << player.name
                        else
                            player.playing = false
                            player.numFolds += 1
                        end
                    else #cannot check
                        puts "Do you want to 1: bet or 2:fold?"
                        answer = gets().chomp()
                        if(answer == "1")
                            player.playing = true
                        else #answer == "2")
                            player.playing = false
                            player.numFolds += 1
                        end
                    end
                end
            end
            if(player.playing)
                if(canCheck)
                    if(!player.checking)
                        print(player.name + " is placing bet.. \n")
                        @pot_size += player.getBet(@bet)
                        print(player.name + " chips left: " + player.chips.to_s + "\n")
                        canCheck = false
                    else
                        print(player.name + " is checking.. \n")
                        playersChecking << player.name
                    end
                else
                    print(player.name + " is placing bet.. \n")
                    @pot_size += player.getBet(@bet)
                    print(player.name + " chips left: " + player.chips.to_s + "\n")
                end
            else
                print(player.name + " is out \n")
            end
        }
        haventBeenAsked = true
        if (playersChecking.size() > 0)
            for i in 0..playersChecking.size() -1
                @players_at_table.each{|player|
                if(player.name == playersChecking[i])
                    if(player.name == @user.name && haventBeenAsked)
                        if(player.playing)
                            haventBeenAsked = false
                            puts "Do you want to 1: bet or 2:fold?"
                            answer = gets().chomp()
                            if(answer == "1")
                                player.playing = true
                                print(player.name + " is placing bet.. \n")
                                @pot_size += player.getBet(@bet)
                                print(player.name + " chips left: " + player.chips.to_s + "\n")
                            else #answer == "2")
                                player.playing = false
                                print(player.name + " is out \n")
                            end
                        end#Player.playing
                    end#End player.name == user.name
                else
                    if(player.playing)
                        print(player.name + " is placing bet.. \n")
                        @pot_size += player.getBet(@bet)
                        print(player.name + " chips left: " + player.chips.to_s + "\n")
                    else
                        print(player.name + " is out \n")
                    end
                end
            }#Ends the each block
        end #Ends for loop
        playersChecking.clear()
    end #End if block
end #end method

    def determineWinner()
        puts "Calculating Winner.."
        cards = String.new()
        @aroundTable.each{|player|
            if(player.playing)
                cards += player.getHand()
            end
        }
        from_API = @pokerProxy.setUpAndMakeCall(cards, @board, @aroundTable.size().to_s)
        hash = @pokerProxy.parseJSON(from_API)
        winningCards = hash["cards"]
        winningCards = winningCards[0..3]
        @aroundTable.each{ |player|
            if(player.getHand() == winningCards)
                puts "Winner is"
                puts player.name
                player.numWins += 1
                player.collectWinnings(@pot_size)
            end
        }
    end

    def updatePlayersAtTable()
        num = 0
        value = @players_at_table.size() - 1
        winnerName = ""
        for i in 0..value
            if(@players_at_table[i].chips <= 0)
                #puts "Removing player"
                #puts @players_at_table[i].name
                @players_at_table[i].playing = false
                @players_at_table[i].numLoses += 1
                #removePlayer(@players_at_table[i].name)
                num += 1
            else
                @players_at_table[i].playing = true
                @players_at_table[i].clearHand()
                #puts @players_at_table[i].getHand()
                winnerName = @players_at_table[i].name

            end
        end
        if(value - num == 0)
            @winner = winnerName
            puts @winner
            return true
        end
        @aroundTable.clear
        @deck = Deck.new()
        @board = ""
        return false
    end
end
#The table h;as a deck. the table can cycle through the players and call dealHand
#for every player.
