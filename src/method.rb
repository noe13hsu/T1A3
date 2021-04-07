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

def category_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    prompt.select("Please select a category", per_page: 9) do |menu|
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
    user_selection = prompt.select("Please select an attribute", per_page: 7) do |menu|
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

def load_data(filename)
    data = []
    CSV.foreach("#{filename}.csv", headers: true, header_converters: :symbol) do |row|
        headers ||= row.headers
        data << row
    end
    return data
end

def weapon_category_menu(user_choice_category)
    prompt = TTY::Prompt.new(active_color: :blue)
    case user_choice_category
    when "weapon_ranged"
        prompt.select("Please select a weapon category", per_page: 6) do |menu|
            menu.choice "Bazooka"
            menu.choice "Gatling Gun"
            menu.choice "Long Rifle"
            menu.choice "Machine Gun"
            menu.choice "Rifle"
            menu.choice "Twin Rifle"
        end
    when "weapon_melee"
        prompt.select("Please select a weapon category", per_page: 8) do |menu|
            menu.choice "Axe"
            menu.choice "Blade"
            menu.choice "Dual Saber"
            menu.choice "Lance"
            menu.choice "Saber"
            menu.choice "Twin Blade"
            menu.choice "Whip"
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
