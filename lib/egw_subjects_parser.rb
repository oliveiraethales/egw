require 'fileutils'

module EGWSubjectsParser
  def self.process_files
    base_dir = "#{ENV['HOME']}/egw-files/letters"
    base_done_dir = "#{ENV['HOME']}/egw-files/done"

    Dir.chdir(base_dir)

    letter_dirs = Dir.glob("**")

    puts "letter dirs: #{letter_dirs}"

    letter_dirs.each {|ld|
    	all_file = File.new(File.join(base_dir, ld, 'All.txt'), 'r')
    	
    	if File.exist?(File.join(base_done_dir, "#{ld}.txt"))
        puts "nothing to do for letter #{ld}. already processed"
        next
      end

    	puts "processing #{all_file.path}"

      output_file = File.new(File.join(base_done_dir, "#{ld}.txt"), 'a+')
      subjects = Array.new

      subjects = all_file.readlines.select { |line| !(line =~ /\d/) && line[0] == ld.upcase }

      output_file.puts subjects

      puts "finished processing"
    }

    puts "finished all"
  end
end