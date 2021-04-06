require "csv"
require "tty-prompt"
require "tty-table"
require "colorize"
require "ruby_figlet"
require "lolize"
using RubyFiglet
colorizer = Lolize::Colorizer.new

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

def request_part_name(message)
    print message
    return gets.chomp.downcase.split(/\s+/).each{ |word| word.capitalize! }.join(' ')
end

def request_username(message)
    print message
    return gets.chomp.downcase
end

def request_password(message)
    print message
    return gets.chomp.downcase
end

def to_update_build?(user_choice_category, user_choice_part, this_user)
    prompt = TTY::Prompt.new(active_color: :blue)
    answer = prompt.select("Would you like to update your build?") do |menu|
        menu.choice "Yes"
        menu.choice "No"
    end
    case answer
    when "Yes"
        this_user[:"#{user_choice_category}"] = user_choice_part
        puts "Build updated"
        return true
        # puts this_user, user_choice_category, user_choice_part
    when "No"
        puts "Build not updated"
        return false
    end
end

def category_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    prompt.select("Please select a category") do |menu|
        menu.choice "Head"
        menu.choice "Body"
        menu.choice "Arm"
        menu.choice "Leg"
        menu.choice "Back"
        menu.choice "Weapon_Melee"
        menu.choice "Weapon_Ranged"
        menu.choice "Shield"
        menu.choice "Pilot"
    end
end

def feature_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    prompt.select("What would you like to do?") do |menu|
        menu.choice "View my current build"
        menu.choice "Start a new build"
        menu.choice "Search for parts by name"
        menu.choice "Filter and sort parts"
        menu.choice "Get a build recommendation"
        menu.choice "Log out"
    end
end

def attribute_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    user_selection = user_choice_stat = prompt.select("Please select an attribute") do |menu|
        menu.choice "Armor"
        menu.choice "Melee Attack"
        menu.choice "Shot Attack"
        menu.choice "Melee Defence"
        menu.choice "Shot Defence"
        menu.choice "Beam Resistance"
        menu.choice "Phys Resistance"
    end
    case user_selection
        when "Armor"
            return :armor
        when "Melee Attack"
            return :melee_atk
        when "Shot Attack"
            return :shot_atk
        when "Melee Defence"
            return :melee_def
        when "Shot Defence"
            return :shot_def
        when "Beam Resistance"
            return :beam_res
        when "Phys Resistance"
            return :phys_res
    end
end

def title_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Sign up"
        menu.choice "Log in"
        menu.choice "Quit"
    end
end

def sum_stat(this_user)
    categories = ["head", "body", "arm", "leg", "back", "weapon_melee", "weapon_ranged", "shield", "pilot"]
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
    i = 0
    while i < categories.length do
        CSV.foreach("#{categories[i]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:name] == this_user[:"#{categories[i]}"]
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

def user_type(user_stats)
    if user_stats[:type][:S] >= 5
        return "S"
    elsif user_stats[:type][:P] >= 5
        return "P"
    elsif user_stats[:type][:T] >= 5
        return "T"
    else
        return "-"
    end
end

def create_user_data_table(this_user)
    user_stats = sum_stat(this_user)
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

def load_all_users
    all_users = []
    CSV.foreach("user.csv", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        all_users << row
    end
    return all_users
end

def load_parts(category)
    all_parts = []
    CSV.foreach("#{category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        all_parts << row
    end
    return all_parts
end

def search_and_display_parts(this_user)
    user_choice_category = category_menu.downcase
    user_choice_part = request_part_name("Please enter a Gundam name: ")
    is_table_created = create_parts_data_table(user_choice_category, user_choice_part, this_user)
    return user_choice_part, user_choice_category, is_table_created
end

def sort_and_display_parts(this_user)
    prompt = TTY::Prompt.new(active_color: :blue)
    user_choice_category = category_menu.downcase
    selected_category = load_parts(user_choice_category)
    user_choice_stat = attribute_menu
    selected_category.sort! { |part1, part2| part2[user_choice_stat].to_i <=> part1[user_choice_stat].to_i }
    user_choice_part = prompt.select("Please select a part") do |menu|
        selected_category.first(3).each do |part|
            menu.choice part[:name]
        end
    end
    create_parts_data_table(user_choice_category, user_choice_part, this_user)
    return user_choice_part, user_choice_category
end

def part_in_use(user_choice_category, this_user)
    CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:name] == this_user[:"#{user_choice_category}"]
            return row
        end
    end
    return "-"
end

def color_stats(row, part_in_use, attr)
    if row[attr].to_i - part_in_use[attr].to_i > 0
        return row[:"#{attr}"].colorize(:blue)
    elsif row[attr].to_i - part_in_use[attr].to_i < 0
        return row[attr].colorize(:red)
    else
        return row[attr]
    end    
end 

def create_parts_data_table(user_choice_category, user_choice_part, this_user)
    part_in_use = part_in_use(user_choice_category, this_user)

    CSV.foreach("#{user_choice_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:name] == user_choice_part
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
            return row
        end
    end
    puts "Invalid name".colorize(:red)
    return false
end

def reset_build(users, this_user)
    users.each do |user|
        if user[:username] == this_user[:username]
            user[:head] = "-"
            user[:body] = "-"
            user[:arm] = "-"
            user[:leg] = "-"
            user[:back] = "-"
            user[:weapon_melee] = "-"
            user[:weapon_ranged] = "-"
            user[:shield] = "-"
            user[:pilot] = "-"
        end
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

users = load_all_users
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
        write_to_csv(users)
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





