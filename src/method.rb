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

def username_registered?(users, username)
    users.each do |user|
        if user[:username] == username
            return true
        end
    end
    return false
end

def username_validation(users, username)
    required_format = /\A\p{Alnum}*\p{L}\p{Alnum}*\z/
    required_length = 6
    is_username_registered = username_registered?(users, username)
    if username.chars.length >= required_length and username.match?(required_format) == true and is_username_registered == false
        return true
    else
        return false
    end  
end

def password_validation(password)
    required_length = 6
    if password.chars.length >= required_length
        return true
    else
        return false
    end
end

def log_in(this_user, is_signed_in)
    password = ""
    input_count = 0
    input_limit = 3
    out_of_input = false
    while password != this_user[:password] and !out_of_input
        if input_count == 0 
            password = request_input("Please enter your password: ")
            input_count += 1
        elsif input_count > 0 and input_count < input_limit
            puts ("Invalid password").colorize(:red)
            password = request_input("Please enter your password: ")
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
    return is_signed_in
end

def request_input(message)
    print message
    return gets.chomp.downcase
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

def reset_build(this_user)
    i = 2
    while i < this_user.length do
        this_user[i] = "-"
        i += 1
    end
end

def to_update_build?(user_selection, this_user)
    case yes_or_no
    when "Yes"
        this_user[:"#{user_selection[:category]}"] = user_selection[:part]
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

def create_user_data_table(this_user)
    user_stats = user_build_stats(this_user)
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
            ["Pilot",           this_user[:pilot],           "  ",   "Word Tag 1", word_tag_1],
            ["Job License 1",   pilot_job_1,                 "  ",   "Word Tag 2", word_tag_2],
            ["Job License 2",   pilot_job_2,                 "  ",   "Word Tag 3", word_tag_3]
        ]
    )
    puts current_build.render(:unicode, alignments: [:left, :center, :center, :left, :center], column_widths: [15, 25, 2, 15, 25])  
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
    CSV.foreach("./parts/pilot.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:name] == this_user[:pilot]
            return row[:job_1], row[:job_2]
        end
    end
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

def sum_stats(category, user_stats, this_user, ref_attr)
    i = 0
    while i < category.length do
        CSV.foreach("./parts/#{category[i]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
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

def filter_and_sort_by_category(user_selection, this_user)
    filter_result = []
    case user_selection[:category]
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            filter_result.push(row)
        end
    when "weapon_melee", "weapon_ranged"
        CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            headers ||= row.headers
            if row[:category] == user_selection[:weapon_type]
                filter_result.push(row)
            end
        end
    end
    filter_result.delete_if { |part| part[:name] == "-"}
    filter_result.sort! { |part1, part2| part2[user_selection[:attr]].to_i <=> part1[user_selection[:attr]].to_i }
    return filter_result
end

def search_parts(user_selection, this_user)
    search_result = []
    search_count = 0
    search_limit = 5
    out_of_search = false
    while search_result.length == 0 and !out_of_search
        if search_count < search_limit
            print "Please enter a Gundam name: " 
            user_selection[:part] = gets.chomp.downcase.split(/\s+/).each{ |word| word.capitalize! }.join(' ')
            CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
                headers ||= row.headers
                if row[:name] == user_selection[:part]
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
        return user_selection, search_result
    end
    return user_selection, search_result
end

def display_parts_data_table(user_selection, this_user)
    part_in_use = part_in_use(user_selection[:category], this_user)
    case user_selection[:category]
    when "head", "body", "arm", "leg", "back", "pilot", "shield"
        create_parts_data_table(user_selection, part_in_use, :name)
    when "weapon_melee", "weapon_ranged"
        create_parts_data_table(user_selection, part_in_use, :weapon_name)
    end  
end

def create_parts_data_table(user_selection, part_in_use, attr)
    CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[attr] == user_selection[:part]
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
        end
    end
end

def part_in_use(category, this_user)
    case category
    when "weapon_melee", "weapon_ranged"
    CSV.foreach("./parts/#{category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:weapon_name] == this_user[:"#{category}"]
            return row
        end
    end
    return "-"
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        CSV.foreach("./parts/#{category}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:name] == this_user[:"#{category}"]
                return row
            end
        end
    return "-"
    end
end

def get_parts_with_highest_param(user_selection)
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
        filter_result = []
        CSV.foreach("./parts/#{categories[i]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:type] ==  user_selection[:type]
                filter_result.push(row)
            end
        end
        filter_result.delete_if { |part| part[:name] == "-"}
        filter_result.sort! { |part1, part2| part2[user_selection[:attr]].to_i <=> part1[user_selection[:attr]].to_i }
        part_with_highest_param = filter_result.take(1)
        parts_with_highest_param[:"#{categories[i]}"] = part_with_highest_param[0][:name]
        i += 1
    end
    return parts_with_highest_param
end

def display_parts_with_highest_param_table(user_selection, parts_with_highest_param)
    parts_names = TTY::Table.new(
        [
            ["Type",            user_selection[:type]                       ],
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
end

def filter_and_sort_pilots(user_selection)
    filter_result = []
    CSV.foreach("./parts/pilot.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
        if row[:job_1] == user_selection[:job_license] and row[:type] == user_selection[:type]
            filter_result.push(row)
        elsif row[:job_2] == user_selection[:job_license] and row[:type] == user_selection[:type]
            filter_result.push(row)
        end
    end
    filter_result.sort! { |part1, part2| part2[user_selection[:attr]].to_i <=> part1[user_selection[:attr]].to_i }
    return filter_result
end

def filter_and_sort_word_tags(user_selection)
    filter_result = []
    case user_selection[:category]
    when "head", "body", "arm", "leg", "back", "pilot", "shield"
        CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:word_tag_1] ==  user_selection[:word_tag] and row[:type] ==  user_selection[:type]
                filter_result.push(row)
            elsif row[:word_tag_2] ==  user_selection[:word_tag] and row[:type] ==  user_selection[:type]
                filter_result.push(row)
            end
        end
    when "weapon_melee", "weapon_ranged"
        CSV.foreach("./parts/#{user_selection[:category]}.csv", :quote_char => "|", headers: true, header_converters: :symbol) do |row|
            if row[:word_tag_1] ==  user_selection[:word_tag] and row[:type] == user_selection[:type] and row[:category] == user_selection[:weapon_type]
                filter_result.push(row)
            elsif row[:word_tag_2] ==  user_selection[:word_tag] and row[:type] == user_selection[:type] and row[:category] == user_selection[:weapon_type]
                filter_result.push(row)
            end
        end
    end
    filter_result.sort! { |part1, part2| part2[user_selection[:attr]].to_i <=> part1[user_selection[:attr]].to_i }
    return filter_result
end