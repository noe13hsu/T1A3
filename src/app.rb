require "csv"
require "tty-prompt"
require "tty-table"
require "colorize"
require "ruby_figlet"
require "lolize"

require_relative "method"
require_relative "menu"
using RubyFiglet
colorizer = Lolize::Colorizer.new

def recommend_and_display_parts(this_user)
    user_selection = recommendation_menu
    case user_selection
    when "I am looking for parts with a certain type and attribute"
        user_selection_type = type_menu #S
        user_selection_attr = attribute_menu #:armor
        display_recommendation_by_type_table(user_selection_type, user_selection_attr)
    when "I am looking for a pilot with a certain job license and type"
        user_selection_job_license = pilot_job_license_menu
        user_selection_type = type_menu
        user_selection_attr = attribute_menu
        user_selection_pilot = display_recommendation_by_pilot_table(user_selection_job_license, user_selection_type, user_selection_attr, this_user)
        to_update_build?("pilot", user_selection_pilot, this_user)
    when "I am looking for parts with a certain word tag and type"
        user_selection_word_tag = word_tag_menu
        user_selection_category = category_menu
        user_selection_weapon_type = weapon_category_menu
    end
end

def display_recommendation_by_pilot_table(user_selection_job_license, user_selection_type, user_selection_attr, this_user)
    filtered_pilots = []
    CSV.foreach("pilot.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:job_1] ==  user_selection_job_license and row[:type] ==  user_selection_type
            filtered_pilots.push(row)
        elsif row[:job_2] ==  user_selection_job_license and row[:type] ==  user_selection_type
            filtered_pilots.push(row)
        end
    end
    filtered_pilots.sort! { |part1, part2| part2[user_selection_attr].to_i <=> part1[user_selection_attr].to_i }
    user_selection_pilot = sorted_parts_menu("pilot", filtered_pilots, 3)
    display_parts_data_table("pilot", user_selection_pilot, this_user)
    return user_selection_pilot
end

# ---------------------------Program---------------------------------------
system("clear")

puts "=== == == == == == == == == == == == == == == == == == == == == == == ===".colorize(:blue)
welcome_message = "WELCOME    TO\n  GBM    HELPER\n"
welcome_message.art!
puts welcome_message.colorize(:blue)
puts ""
puts "=== == == == == == == == == == == == == == == == == == == == == == == ===".colorize(:blue)

users = load_data("user")
is_signed_in = false
user_selection_title = title_menu
case user_selection_title
# ---------------------------Sign-up---------------------------------------
when "Sign up"
    username = request_username("Please enter a username: ")
    is_username_found = username_registered?(username)
    while is_username_found
        username = request_username("Username is already taken\nPlease enter a different username: ")
        is_username_found = username_registered?(username)
    end
    password = request_password("Please enter a password: ")
    puts "Successful sign-up".colorize(:blue)
    append_to_user_csv(username, password)
    users = load_data("user")
    this_user = load_user_details(users, username)
    reset_build(users, this_user)
    is_signed_in = true
# ----------------------------Log in---------------------------------------
when "Log in"
    username = request_username("Please enter your username: ")
    is_username_found = username_registered?(username)
    if is_username_found == true
        this_user = load_user_details(users, username)
        password = ""
        input_count = 0
        input_limit = 3
        out_of_input = false
        while password != this_user[:password] and !out_of_input
            if input_count == 0 
                password = request_password("Please enter your password: ")
                input_count += 1
            elsif input_count > 0 and input_count < input_limit
                puts ("Invalid password").colorize(:red)
                password = request_password("Please enter your password: ")
                input_count += 1
            else
                out_of_input = true
            end
        end
        if out_of_input
            puts "Invalid password\nPlease check your password".colorize(:red)
        else
            puts "Successful login".colorize(:blue)
            is_signed_in = true
        end
    else puts "Username not found".colorize(:red) 
    end
# ----------------------------Quit-----------------------------------------
when "Quit"
    colorizer.write "Thank you for using GBM Helper"    
end
# ----------------------------Signed in------------------------------------
while is_signed_in
    user_selection_feature = feature_menu
    case user_selection_feature
    when "View my current build"
        create_user_data_table(this_user)
    when "Start a new build"
        reset_build(users, this_user)
    when "Search for parts by name"
        user_selection_part, user_selection_category, is_table_created = search_and_display_parts(this_user)
        if is_table_created
            to_update_build?(user_selection_category, user_selection_part, this_user)
        end
    when "Filter and sort parts"
        user_selection_part, user_selection_category = sort_and_display_parts(this_user)
            to_update_build?(user_selection_category, user_selection_part, this_user)
    when "Get a build recommendation"
        recommend_and_display_parts(this_user)
    when "Log out"
        write_to_csv(users)
        is_signed_in = false
        colorizer.write "Thank you for using GBM Helper"
    end
end