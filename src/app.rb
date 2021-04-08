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
                case row[:type]
                when "S"
                    user_stats[:type][:S] += 1
                when "P"
                    user_stats[:type][:P] += 1
                when "T"
                    user_stats[:type][:T] += 1
                end
                user_stats[:word_tags].push(row[:word_tag_1])
                user_stats[:word_tags].push(row[:word_tag_2])
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
        type: {S: 0, P: 0, T: 0},
        word_tags: []
    }
    sum_stats_non_weapon = sum_stats(non_weapon_categories, user_stats, this_user, :name)
    sum_stats_all_parts = sum_stats(weapon_categories, sum_stats_non_weapon, this_user, :weapon_name)
    return sum_stats_all_parts
end

def create_user_data_table(this_user)
    user_stats = user_build_stats(this_user)
    # p this_user
    # get_pilot_job(this_user)
    pilot_job_1, pilot_job_2 = get_pilot_job(this_user)
    word_tag_1, word_tag_2, word_tag_3 = get_active_word_tags(user_stats[:word_tags])
    current_build = TTY::Table.new(
        [   "Part",             "Name",                      "  ",   "Type",       get_build_type(user_stats)],
        [
            ["Head",            this_user[:head],            "  ",   "Armor",      user_stats[:armor]], 
            ["Body",            this_user[:body],            "  ",   "Melee ATK",  user_stats[:melee_atk]], 
            ["Arm",             this_user[:arm],             "  ",   "Shot ATK",   user_stats[:shot_atk]], 
            ["Leg",             this_user[:leg],             "  ",   "Melee DEF",  user_stats[:melee_def]], 
            ["Back",            this_user[:back],            "  ",   "Shot DEF",   user_stats[:shot_def]], 
            ["Melee Weapon",    this_user[:weapon_melee],    "  ",   "Beam RES",   user_stats[:beam_res]], 
            ["Ranged Weapon",   this_user[:weapon_ranged],   "  ",   "Phys RES",   user_stats[:phys_res]], 
            ["Shield",          this_user[:shield],          "  ",   "", ""], 
            ["Pilot",           this_user[:pilot],           "  ",   "Active Word Tag 1", word_tag_1],
            ["Job License 1",   pilot_job_1,                 "  ",   "Active Word Tag 2", word_tag_2],
            ["Job License 2",   pilot_job_2,                 "  ",   "Active Word Tag 3", word_tag_3]
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
    user_choice_category = category_menu.downcase #weapon_ranged
    user_choice_weapon =  weapon_category_menu(user_choice_category) #rifle
    filter_result = load_parts(user_choice_category, user_choice_weapon) # array of all rifles
    user_choice_attr = attribute_menu #shot atk
    filter_result.sort! { |part1, part2| part2[user_choice_attr].to_i <=> part1[user_choice_attr].to_i } #sort all rifles by highest shot atk
    user_choice_part = sorted_parts_menu(user_choice_category, filter_result)
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

def recommend_and_display_parts
    user_selection = recommendation_menu
    case user_selection
    when "Type"
        user_selection_type = type_menu #S
        user_selection_attr = attribute_menu #:armor
        display_recommendation_table(user_selection_type, user_selection_attr)
    when "Pilot"
        user_selection = pilot_menu
    when "Word Tag"
        user_selection = word_tag_menu
    end
end


def display_recommendation_table(user_selection_type, user_selection_attr)
    categories = ["head", "body", "arm", "leg", "back", "shield", "pilot", "weapon_melee", "weapon_ranged"]
    parts_with_highest_param = {
        head: "",
        body: "",
        arm: "",
        leg: "",
        back: "",
        shield: "",
        pilot: "",
        weapon_melee: "",
        weapon_ranged: ""
    }
    i = 0
    while i < categories.length
        parts_with_selected_type = []
        CSV.foreach("#{categories[i]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:type] ==  user_selection_type
                parts_with_selected_type.push(row)
            end
        end
        parts_with_selected_type.sort! { |part1, part2| part2[user_selection_attr].to_i <=> part1[user_selection_attr].to_i }
        part_with_highest_param = parts_with_selected_type.take(1)
        parts_with_highest_param[:"#{categories[i]}"] = part_with_highest_param[0][:name]
        i += 1
    end
    parts_names = TTY::Table.new(
        [
            ["Type",            user_selection_type                      ],
            ["---------------", "---------------------------------------"],
            ["Head",            parts_with_highest_param[:head]          ],
            ["Body",            parts_with_highest_param[:body]          ], 
            ["Arm",             parts_with_highest_param[:arm]           ], 
            ["Leg",             parts_with_highest_param[:leg]           ], 
            ["Back",            parts_with_highest_param[:back]          ], 
            ["Melee Weapon",    parts_with_highest_param[:weapon_melee]  ], 
            ["Ranged Weapon",   parts_with_highest_param[:weapon_ranged] ], 
            ["Shield",          parts_with_highest_param[:shield]        ],
            ["Pilot",           parts_with_highest_param[:pilot]         ]
        ]
    )
    puts parts_names.render(:unicode, multiline: true, alignments: [:left, :center], column_widths: [15, 40])
    # p parts_with_highest_param
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
    users = load_data("user")
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
            puts "Please check your password".colorize(:red)
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
        recommend_and_display_parts
    when "Log out"
        write_to_csv(users)
        is_signed_in = false
        colorizer.write "Thank you for using GBM Helper"
    end
end