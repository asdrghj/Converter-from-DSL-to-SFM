require_relative 'lib.rb'

class Lexer
    attr_accessor :file_name, :file, :unget_flg, :line, :current_line_number
    
    def initialize(file_name)
        self.file_name = file_name
        self.line = ""
        self.unget_flg = false
        self.current_line_number = 0
        self.open_file(file_name)
    end

    def scan
        line = Marshal.load(Marshal.dump(self.get_line)) # Копирование полученной строки
        # puts "#{line}"
        if line == -1
            result = {tag: "end of file"}
            return result
        
        elsif line.include?("[c sienna]")
            self.parse_hm(line)

        elsif line.include?("[m1][b][c darkblue]")
            self.parse_darkblue(line)
        
        elsif line.include?("[m3]")
            line.gsub!("[m3]", "")
            self.parse_example(line)
        
        elsif line.include?("[p]см.[/p]")
            line.gsub!("[p]см.[/p]", "")
            self.parse_reference(line)
        
        elsif line.strip.index('[b]') == 0 || line.strip.index('◊') == 0 
            result = {tag: "tag b", lx: word_between_tags(line, "[b]", "[/b]")}
            return result

        elsif line.index(" ") == 0
            pos = parse_part_of_speech(line)
            convert_tag_i_to_parens(line)
            if line.strip.empty? && pos
                return pos    
            else
                result = {tag:"g_Rus"}
                if pos
                    result[:pos] = pos[:lx]
                end
                if dscr = parse_description(line)
                    result[:dscr] = dscr
                end
                result[:lx] = line.strip
                return result 

            end

        else
            result = {tag: "lx", lx: line.strip}
            return result
        end
    end

    def parse_hm(line)
        result = {tag: "hm"}
        hm_num = 0
        buf_num = word_between_tags(line, "[c sienna]", "[/c]")
        buf_num.each_char do |i|
            if i == "I"
                hm_num += 1
            end              
        end
        result[:num] = hm_num
        delete_tag!(line, "[c sienna]", "[/c]")
        if pos = parse_part_of_speech(line)
            result[:pos] = pos[:lx]
        end
        if dscr = parse_description(line)
            result[:dscr] = dscr
        end
        convert_tag_i_to_parens(line)
        if !line.strip.empty?
            result[:lx] = line.strip
            line.gsub!(result[:lx], "")
        end
        check_line(line)
        return result
    end

    def parse_part_of_speech(line)
        parse_line = line
        word = word_between_tags(parse_line, '[i]', '[/i]')
        if part_of_speech?(word)
            result = {tag: "part of speech", lx: word}
            line.gsub!("[i]#{word}[/i]",'')
            return result
        end
        while parse_line.include?('[p]')
            word = word_between_tags(parse_line, '[p]', '[/p]')
            if part_of_speech?(word)
                result = {tag: "part of speech", lx: word}
                line.gsub!("[p]#{word}[/p]",'')
                return result
            else
                parse_line = delete_tag(parse_line, '[p]', '[/p]')
            end
        end
        return nil
    end

    def parse_description(line)
        parse_line = line
        dscr = []
        while parse_line.include?('[p]')
            word = word_between_tags(parse_line, '[p]', '[/p]')
            if !part_of_speech?(word)
                dscr << word
                # puts word
                line.gsub!("[p]#{word}[/p]",'')
            else
                parse_line = delete_tag(parse_line, '[p]', '[/p]')
            end
        end
        if !dscr.empty?
            return dscr
        else
            return nil
        end
    end

    def parse_darkblue(line)
        result = {tag: "darkblue"}
        if pos = parse_part_of_speech(line)
            result[:pos] = pos[:lx]
        end
        if dscr = parse_description(line)
            result[:dscr] = dscr
        end
        convert_tag_i_to_parens(line)
        result[:lx] = word_between_tags(line, "[/b]", "[/m]").strip
        delete_tag!(line, "[m1]", "[/c]")
        delete_tag!(line, "[/b]", "[/m]")
        check_line(line)
        return result
    end

    def parse_example(line)
        result = {tag: "example"}
        convert_tag_to_parens(line, "[p]", "[/p]")
        convert_tag_to_parens(line, "[i]", "[/i]")
        result[:ex] = word_between_tags(line, "[b]", "[/b]")
        result[:trslt] = word_between_tags(line, "[/b]", "[/m]")
        delete_tag!(line, "[b]", "[/m]")
        check_line(line)
        return result
    end

    def parse_reference(line)
        result = {tag: "reference"}
        result[:lx] = word_between_tags(line, "<<", ">>").strip
        delete_tag!(line, "<<", ">>")
        check_line(line)
        return result
    end

    def open_file(file_name)
        if File.exist?(file_name)
            self.file = File.open(file_name)
        else
            abort "Файл не найден"
        end
    end

    def close_file
        @file.close
    end
    
    def get_line
        if @unget_flg
            @unget_flg = false
            return @line
        else
            l = file.gets
            if l != nil
                @line.replace(l)
                @current_line_number += 1
                return @line
            else 
                return -1
            end
        end
    end

    def unget_line
        @unget_flg = true
    end

    def convert_tag_i_to_parens (line)
        if line.include?("[i]") &&  line.include?("[/i]")
            if part_of_speech?(word_between_tags(line, "[i]", "[/i]").strip)
                return
            else
                convert_tag_to_parens(line, "[i]", "[/i]")
            end
        end
    end

    def convert_tag_to_parens(line, start_tag, end_tag)
        if line.include?(start_tag) && line.include?(end_tag)
            if line.include?("(") && line.include?(")")
                line.gsub!(start_tag, "")
                line.gsub!(end_tag, "")
            else
                line.gsub!(start_tag, "(")
                line.gsub!(end_tag, ")")
            end
            
        end
    end

    def delete_symbols(line, first_insex, last_index)
        str_1 = ""
        str_2 = ""
        if first_insex < last_index
            if first_insex != 0
                str_1 = line[0..first_insex - 1]
            end
            if last_index <= line.length - 1
                str_2 = line[last_index + 1 ..line.length - 1]
            end
        end
        return str_1 + str_2
    end

    def delete_tag(line, start_tag, end_tag)
        if line != nil && start_tag != nil && end_tag != nil && line.include?(start_tag) && line.include?(end_tag)
            first_index = line.index(start_tag)
            last_index = line.index(end_tag) + end_tag.length - 1
            if block_given?
                yield(line, first_index, last_index) 
            else
                return delete_symbols(line, first_index, last_index)
            end
        end
    end
    
    def delete_tag!(line, start_tag, end_tag)
        delete_tag(line, start_tag, end_tag) do |line, first_index, last_index|
            line.replace(delete_symbols(line, first_index, last_index))
        end
    end

    def parse_tag_p (line)
        if line.include?("[p]") &&  line.include?("[/p]") && line
            tag_content = word_between_tags(line, "[p]", "[/p]").strip
            delete_tag!(line, "[p]", "[/p]")
            return tag_content
        else
            return nil
        end
    end

    def word_between_tags(line, start_tag, end_tag)
        if line != nil && start_tag != nil && end_tag != nil && line.include?(start_tag) && line.include?(end_tag)
            str = line[(line.index(start_tag) + start_tag.length) .. (line.index(end_tag) - 1)]
            return str
        else
            return nil
        end
    end

    def check_line(line)
        if !line.strip.empty?
            puts "Line #{@current_line_number} not empty: #{line}"
        end
    end
end