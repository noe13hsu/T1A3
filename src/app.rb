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
        reset_build(this_user)
        is_signed_in = true
# ----------------------------Log in---------------------------------------
    when "Log in"
        username = request_username("Please enter your username: ")
        is_username_found = username_registered?(username)
        if is_username_found == true
            this_user = load_user_details(users, username)
            is_signed_in = password_validation(this_user, is_signed_in)
        else puts "Username not found".colorize(:red) 
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
    when "View my current build"
        create_user_data_table(this_user)
    when "Start a new build"
        reset_build(this_user)
    when "Search for parts by name"
        user_selection = {
            category: "",
            part: ""
        }
        user_selection[:category] = category_menu
        user_selection, search_result = search_parts(user_selection, this_user)
        if search_result.length > 0
            user_selection[:part] = sorted_parts_menu(user_selection[:category], search_result, 1)
            display_parts_data_table(user_selection, this_user)
            to_update_build?(user_selection, this_user)
        end
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
        user_selection[:part] = sorted_parts_menu(user_selection[:category], sort_result, sort_result.length)
        display_parts_data_table(user_selection, this_user)
        to_update_build?(user_selection, this_user)
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
                pilot: ""
            }
            user_selection[:job_license] = pilot_job_license_menu
            user_selection[:type] = type_menu
            user_selection[:attr] = attribute_menu
            filter_result = filter_and_sort_pilots(user_selection, this_user)
            user_selection[:pilot] = sorted_parts_menu(user_selection[:category], filter_result, filter_result.length)
            display_parts_data_table(user_selection, this_user)
            to_update_build?(user_selection, this_user)
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
            filter_result = filter_and_sort_word_tags(user_selection, this_user)
            user_selection[:part] = sorted_parts_menu(user_selection[:category], filter_result, filter_result.length)
            display_parts_data_table(user_selection, this_user)
            to_update_build?(user_selection, this_user)
        end
    when "Log out"
        write_to_csv(users)
        is_signed_in = false
        colorizer.write "Thank you for using GBM Helper"
    end
end