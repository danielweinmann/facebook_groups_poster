@file_name = File.expand_path('../', __FILE__) + "/final.csv"
@lines = []
File.open(@file_name, "r") do |file|
  file.each_line do |line|
    @lines << line
  end
end
@lines.sort!
@lines.uniq!
File.open(@file_name, "w+") do |file|
  @lines.each { |line| file.puts(line) }
end
