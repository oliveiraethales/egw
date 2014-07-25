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
    origin_text_db = File.read(File.expand_path('../ellen_white.txt', __FILE__))

    insert_into_db(origin_text_db)
    
    finish = Time.now

    puts "Finished! Elapsed time: #{diff}"
  end

  def insert_into_db(text_file)
    previous_line = ''
    spaces = 0
    previous_spaces = 0
    current_subject = nil
    current_subject_items = []
    previous_line_was_letter = false
    previous_line_was_subject = false
    previous_line_was_item = false
    previous_line_was_supplement = false

    text_file.each_line do |line|
      if line.strip.length == 1
        previous_line_was_letter = true
        previous_line_was_subject = false
        previous_line_was_item = false
        previous_line_was_supplement = false

        puts "Letter: #{line}"

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
        end
      end

      if previous_line_was_supplement
        # it IS an item
        current_subject_items << Item.create!(text: line, subject: current_subject)
        
        previous_line_was_supplement = false
        previous_line_was_item = true
        previous_line_was_subject = false
        previous_line_was_letter = false
      end
    end
  end
end

Egw.new.parse
