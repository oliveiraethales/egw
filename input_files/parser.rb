require 'mongoid'
require 'json'
require_relative '../app/models/subject'
require_relative '../app/models/item'

class EgwParser
  def initialize
    Mongoid.load!('config/mongoid.yml')
  end

  def parse
    start = Time.now

    puts 'Starting...'

    main_file = File.read(File.expand_path('../main.txt', __FILE__))

    insert_into_db(main_file)

    finish = Time.now

    puts "Finished! Elapsed time: #{finish - start}"
  end

  def insert_into_db(text_file)
    puts 'Cleaning DB'

    start = Time.now

    Subject.destroy_all

    finish = Time.now

    puts "Took: #{finish - start}"

    previous_line = ''
    line_count = 0
    current_subject = nil
    current_subject_items = []
    previous_line_was_letter = false
    previous_line_was_subject = false
    previous_line_was_item = false
    previous_line_was_supplement = false
    subject_start = nil
    subject_finish = nil

    puts 'Processing input lines'

    text_file.each_line do |line|
      puts "#{Time.now.strftime('%H:%M:%S')}: Processed #{line_count} line(s)" if (line_count % 10) == 0

      line_count += 1
      line = line.strip

      if line.length == 1
        previous_line_was_letter = true
        previous_line_was_subject = false
        previous_line_was_item = false
        previous_line_was_supplement = false

        if line != 'A'
          finish = Time.now

          puts "Letter processing took: #{finish - start}"
        end

        puts "Started processing for letter: #{line}"

        start = Time.now

        next
      end

      if previous_line_was_letter
        if current_subject
          subject_finish = Time.now

          puts "Saving #{current_subject_items.count} items in Subject #{current_subject.name}"
          subject_items_save_start = Time.now

          current_subject.items = current_subject_items
          current_subject.save

          subject_items_save_end = Time.now

          puts "Saved! Took #{subject_items_save_end - subject_items_save_start}"

          current_subject_items = []
        end

        # it IS a subject
        current_subject = Subject.create!(name: line)

        puts "Subject change! Started processing for Subject: #{current_subject.name}"

        subject_start = Time.now

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
