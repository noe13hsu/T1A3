if ARGV.include? "-help"
    puts "Hello World!"
    puts "If you are playing Gundam Breaker Mobile or Gundam Battle: Gunpla Warefare\nthis GBM Helper can help you imporve your build with features such as:"
    puts "  - search"
    puts "  - filter and sort"
    puts "  - recommendation"
    puts ""
    puts "Command to find out the current version"
    puts "  -v"
    exit
end

if ARGV.include? "-v"
    puts "version 1.1.1"
    exit
end