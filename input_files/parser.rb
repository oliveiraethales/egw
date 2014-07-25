require 'mongoid'
require 'json'
# require_relative 'app/models/subject'
# require_relative 'app/models/item'

class EgwParser
  def initialize
    # Mongoid.load!('config/mongoid.yml')
  end

  def parse
    start = Time.now

    puts 'Starting...'

    current_dir = File.dirname(__FILE__)
    main_file = File.read(File.expand_path('../main.txt', __FILE__))

    # insert_into_db(origin_text_db)
    create_json(main_file)

    finish = Time.now

    puts "Finished! Elapsed time: #{finish - start}"
  end

  def create_json(input_file)
    spaces = 0
    previous_spaces = 0
    current_subject = {}
    current_subject_items = []
    previous_line_was_letter = false
    previous_line_was_subject = false
    previous_line_was_item = false
    previous_line_was_supplement = false
    json_file = File.open(File.join(Dir.pwd, 'main.json'), 'w+')
    # line_count = 0

    puts 'Processing input lines'

    input_file.each_line { |line|
      # line_count += 1

      # break if line_count > 50

      line = line.strip

      if line.length == 1
        puts "Letter '#{line}' found"

        previous_line_was_letter = true
        previous_line_was_subject = false
        previous_line_was_item = false
        previous_line_was_supplement = false

        break if line != 'A'

        puts "Started processing for letter: #{line}"

        next
      end

      if previous_line_was_letter
        if current_subject[:name]
          current_subject[:items] = current_subject_items
          json_file.write current_subject.to_json

          current_subject = {}
          current_subject[:name] = line

          current_subject_items = []
        end

        # it IS a subject
        current_subject[:name] = line

        previous_line_was_item = false
        previous_line_was_subject = true
        previous_line_was_letter = false
        previous_line_was_supplement = false

        next
      end

      if previous_line_was_subject
        # it IS an item
        current_subject_items << { text: line }

        previous_line_was_item = true
        previous_line_was_subject = false
        previous_line_was_letter = false
        previous_line_was_supplement = false

        next
      end

      if previous_line_was_item
        # it can be subject or item
        if line == 'Supplement'
          previous_line_was_supplement = true
          previous_line_was_item = false
          previous_line_was_subject = false
          previous_line_was_letter = false

          next
        end

        if line =~ /\d/
          # contains a number, it PROBABLY is an item
          current_subject_items << { text: line }

          previous_line_was_item = true
          previous_line_was_subject = false
          previous_line_was_letter = false
          previous_line_was_supplement = false

          next
        else
          current_subject[:items] = current_subject_items
          json_file.puts current_subject.to_json

          current_subject = {}
          current_subject[:name] = line

          previous_line_was_item = false
          previous_line_was_subject = true
          previous_line_was_letter = false
          previous_line_was_supplement = false

          next
        end
      end

      if previous_line_was_supplement
        # it IS an item
        current_subject_items << { text: line }

        previous_line_was_supplement = false
        previous_line_was_item = true
        previous_line_was_subject = false
        previous_line_was_letter = false

        next
      end
    }

    json_file.close
  end

  def insert_into_db(text_file)
    puts 'Cleaning DB'

    Subject.destroy_all

    previous_line = ''
    spaces = 0
    previous_spaces = 0
    current_subject = nil
    current_subject_items = []
    previous_line_was_letter = false
    previous_line_was_subject = false
    previous_line_was_item = false
    previous_line_was_supplement = false

    puts 'Processing input lines'

    text_file.each_line do |line|
      line = line.strip

      if line.length == 1
        previous_line_was_letter = true
        previous_line_was_subject = false
        previous_line_was_item = false
        previous_line_was_supplement = false

        break if line != 'A'

        puts "Started processing for letter: #{line}"

        next
      end

      if previous_line_was_letter
        if current_subject
          current_subject.items = current_subject_items
          current_subject.save

          current_subject_items = []
        end

        # it IS a subject
        current_subject = Subject.create!(name: line)

        previous_line_was_item = false
        previous_line_was_subject = true
        previous_line_was_letter = false
        previous_line_was_supplement = false

        next
      end

      if previous_line_was_subject
        # it IS an item
        current_subject_items << Item.create!(text: line, subject: current_subject)

        previous_line_was_item = true
        previous_line_was_subject = false
        previous_line_was_letter = false
        previous_line_was_supplement = false

        next
      end

      if previous_line_was_item
        # it can be subject or item
        if line == 'Supplement'
          previous_line_was_supplement = true
          previous_line_was_item = false
          previous_line_was_subject = false
          previous_line_was_letter = false

          next
        end

        if line =~ /\d/
          # contains a number, it PROBABLY is an item
          current_subject_items << Item.create!(text: line, subject: current_subject)

          previous_line_was_item = true
          previous_line_was_subject = false
          previous_line_was_letter = false
          previous_line_was_supplement = false

          next
        else
          current_subject.items = current_subject_items
          current_subject.save

          current_subject = Subject.create!(name: line)

          previous_line_was_item = false
          previous_line_was_subject = true
          previous_line_was_letter = false
          previous_line_was_supplement = false

          next
        end
      end

      if previous_line_was_supplement
        # it IS an item
        current_subject_items << Item.create!(text: line, subject: current_subject)

        previous_line_was_supplement = false
        previous_line_was_item = true
        previous_line_was_subject = false
        previous_line_was_letter = false

        next
      end
    end
  end
end

EgwParser.new.parse