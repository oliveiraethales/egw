require 'nokogiri'

class Egw
  def initialize
    @html_builder = Nokogiri::HTML::Builder.new
  end

  def self.parse
    current_dir = File.dirname(__FILE__)
    origin_text = File.read(File.expand_path('../ellen white comprehensive topical index.txt', __FILE__))
    
    subjects_txt = File.new(File.join(current_dir, 'egw_subjects.txt'), 'w+')

    parsed_stuff = parse_lines(origin_text)

    parsed_stuff[:subjects].collect(&:strip).each {|s|
      next if s.empty? || s.length == 1
      subjects_txt.puts s
    }

    dest_txt = File.open(File.join(current_dir, 'ellen_white.txt'), 'w+') do |f|
      f.puts parsed_stuff[:lines]
    end
  end

  def self.parse_lines(text_file)
    previous_line = ''
    supplement_mode = false
    subjects = []
    lines_to_write = []

    text_file.each_line do |line|
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

      if line == previous_line
        next
      end

      if line =~ /\d/ || line.include?('See') || line.include?('Supplement')
        spaces_to_add += 2
      end

      spaces_to_add += 2 if (line.strip[-1, 1] == ',')

      new_line = add_spaces_to_line(new_line, spaces_to_add)

      lines_to_write << new_line unless new_line.strip.empty?

      if line == new_line
        subject = line.strip

        if subject != nil && !subjects.include?(subject) && (line[0].upcase == line[0])
          subjects << subject
        end
      end

      previous_line = line
    end

    { subjects: subject, lines: lines_to_write }
  end

  def self.add_spaces_to_line(line, spaces)
    spcs = ' ' * spaces
    line = "#{spcs}#{line}"
    line
  end

  def write_html_file(text)
    @html_builder do |doc|
      doc.html {
        doc.body {
          doc.text text
        }
      }
    end
  end
end

Egw.parse