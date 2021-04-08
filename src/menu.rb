def title_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    prompt.select("What would you like to do?") do |menu|
        menu.choice "Sign up"
        menu.choice "Log in"
        menu.choice "Quit"
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

def sorted_parts_menu(user_choice_category, filter_result)
    prompt = TTY::Prompt.new(active_color: :blue)
    case user_choice_category
    when "weapon_melee", "weapon_ranged"
        user_choice_part = prompt.select("Please select a part") do |menu| #user_choice_part = rifle name
            filter_result.first(5).each do |part|
                menu.choice part[:weapon_name] #display top 5 rifles 
            end
        end
        return user_choice_part
    when "head", "body", "arm", "leg", "back", "shield", "pilot"
        user_choice_part = prompt.select("Please select a part") do |menu| #user_choice_part = rifle name
            filter_result.first(5).each do |part|
                menu.choice part[:name] #display top 5 rifles 
            end
        end
        return user_choice_part
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

def yes_or_no
    prompt = TTY::Prompt.new(active_color: :blue)
    answer = prompt.select("Would you like to update your build?") do |menu|
        menu.choice "Yes"
        menu.choice "No"
    end
    return answer
end

def recommendation_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    user_selection = prompt.select("Please select one of the followings") do |menu|
        menu.choice "Type"
        menu.choice "Pilot"
        menu.choice "Word Tag"
    end
    return user_selection
end

def type_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    user_selection = prompt.select("Please select a type") do |menu|
        menu.choice "S"
        menu.choice "P"
        menu.choice "T"
    end
    return user_selection
end

def word_tag_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    user_selection = prompt.select("Please select a word tag", per_page: 8) do |menu|
        menu.choice "Protag."
        menu.choice "Mobile Fighter"
        menu.choice "High Firepower"
        menu.choice "High Mobility"
        menu.choice "Ace Excl."
        menu.choice "Gundam Type"
        menu.choice "Long-Range"
        menu.choice "Mid-Range"
    end
    return user_selection
end

def pilot_menu
    prompt = TTY::Prompt.new(active_color: :blue)
    user_selection = prompt.select("Please select a word tag") do |menu|
        menu.choice "Defender"
        menu.choice "In-Fighter"
        menu.choice "Out-Fighter"
        menu.choice "Middle-Shooter"
        menu.choice "Long-Shooter"
        menu.choice "Supporter"
    end
    return user_selection
end

