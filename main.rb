require "./Database.rb"
require "./Player.rb"
require "./Table.rb"
require "./Deck.rb"
require "./Card.rb"
def main()
    ##Possible players.
    puts "Welcome to poker night!"
    puts "What is your name?"
    user_name = gets().chomp()
    puts "How many players at the table? Minimum of 2, maximum of 8."
    table_size = gets().chomp()
    table_size = table_size.to_i(base=10)
    if( 2 <= table_size && table_size <= 8)
        #Setting up the players and table.
        puts "What is the starting chip amount? (At least 5)"
        chips_to_start = gets().chomp()
        chips_to_start = chips_to_start.to_i(base=10)
        if(chips_to_start < 5)
            puts "Invalid Chips. Game Over."
            return
        end
        player_names = ["Dwight", "Jan", "Michael", "Jim", "Pam", "Andy", "Kevin", "Holly"]
        play_style_types = {0 => "Loose Passive", 1 => "Loose Aggressive", 2 => "Tight Aggressive", 3 => "Tight Passive"}
        game_table = Table.new()
        idx = Random.new()
        table_size += 1
        user = Player.new(user_name, "none", chips_to_start)
        game_table.addPlayer(user)
        game_table.setUser(user)
        #Create the Players and add them to the table.
        for index in 0...table_size-1
            temp_name = player_names[index]
            temp_style = play_style_types[idx.rand(0..3)]
            temp_player = Player.new(temp_name, temp_style, chips_to_start)
            game_table.addPlayer(temp_player)
        end
        puts "***********"
        #puts table_size
        stillPlaying = true
        myDB = Database.new("C:\\Users\\Abby\\Desktop\\342\\Project 3\\myJSON.json")
        while(stillPlaying)
            puts "  "
            puts"In while loop"
            game_table.setDealer()
            if(game_table.playGame())
            #if(game_table.players_at_table.size() == 1)
                puts "The world champion winner is: "
                puts game_table.winner
                puts "Do you want to play again? (yes or no)"
                ans = gets().chomp()
                if(ans == "no" || ans == "no")
                    stillPlaying = false
                    myDB.createHash(game_table.players_at_table)
                    myDB.writeDataToFile()
                end
            end
        puts "*****************"
        end
        #myDB.readFile()
    else
        puts "Invalid table size. Game Over."
    end
end
main()
