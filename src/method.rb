def append_to_user_csv(username, password, head=nil, body=nil, arm=nil, leg=nil, back=nil, weapon_melee=nil, weapon_ranged=nil, shield=nil, pilot=nil)
    CSV.open("user.csv", "a") do |row|
        row << [username, password, head, body, arm, leg, back, weapon_melee, weapon_ranged, shield, pilot]
    end
end

def write_to_csv(users)
    headers = users.first.headers || ["username", "password", "head", "body", "arm", "leg", "back", "weapon_melee", "weapon_ranged", "shield", "pilot"]
    CSV.open("user.csv", "w") do |csv|
        csv << headers
        users.each do |user|
            csv << user
        end
    end
end

def load_data(filename)
    data = []
    CSV.foreach("#{filename}.csv", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        data << row
    end
    return data
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

def get_build_type(user_stats)
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

def get_pilot_job(this_user)
    CSV.foreach("pilot.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:name] == this_user[:pilot]
            return row[:job_1], row[:job_2]
        end
    end
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

def reset_build(users, this_user)
    users.each do |user|
        if user[:username] == this_user[:username]
            i = 2
            while i < user.length do
                user[i] = "-"
                i += 1
            end
        end
    end
end

def to_update_build?(user_selection_category, user_selection_part, this_user)
    answer = yes_or_no
    case answer
    when "Yes"
        this_user[:"#{user_selection_category}"] = user_selection_part
        puts "Build updated".colorize(:blue)
    when "No"
        puts "Build not updated".colorize(:red)
    end
end

def get_active_word_tags(word_tags)
    active_word_tags = []
    word_tag_counts = Hash.new(0)
    word_tags.each { |word_tag| word_tag_counts[word_tag] += 1 }
    word_tag_counts.each do |key, value|
        if value >= 5
            active_word_tags.push(key)
        end
    end
    case active_word_tags.length
    when 0
        return "-", "-", "-"
    when 1
        return active_word_tags[0], "-", "-"
    when 2
        return active_word_tags[0], active_word_tags[1], "-"
    when 3
        return active_word_tags[0], active_word_tags[1], active_word_tags[2]
    end
end

def display_recommendation_by_type_table(user_selection_type, user_selection_attr)
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
            ["Type",            user_selection_type                       ],
            ["---------------", "----------------------------------------"],
            ["Head",            parts_with_highest_param[:head]           ],
            ["Body",            parts_with_highest_param[:body]           ], 
            ["Arm",             parts_with_highest_param[:arm]            ], 
            ["Leg",             parts_with_highest_param[:leg]            ], 
            ["Back",            parts_with_highest_param[:back]           ], 
            ["Melee Weapon",    parts_with_highest_param[:weapon_melee]   ], 
            ["Ranged Weapon",   parts_with_highest_param[:weapon_ranged]  ], 
            ["Shield",          parts_with_highest_param[:shield]         ],
            ["Pilot",           parts_with_highest_param[:pilot]          ]
        ]
    )
    puts parts_names.render(:unicode, multiline: true, alignments: [:left, :center], column_widths: [15, 40])
    # p parts_with_highest_param
end

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

def load_parts(user_selection_category, user_selection_weapon)
    all_parts = []
    case user_selection_category
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            all_parts << row
        end
        return all_parts
    when "weapon_melee", "weapon_ranged"
        CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            if row[:category] == user_selection_weapon
                all_parts << row
            end
        end
        return all_parts
    end
end

def sort_and_display_parts(this_user)
    filter_result = []
    user_selection_category = category_menu.downcase #weapon_ranged
    user_selection_weapon =  weapon_category_menu(user_selection_category) #rifle
    filter_result = load_parts(user_selection_category, user_selection_weapon) # array of all rifles
    user_selection_attr = attribute_menu #shot atk
    filter_result.sort! { |part1, part2| part2[user_selection_attr].to_i <=> part1[user_selection_attr].to_i } #sort all rifles by highest shot atk
    user_selection_part = sorted_parts_menu(user_selection_category, filter_result, 3)
    display_parts_data_table(user_selection_category, user_selection_part, this_user) #(weapon_ranged, rifle name, this_user)
    return user_selection_part, user_selection_category
end

def search_and_display_parts(this_user)
    search_result = []
    search_count = 0
    search_limit = 5
    out_of_search = false
    user_selection_category = category_menu.downcase #melee weapon
    while search_result.length == 0 and !out_of_search
        if search_count < search_limit
            user_selection_part = request_part_name("Please enter a Gundam name: ")
            CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
                headers ||= row.headers
                if row[:name] == user_selection_part
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
        return user_selection_part, user_selection_category, false
    end
    prompt = TTY::Prompt.new(active_color: :blue)
    case user_selection_category
    when "weapon_melee", "weapon_ranged"
        user_selection_part = prompt.select("Please select a part") do |menu|
        search_result.each do |part|
            menu.choice part[:weapon_name]
        end
    end
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        user_selection_part = prompt.select("Please select a part") do |menu|
            search_result.each do |part|
                menu.choice part[:name]
            end
        end
    end
    is_table_created = display_parts_data_table(user_selection_category, user_selection_part, this_user)
    return user_selection_part, user_selection_category, is_table_created
end

def part_in_use(user_selection_category, this_user)
    case user_selection_category
    when "weapon_melee", "weapon_ranged"
    CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:weapon_name] == this_user[:"#{user_selection_category}"]
            return row
        end
    end
    return "-"
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:name] == this_user[:"#{user_selection_category}"]
                return row
            end
        end
    return "-"
    end
end

def create_parts_data_table(user_selection_category, user_selection_part, part_in_use, attr)
    CSV.foreach("#{user_selection_category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[attr] == user_selection_part
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

def display_parts_data_table(user_selection_category, user_selection_part, this_user)
    part_in_use = part_in_use(user_selection_category, this_user)
    case user_selection_category
    when "head", "body", "arm", "leg", "back", "pilot", "shield"
        is_table_created = create_parts_data_table(user_selection_category, user_selection_part, part_in_use, :name)
        return is_table_created
    when "weapon_melee", "weapon_ranged"
        is_table_created = create_parts_data_table(user_selection_category, user_selection_part, part_in_use, :weapon_name)
        return is_table_created
    end  
end