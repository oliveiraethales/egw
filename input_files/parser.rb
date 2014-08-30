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

    clean_database

    insert_into_db(main_file)

    finish = Time.now

    puts "Finished! Elapsed time: #{(finish - start).round/60} minutes"
  end

  def insert_into_db(text_file)
    line_count = 0
    @current_subject = nil
    @previous_line_was_letter = false
    @previous_line_was_subject = false
    @previous_line_was_item = false
    @previous_line_was_supplement = false
    @current_letter = ''
    @subject_finish = nil
    @letter_start = nil
    @subject_start = nil

    puts 'Processing input lines'

    text_file.each_line do |line|
      line_count += 1
      line = line.strip

      next if line.blank?

      if line.length == 1
        # it IS a letter
        change_letter line
      elsif line[0].upcase != @current_letter
        # first character is differente than the current letter, it IS an item
        add_item_to_subject line
      elsif line[-1, 1] == ','
        # last character is a comma, it IS an item
        add_item_to_subject line
      elsif /[[:lower:]]/.match line[0]
        # first character is lower case, it IS an item
        add_item_to_subject line
      elsif @previous_line_was_letter
        # it IS a subject
        change_subject line
      elsif @previous_line_was_subject
        # it IS an item
        add_item_to_subject line
      elsif @previous_line_was_item
        # it can be subject, item or supplement
        if line == 'Supplement'
          set_line_as_supplement

          add_item_to_subject line
          next
        end

        if line =~ /\d/
          # contains a number, it PROBABLY is an item
          add_item_to_subject line
        else
          change_subject line
        end
      elsif @previous_line_was_supplement
        # it IS an item
        add_item_to_subject line
      else
        change_subject line
      end
    end
  end

  def set_line_as_supplement
    @previous_line_was_supplement = true
    @previous_line_was_item = false
    @previous_line_was_subject = false
    @previous_line_was_letter = false
  end

  def add_item_to_subject(line)
    @current_subject.items << Item.new(text: line)

    @previous_line_was_item = true
    @previous_line_was_subject = false
    @previous_line_was_letter = false
    @previous_line_was_supplement = false
  end

  def change_subject(line)
    @current_subject = Subject.create!(name: line, letter: @current_letter)

    # puts "Subject change! Started processing for Subject: #{@current_subject.name}"

    @previous_line_was_item = false
    @previous_line_was_subject = true
    @previous_line_was_letter = false
    @previous_line_was_supplement = false

    @subject_start = Time.now
  end

  def change_letter(line)
    unless @current_letter.blank?
      @letter_finish = Time.now
      time = (@letter_finish - @letter_start).round

      if time < 61
        puts "Letter processing took: #{time} seconds"
      else
        puts "Letter processing took: #{time/60} minutes"
      end
    end

    puts "Started processing for letter: #{line}"

    @current_letter = line
    @previous_line_was_letter = true
    @previous_line_was_subject = false
    @previous_line_was_item = false
    @previous_line_was_supplement = false

    @letter_start = Time.now
  end

  def clean_database
    puts 'Cleaning DB'

    start = Time.now

    session = Moped::Session.new(["127.0.0.1:27017"])
    session.use :egw

    session.drop

    finish = Time.now

    puts "Clean complete (#{finish - start} seconds)"
  end
end

EgwParser.new.parse
