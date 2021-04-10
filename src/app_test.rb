# sorry, when I realised that I should have done TDD, I had already completed developing my app, but hopefully this demonstrates some understanding of it....
require "test/unit"
require_relative "method"

class AppTest < Test::Unit::TestCase
    def test_username_registered?
        assert_equal true, username_validation(@users, "noe111") #username "noe111" exists in user.csv
        assert_equal false, username_validation(@users, "noe333") #username "noe333" does not
    end
    def test_username_validation
        assert_equal true, username_validation(@users, "noe333") #username "noe333" meets the requirement of minimum 6 characters with at least 1 letter and is not taken
        assert_equal false, username_validation(@users, "noe111") #username "noe111" meets the requirement but is already taken
        assert_equal false, username_validation(@users, "") #username "" does not meet the requirement of minimum 6 characters with at least 1 letter
    end
    def test_password_validation
        assert_equal true, password_validation("666666") # password "666666" meets the requirement of minimum 6 characters
        assert_equal false, password_validation("") # password "" does not
    end
end