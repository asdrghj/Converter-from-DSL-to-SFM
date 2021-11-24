require_relative 'Parser.rb'

def main
    if File.exist?("config.txt")
        file = File.open("config.txt")
        file_name = file.readline.strip
    else
        file_name = "text_to_convert.txt"
    end

    p = Parser.new
    output_mass = p.convert(file_name)
    file = File.open("converted_file.txt", 'w')
    output_mass.each do |line|
        file.puts(line)
    end
    file.close

    gets
end

main
