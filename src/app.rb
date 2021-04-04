require "csv"
require "tty-prompt"
require "tty-table"
# prompt = TTY::Prompt.new

def append_to_user_csv(username, password, head=nil, body=nil, arm=nil, leg=nil, back=nil, weapon_melee=nil, weapon_ranged=nil, shield=nil, pilot=nil)
    CSV.open("user.csv", "a") do |row|
        row << [username, password, head, body, arm, leg, back, weapon_melee, weapon_ranged, shield, pilot]
    end
end

def write_to_csv(users)
    headers = users.first.headers || ["username", "password", "build"]
    CSV.open("user.csv", "w") do |csv|
        csv << headers
        users.each do |user|
            csv << user
        end
    end
end

def load_user_details(all_users, username)
    all_users.each do |user|
        if user[:username] == username
            return user
        end
    end
end

def username_registered?(username)
    CSV.foreach("user.csv", "a+", headers: true, header_converters: :symbol) do |row|
        if row[:username] == username
            # puts row[0]
            return true
        end
    end
    return false
end

def request_username(message)
    print message
    return gets.chomp.downcase
end

def request_password(message)
    print message
    return gets.chomp.downcase
end

def feature_menu
    prompt = TTY::Prompt.new
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Review my current build"
        menu.choice "Start a new build"
        menu.choice "Search for parts by name"
        menu.choice "Filter and sort parts"
        menu.choice "Get a build recommendation"
        menu.choice "Log out"
    end
end

def title_menu
    prompt = TTY::Prompt.new
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Sign up"
        menu.choice "Log in"
    end
end

def create_table(this_user)
    TTY::Table.new(
        [   "Part",             "Name",                         "  ",   "Type",       "S"],
        [
            ["Head",            this_user[:head],            "  ",   "Armor",      this_user[:head]], 
            ["Body",            this_user[:body],            "  ",   "Melee ATK",  this_user[:body]], 
            ["Arm",             this_user[:arm],             "  ",   "Shot ATK",   this_user[:arm]], 
            ["Leg",             this_user[:leg],             "  ",   "Melee DEF",  this_user[:leg]], 
            ["Back",            this_user[:back],            "  ",   "Shot DEF",   this_user[:back]], 
            ["Melee Weapon",    this_user[:weapon_melee],    "  ",   "Beam RES",   this_user[:weapon_melee]], 
            ["Ranged Weapon",   this_user[:weapon_ranged],   "  ",   "Phys RES",   this_user[:weapon_ranged]], 
            ["Shield",          this_user[:shield],          "  ",   nil,          nil], 
            ["Pilot",           this_user[:pilot],           "  ",   nil,          nil]
        ]
    )  
end

def load_all_users
    all_users = []
    CSV.foreach("user.csv", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        all_users << row
    end
    return all_users
end

users = load_all_users
is_signed_in = false
# p all_users

puts "Welcome to GBM Helper"

user_choice = title_menu

case user_choice
when "Sign up"
    username = request_username("Please enter a username: ")
    is_username_found = username_registered?(username)
    while is_username_found
        username = request_username("Username is already taken\nPlease enter a different username: ")
        is_username_found = username_registered?(username)
    end
    password = request_password("Please enter a password: ")
    puts "Successful sign-up"
    append_to_user_csv(username, password)
    users = load_all_users
    this_user = load_user_details(users, username)
    # p this_user
    is_signed_in = true
    while is_signed_in
        user_choice = feature_menu
        case user_choice
        when "Review my current build"
            current_build = create_table(this_user)
            puts current_build.render(:unicode, alignments: [:left, :center])
        when "Start a new build"
            puts "a"
        when "Search for parts by name"
            puts "b"
        when "Filter and sort parts"
            puts "c"
        when "Get a build recommendation"
            puts "d"
        when "Log out"
            is_signed_in = false
            puts "Thank you for using GBM Helper"
        end
    end
when "Log in"
    username = request_username("Please enter your username: ")
    is_username_found = username_registered?(username)
    if is_username_found == true
        users = load_all_users
        this_user = load_user_details(users, username)
        password = request_password("Please enter your password: ")
        if password == this_user[:password]
            puts "Successful login"
            is_signed_in = true
            while is_signed_in
                user_choice = feature_menu
                case user_choice
                when "Review my current build"
                    current_build = create_table(this_user)
                    puts current_build.render(:unicode, alignments: [:left, :center])
                when "Start a new build"
                    users.each do |user|
                        if user[:username] == this_user[:username]
                            user[:head] = nil
                            user[:body] = nil
                            user[:arm] = nil
                            user[:leg] = nil
                            user[:back] = nil
                            user[:weapon_melee] = nil
                            user[:weapon_ranged] = nil
                            user[:shield] = nil
                            user[:pilot] = nil
                        end
                    end
                    write_to_csv(users)
                when "Search for parts by name"
                    puts "b"
                when "Filter and sort parts"
                    puts "c"
                when "Get a build recommendation"
                    puts "d"
                when "Log out"
                    is_signed_in = false
                    puts "Thank you for using GBM Helper"
                end
            end
        else
            puts "Invalid password"
        end
    else 
        puts "Username not found \nPlease sign up for a new account"
    end
end
