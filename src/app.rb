require "csv"
require "tty-prompt"
require "tty-table"
prompt = TTY::Prompt.new

def append_to_user_csv(username, password, head=nil, body=nil, arm=nil, leg=nil, back=nil, weapon_melee=nil, weapon_ranged=nil, shield=nil, pilot=nil)
    CSV.open("user.csv", "a") do |row|
        row << [username, password, head, body, arm, leg, back, weapon_melee, weapon_ranged, shield, pilot]
    end
end

def load_user_details(username)
    CSV.foreach("user.csv", "a+", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        if row[0] == username
            return row
        end
    end
end

def username_registered?(username)
    CSV.foreach("user.csv", "a+") do |row|
        if row[0] == username
            # puts row[0]
            return true
        end
    end
    return false
end

def request_username
    print "Please enter your username: "
    return gets.chomp.downcase
end

def request_password
    print "Please enter your password: "
    return gets.chomp.downcase
end

puts "Welcome to GBM Helper"

user_choice = prompt.select("What would you like to do?") do |menu|
    menu.choice "Sign up"
    menu.choice "Log in"
end

is_signed_in = false
case user_choice
when "Sign up"
    username = request_username
    # puts username
    is_username_found = username_registered?(username)
    while is_username_found
        print "#{username} is already taken \nPlease enter a different username: "
        username = request_username
        # puts username
        is_username_found = username_registered?(username)
    end
    password = request_password
    append_to_user_csv(username, password)
    puts "Successful sign-up "
    is_signed_in = true
    while is_signed_in
        # puts username
        user_choice = prompt.select("What would you like to do?") do |menu|
            menu.choice "Review my current build"
            menu.choice "Start a new build"
            menu.choice "Search for parts by name"
            menu.choice "Filter and sort parts"
            menu.choice "Get a build recommendation"
            menu.choice "Log out"
        end
        case user_choice
        when "Review my current build"
            user_details = load_user_details(username)
            build_table = TTY::Table.new(
                ["Category","Name"], 
                [
                    ["Head", user_details[:head]], 
                    ["Body", user_details[:body]], 
                    ["Arm", user_details[:arm]], 
                    ["Leg", user_details[:leg]], 
                    ["Back", user_details[:back]], 
                    ["Melee Weapon", user_details[:weapon_melee]], 
                    ["Ranged Weapon", user_details[:weapon_ranged]], 
                    ["Shield", user_details[:shield]], 
                    ["Pilot", user_details[:pilot]]
                ])
            puts build_table.render(:unicode, alignments: [:left, :center])
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
    print "Please enter your username: "
    username = request_username
    is_username_found = username_registered?(username)
    if is_username_found == true
        user_details = load_user_details(username)
        password = request_password
        if password == user_details[1]
            puts "Successful login"
            is_signed_in = true
            while is_signed_in
                user_choice = prompt.select("What would you like to do?") do |menu|
                    menu.choice "Review my current build"
                    menu.choice "Search for parts by name"
                    menu.choice "Filter and sort parts"
                    menu.choice "Get a build recommendation"
                    menu.choice "Log out"
                end
                case user_choice
                when "Review my current build"
                    puts build_table.render(:unicode, alignments: [:left, :center])
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
