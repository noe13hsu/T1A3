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

def to_update_build?(user_choice_category, user_choice_part, this_user)
    answer = yes_or_no
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