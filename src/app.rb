require "csv"
require "tty-prompt"
require "tty-table"
require "colorize"
require "ruby_figlet"
require "lolize"

require_relative "method"
using RubyFiglet
colorizer = Lolize::Colorizer.new

def sum_stats(category, user_stats, this_user, ref_attr)
    i = 0
    while i < category.length do
        CSV.foreach("#{category[i]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[ref_attr] == this_user[:"#{category[i]}"]
                user_stats[:armor] += row[:armor].to_i
                user_stats[:melee_atk] += row[:melee_atk].to_i
                user_stats[:shot_atk] += row[:shot_atk].to_i
                user_stats[:melee_def] += row[:melee_def].to_i
                user_stats[:shot_def] += row[:shot_def].to_i
                user_stats[:beam_res] += row[:beam_res].to_i
                user_stats[:phys_res] += row[:phys_res].to_i
                if row[:type] == "S"
                    user_stats[:type][:S] += 1
                elsif row[:type] == "P"
                    user_stats[:type][:P] += 1
                elsif row[:type] == "T"
                    user_stats[:type][:T] += 1
                end
            end
        end
        i += 1
    end
    return user_stats
end

def user_build_stats(this_user)
    non_weapon_categories = ["head", "body", "arm", "leg", "back", "shield", "pilot"]
    weapon_categories = ["weapon_melee", "weapon_ranged"]
    user_stats = {
        armor: 0,
        melee_atk: 0,
        shot_atk: 0,
        melee_def: 0,
        shot_def: 0,
        beam_res: 0,
        phys_res: 0,
        type: {S: 0, P: 0, T: 0}
    }
    sum_stats_non_weapon = sum_stats(non_weapon_categories, user_stats, this_user, :name)
    sum_stats_all_parts = sum_stats(weapon_categories, sum_stats_non_weapon, this_user, :weapon_name)
    return sum_stats_all_parts
end

def create_user_data_table(this_user)
    user_stats = user_build_stats(this_user)
    current_build = TTY::Table.new(
        [   "Part",             "Name",                      "  ",   "Type",       user_type(user_stats)],
        [
            ["Head",            this_user[:head],            "  ",   "Armor",      user_stats[:armor]], 
            ["Body",            this_user[:body],            "  ",   "Melee ATK",  user_stats[:melee_atk]], 
            ["Arm",             this_user[:arm],             "  ",   "Shot ATK",   user_stats[:shot_atk]], 
            ["Leg",             this_user[:leg],             "  ",   "Melee DEF",  user_stats[:melee_def]], 
            ["Back",            this_user[:back],            "  ",   "Shot DEF",   user_stats[:shot_def]], 
            ["Melee Weapon",    this_user[:weapon_melee],    "  ",   "Beam RES",   user_stats[:beam_res]], 
            ["Ranged Weapon",   this_user[:weapon_ranged],   "  ",   "Phys RES",   user_stats[:phys_res]], 
            ["Shield",          this_user[:shield],          "  ",   "Word Tag 1", "-"], 
            ["Pilot",           this_user[:pilot],           "  ",   "Word Tag 2", "-"],
            ["Job",             "-",                         "  ",   "Word Tag 3", "-"]
        ]
    )
    puts current_build.render(:unicode, alignments: [:left, :center, :center, :left, :center], column_widths: [15, 25, 2, 15, 25])  
end

def load_parts(user_choice_category, user_choice_weapon)
    all_parts = []
    case user_choice_category
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            all_parts << row
        end
        return all_parts
    when "weapon_melee", "weapon_ranged"
        CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            if row[:category] == user_choice_weapon
                all_parts << row
            end
        end
        return all_parts
    end
end

def sort_and_display_parts(this_user)
    filter_result = []
    prompt = TTY::Prompt.new(active_color: :blue)
    user_choice_category = category_menu.downcase #weapon_ranged
    user_choice_weapon =  weapon_category_menu(user_choice_category) #rifle
    filter_result = load_parts(user_choice_category, user_choice_weapon) # array of all rifles
    user_choice_stat = attribute_menu #shot atk
    filter_result.sort! { |part1, part2| part2[user_choice_stat].to_i <=> part1[user_choice_stat].to_i } #sort all rifles by highest shot atk
    case user_choice_category
    when "weapon_melee", "weapon_ranged"
        user_choice_part = prompt.select("Please select a part") do |menu| #user_choice_part = rifle name
            filter_result.first(5).each do |part|
                menu.choice part[:weapon_name] #display top 5 rifles 
            end
        end
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        user_choice_part = prompt.select("Please select a part") do |menu| #user_choice_part = rifle name
            filter_result.first(5).each do |part|
                menu.choice part[:name] #display top 5 rifles 
            end
        end
    end
    display_parts_data_table(user_choice_category, user_choice_part, this_user) #(weapon_ranged, rifle name, this_user)
    return user_choice_part, user_choice_category
end

def search_and_display_parts(this_user)
    search_result = []
    search_count = 0
    search_limit = 5
    out_of_search = false
    user_choice_category = category_menu.downcase #melee weapon
    while search_result.length == 0 and !out_of_search
        if search_count < search_limit
            user_choice_part = request_part_name("Please enter a Gundam name: ")
            CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
                headers ||= row.headers
                if row[:name] == user_choice_part
                    search_result.push(row)
                end
            end
            begin
                error_test = 1/search_result.length
            rescue ZeroDivisionError
                puts "Gundam not found".colorize(:red)
            end
            search_count += 1
        else
            out_of_search = true
        end
    end
    if out_of_search
        puts "You have been redirected".colorize(:red)
        return user_choice_part, user_choice_category, false
    end
    prompt = TTY::Prompt.new(active_color: :blue)
    case user_choice_category
    when "weapon_melee", "weapon_ranged"
        user_choice_part = prompt.select("Please select a part") do |menu|
        search_result.each do |part|
            menu.choice part[:weapon_name]
        end
    end
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        user_choice_part = prompt.select("Please select a part") do |menu|
            search_result.each do |part|
                menu.choice part[:name]
            end
        end
    end
    is_table_created = display_parts_data_table(user_choice_category, user_choice_part, this_user)
    return user_choice_part, user_choice_category, is_table_created
end

def part_in_use(user_choice_category, this_user)
    case user_choice_category
    when "weapon_melee", "weapon_ranged"
    CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:weapon_name] == this_user[:"#{user_choice_category}"]
            return row
        end
    end
    return "-"
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:name] == this_user[:"#{user_choice_category}"]
                return row
            end
        end
    return "-"
    end
end

def create_parts_data_table(user_choice_category, user_choice_part, part_in_use, attr)
    CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[attr] == user_choice_part
            part_details = TTY::Table.new(
                [
                    ["Name",            part_in_use[:name],                         "==>",      row[:name]],
                    ["--------------",  "-------------------------",                "",         "-------------------------"],
                    ["Type",            part_in_use[:type],                         "==>",      row[:type]],
                    ["Armor",           part_in_use[:armor],                        "==>",      color_stats(row, part_in_use, :armor)], 
                    ["Melee ATK",       part_in_use[:melee_atk],                    "==>",      color_stats(row, part_in_use, :melee_atk)], 
                    ["Shot ATK",        part_in_use[:shot_atk],                     "==>",      color_stats(row, part_in_use, :shot_atk)], 
                    ["Melee DEF",       part_in_use[:melee_def],                    "==>",      color_stats(row, part_in_use, :melee_def)], 
                    ["Shot DEF",        part_in_use[:shot_def],                     "==>",      color_stats(row, part_in_use, :shot_def)], 
                    ["Beam RES",        part_in_use[:beam_res],                     "==>",      color_stats(row, part_in_use, :beam_res)], 
                    ["Phys RES",        part_in_use[:phys_res],                     "==>",      color_stats(row, part_in_use, :phys_res)],
                    ["--------------",  "-------------------------",                "",         "-------------------------"],
                    ["EX Skill",        part_in_use[:ex_skill_name],                "==>",      row[:ex_skill_name]],
                    ["Skill Type",      part_in_use[:ex_skill_type],                "==>",      row[:ex_skill_type]],
                    ["Pierce",          part_in_use[:ex_skill_pierce],              "==>",      row[:ex_skill_pierce]],
                    ["Power",           part_in_use[:ex_skill_power],               "==>",      row[:ex_skill_power]],
                    ["Initial Charge",  part_in_use[:ex_skill_initial_cooldown],    "==>",      row[:ex_skill_initial_cooldown]],
                    ["Cooldown",        part_in_use[:ex_skill_cooldown],            "==>",      row[:ex_skill_cooldown]],
                    ["--------------",  "-------------------------",                "",         "-------------------------"],
                    ["Trait 1",         part_in_use[:trait_1_description],          "==>",      row[:trait_1_description]],
                    ["Trait 2",         part_in_use[:trait_2_description],          "==>",      row[:trait_2_description]],
                    ["--------------",  "-------------------------",                "",         "-------------------------"],  
                    ["Word Tag 1",      part_in_use[:word_tag_1],                   "==>",      row[:word_tag_1]],
                    ["Word Tag 2",      part_in_use[:word_tag_2],                   "==>",      row[:word_tag_2]],
                    ["--------------",  "-------------------------",                "",         "-------------------------"],
                    ["Source",          part_in_use[:source],                       "==>",      row[:source]]
                ]
            )
            puts part_details.render(:unicode, multiline: true, alignments: [:left, :center, :center, :center], column_widths: [14, 25, 5, 25])
            return true
        end
    end
    puts "Invalid name".colorize(:red)
    return false
end

def display_parts_data_table(user_choice_category, user_choice_part, this_user)
    part_in_use = part_in_use(user_choice_category, this_user)
    case user_choice_category
    when "head", "body", "arm", "leg", "back", "pilot", "shield"
        is_table_created = create_parts_data_table(user_choice_category, user_choice_part, part_in_use, :name)
        return is_table_created
    when "weapon_melee", "weapon_ranged"
        is_table_created = create_parts_data_table(user_choice_category, user_choice_part, part_in_use, :weapon_name)
        return is_table_created
    end  
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
user_choice_title = title_menu
case user_choice_title
# ---------------------------Sign-up---------------------------------------
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
            puts ("Invalid password").colorize(:red)
            puts "Please check your password"
        else
            puts "Successful login"
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
    user_choice_feature = feature_menu
    case user_choice_feature
    when "View my current build"
        create_user_data_table(this_user)
    when "Start a new build"
        reset_build(users, this_user)
    when "Search for parts by name"
        user_choice_part, user_choice_category, is_table_created = search_and_display_parts(this_user)
        if is_table_created
            build_updated = to_update_build?(user_choice_category, user_choice_part, this_user)
        end
    when "Filter and sort parts"
        user_choice_part, user_choice_category = sort_and_display_parts(this_user)
        build_updated = to_update_build?(user_choice_category, user_choice_part, this_user)
    when "Get a build recommendation"
        puts "d"
    when "Log out"
        write_to_csv(users)
        is_signed_in = false
        colorizer.write "Thank you for using GBM Helper"
    end
end