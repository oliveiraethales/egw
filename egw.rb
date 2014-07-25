require 'mongoid'
require_relative 'app/models/subject'
require_relative 'app/models/item'

class Egw
  def initialize
    Mongoid.load!('config/mongoid.yml')
  end

  def parse
    start = Time.now
    puts "Starting..."

    current_dir = File.dirname(__FILE__)
    origin_text = File.read(File.expand_path('../ellen white comprehensive topical index.txt', __FILE__))

    insert_into_db(origin_text)
    # parsed_stuff = parse_lines(origin_text)

    # subjects_txt = File.new(File.join(current_dir, 'egw_subjects.txt'), 'w+')

    # parsed_stuff[:subjects].collect(&:strip).each {|s|
    #   next if s.empty? || s.length == 1
    #   subjects_txt.puts s
    # }

    # File.open(File.join(current_dir, 'ellen_white.txt'), 'w+') do |f|
    #   f.puts parsed_stuff[:lines]
    # end

    # File.open(File.join(current_dir, 'egw_pre_html.txt'), 'w+') do |f|
    #   f.puts parsed_stuff[:html_lines]
    # end

    # finish = Time.now
    # diff = finish - start

    # letters = parsed_stuff[:letters]
    # html_letters = parsed_stuff[:html_letters]

    # letters.each {|k,v| 
    #   File.open(File.join(current_dir, "letters/#{k}.txt"), 'w+') do |f|
    #     f.puts v
    #   end
    # }

    puts "Finished! Elapsed time: #{diff}"
  end

  def parse_lines(text_file)
    all_letters = Hash.new
    current_letter = ''
    previous_line = ''
    previous_spaces = 0
    supplement_mode = false
    subjects = []
    lines_to_write = []

    text_file.each_line do |line|
      new_line = line

      if new_line.strip.length == 1
        # new letter started
        current_letter = new_line.strip
        all_letters[current_letter] = []
      end

      spaces_to_add = 0

      if !supplement_mode
        supplement_mode = previous_line.include? 'Supplement'
      end

      if supplement_mode && line =~ /\d/
        spaces_to_add += 2
      else
        supplement_mode = false
      end

      if line == previous_line
        next
      end

      if line =~ /\d/ || line.include?('See') || line.include?('Supplement')
        spaces_to_add += 2
      end

      spaces_to_add += 2 if (line.strip[-1, 1] == ',')

      new_line = add_spaces_to_line(new_line, spaces_to_add)

      lines_to_write << new_line unless new_line.strip.empty?

      all_letters[current_letter] << new_line.strip unless new_line.strip.empty?

      if line == new_line
        subject = line.strip

        if subject != nil && !subjects.include?(subject) && (line[0].upcase == line[0])
          subjects << subject
        end
      end

      previous_line = line
      previous_spaces = spaces_to_add
    end

    { subjects: subjects, lines: lines_to_write, letters: all_letters }
  end

  def add_spaces_to_line(line, spaces)
    spcs = ' ' * spaces
    line = "#{spcs}#{line}"
    line
  end

  def insert_into_db(text_file)
    previous_line = ''
    previous_spaces = 0
    supplement_mode = false
    last_subject = nil

    text_file.each_line do |line|
      next if line.strip.blank? # it's a letter

      new_line = line

      spaces_to_add = 0

      if !supplement_mode
        supplement_mode = previous_line.include? 'Supplement'
      end

      if supplement_mode && line =~ /\d/
        spaces_to_add += 2
      else
        supplement_mode = false
      end

      if line =~ /\d/ || line.include?('See') || line.include?('Supplement')
        spaces_to_add += 2
      end

      spaces_to_add += 2 if (line.strip[-1, 1] == ',')

      if spaces_to_add == 2
        # it is a subject

        if last_subject
          Subject.create!(name: line, subject: last_subject)
        else
          Subject.create!(name: line)
        end
      end

      if spaces_to_add == 4 && previous_spaces == 2
        # it is an item
        Item.create!(text: line, subject: last_subject)
      end

      if spaces_to_add == 6

      end

      previous_line = line
      previous_spaces = spaces_to_add
    end
  end
end

Egw.new.parse
