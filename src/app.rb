def append_to_user_csv(username, password, build={head: "", body: "", arm: "", leg: "", back: "", weapon_melee: "", weapon_ranged: "", shield: "", pilot: ""})
    CSV.open("user.csv", "a") do |csv|
        csv << [username, password, build]
    end
end    

puts "Welcome to GBM Helper"

print "Please enter an username: "
username = gets.chomp.downcase
print "Please enter a password: "
password = gets.chomp.downcase
append_to_user_csv(username, password)