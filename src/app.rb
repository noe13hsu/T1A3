require "csv"
require "tty-prompt"
require "tty-table"
require "colorize"
require "ruby_figlet"
require "lolize"

require_relative "argv"
require_relative "method"
require_relative "menu"
using RubyFiglet
colorizer = Lolize::Colorizer.new

# ---------------------------Program---------------------------------------
system("clear")

puts "=== == == == == == == == == == == == == == == == == == == == == == == ===".colorize(:blue)
welcome_message = "WELCOME    TO\n  GBM    HELPER\n"
welcome_message.art!
puts welcome_message.colorize(:blue)
puts ""
puts "=== == == == == == == == == == == == == == == == == == == == == == == ===".colorize(:blue)

users = load_data("user")
has_quit = false
is_signed_in = false 
while !is_signed_in and !has_quit
    case title_menu
# ---------------------------Sign-up---------------------------------------
    when "Sign up"
        username = request_input("Please enter a username: ")
        is_username_validated = username_validation(users, username)
        while !is_username_validated
            puts "Invalid username\nPlease enter at least 6 characters and 1 letter".colorize(:red)
            username = request_input("Please enter a different username: ")
            is_username_validated = username_validation(users, username)
        end
        password = request_input("Please enter a password: ")
        is_password_validated = password_validation(password)
        while !is_password_validated
            puts "Invalid password\nPlease enter at least 6 characters".colorize(:red)
            password = request_input("Please enter a different password: ")
            is_password_validated = password_validation(password)
        end
        puts "Successful sign-up".colorize(:blue)
        append_to_user_csv(username, password)
        users = load_data("user")
        this_user = load_user_details(users, username)
        reset_build(this_user)
        is_signed_in = true
# ----------------------------Log in---------------------------------------
    when "Log in"
        username = request_username("Please enter your username: ")
        this_user = load_user_details(users, username)
        begin
            is_signed_in = log_in(this_user, is_signed_in)
        rescue TypeError
            puts "Username not found".colorize(:red) 
        end
# ----------------------------Quit-----------------------------------------
    when "Quit"
        has_quit = true
        colorizer.write "Thank you for using GBM Helper"    
    end
end
# ----------------------------Signed in------------------------------------
while is_signed_in
    case feature_menu
# ----------------------------View build-----------------------------------
    when "View my current build"
        create_user_data_table(this_user)
# ----------------------------Reset build----------------------------------
    when "Start a new build"
        reset_build(this_user)
# ------------------------------Search-------------------------------------
    when "Search for parts by name"
        user_selection = {
            category: "",
            part: ""
        }
        user_selection[:category] = category_menu
        user_selection, search_result = search_parts(user_selection, this_user)
        begin
            user_selection[:part] = sorted_parts_menu(user_selection[:category], search_result, 1)
            display_parts_data_table(user_selection, this_user)
            to_update_build?(user_selection, this_user)
        rescue NoMethodError
            puts "You have been redirected".colorize(:red)
        end    
# ----------------------------Filter Sort----------------------------------
    when "Filter and sort parts"
        user_selection = {
            category: "",
            weapon_type: "",
            attr: "",
            part: ""
        }
        user_selection[:category] = category_menu
        user_selection[:weapon_type] =  weapon_category_menu(user_selection[:category])
        user_selection[:attr] = attribute_menu
        sort_result = filter_and_sort_by_category(user_selection, this_user)
        begin
            user_selection[:part] = sorted_parts_menu(user_selection[:category], sort_result, sort_result.length)
            display_parts_data_table(user_selection, this_user)
            to_update_build?(user_selection, this_user)
        rescue NoMethodError
            puts "No match found\nYou have been redirected".colorize(:red)
        end
# ----------------------------Recommendation-------------------------------
    when "Get a build recommendation"
        case recommendation_menu
        when "I am looking for parts with a certain type and attribute"
            user_selection = {
                type: "",
                attr: ""
            }
            user_selection[:type] = type_menu
            user_selection[:attr] = attribute_menu
            parts_with_highest_param = get_parts_with_highest_param(user_selection)
            display_parts_with_highest_param_table(user_selection, parts_with_highest_param)
        when "I am looking for a pilot with a certain job license and type"
            user_selection = {
                category: "pilot",
                job_license: "",
                type: "",
                attr: "",
                part: ""
            }
            user_selection[:job_license] = pilot_job_license_menu
            user_selection[:type] = type_menu
            user_selection[:attr] = attribute_menu
            filter_result = filter_and_sort_pilots(user_selection)
            begin
                user_selection[:part] = sorted_parts_menu(user_selection[:category], filter_result, filter_result.length)
                display_parts_data_table(user_selection, this_user)
                to_update_build?(user_selection, this_user)
            rescue NoMethodError
                puts "No pilot found\nYou have been redirected".colorize(:red)
            end
        when "I am looking for parts with a certain word tag and type"
            user_selection = {
                word_tag: "",
                category: "",
                weapon_type: "",
                type: "",
                attr: "",
                part: ""
            }
            user_selection[:word_tag] = word_tag_menu
            user_selection[:category] = category_menu
            user_selection[:weapon_type] = weapon_category_menu(user_selection[:category])
            user_selection[:type] = type_menu
            user_selection[:attr] = attribute_menu
            filter_result = filter_and_sort_word_tags(user_selection)
            begin
                user_selection[:part] = sorted_parts_menu(user_selection[:category], filter_result, filter_result.length)
                display_parts_data_table(user_selection, this_user)
                to_update_build?(user_selection, this_user)
            rescue NoMethodError
                puts "No match found\nYou have been redirected".colorize(:red)
            end
        end
# ----------------------------Log out--------------------------------------
    when "Log out"
        write_to_csv(users)
        is_signed_in = false
        colorizer.write "Thank you for using GBM Helper"
    end
end