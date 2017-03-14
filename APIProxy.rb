#An Abstract Class that should work for any API call with a JSON response
require "json"
class APIProxy
    def initialize()
        raise NoMethodError
    end

    def parseJSON(json_string)
        #puts"In api proxy"
        result_hash = JSON.parse(json_string)
        if (result_hash.has_key?("error"))
            result_hash.clear()
            num = Random.new
            result_hash["odds"] = num.rand(1.0)
        end
        return result_hash
    end


end
