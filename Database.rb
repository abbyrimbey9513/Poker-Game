#Encapsulates the Database functionality, such reading in the JSON file, writing the JSON file. Updating the database objects.
require "json"

class Database

    def initialize(file_path)
        @file_path = file_path
        @arrayOfHashes = Array.new()
    end

    def readFile()
        myFile = File.open(@file_path, "r")
        myFile.each_line {|line|
            temp_hash = JSON.parse(line)
            temp_hash.each_key{ |key|
                puts key
                puts temp_hash[key]
            }
        }
        myFile.close
    end
    def createHash(players)
        players.each{|player|
            hash = {
                :"Name: " => player.name,
                :"Number of wins: " => player.numWins,
                :"Number of loses: " => player.numLoses,
                :"Number of folds: " => player.numFolds
            }
            @arrayOfHashes << hash
        }
    end

    def writeDataToFile()
        myFile = File.open(@file_path, "w")
        @arrayOfHashes.each{|h|
            myFile.write(h.to_json)
            myFile.write("\n")
        }
        myFile.close()
    end
end
