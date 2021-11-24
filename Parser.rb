require_relative 'Lexer.rb'
require_relative 'Headword.rb'
require_relative 'Example.rb'

class Parser
    attr_accessor :output, :current_lex, :end_of_file, :references, :lexer, :lokahead, :output_mass, :words_num

    def initialize
        self.output = ""
        self.current_lex = ""
        self.end_of_file = false
        self.references = []
        self.words_num = 0
    end

    def parse
        @lokahead = @lexer.scan
        while(!end_of_file) do
            if @lokahead[:tag] == "end of file"
                @end_of_file = true
            elsif lokahead[:tag] == "lx"
                @words_num += 1
                match_lex
            end
        end

    end

    def convert(file_name)
        self.lexer = Lexer.new(file_name)
        parse
        @lexer.close_file
        add_references
        puts "\nCount of Adyghe words: #{@words_num}"
        # puts @references
        return @output_mass
    end

    def match_lex
        pos = nil
        ref = nil
        @current_lex = @lokahead[:lx]
        @lokahead = @lexer.scan
        while @lokahead[:tag] != "lx" && !@end_of_file do
            if @lokahead[:tag] == "part of speech"
                pos = lokahead[:lx]
                @lokahead = @lexer.scan
            end
            if @lokahead[:tag] == "hm"
                while @lokahead[:tag] == "hm"  do
                    match_homonym(pos: pos)
                    @lokahead = @lexer.scan
                end
            else
                @output << "\\lx #{@current_lex} \n"
                if @lokahead[:tag] == "reference"
                    match_referense
                    @lokahead = @lexer.scan
                end
                if @lokahead[:tag] == "g_Rus"
                    match_translate
                    @lokahead = @lexer.scan
                end
                if @lokahead[:tag] == "darkblue"
                    while @lokahead[:tag] == "darkblue" do
                        match_darkblue(pos: pos)
                        @lokahead = @lexer.scan
                    end
                end
                if @lokahead[:tag] == "tag b"
                    match_exdarkblue(@lokahead[:lx])
                    @lokahead = @lexer.scan
                end
                while lokahead[:tag] == "example" do
                    match_example
                    @lokahead = @lexer.scan
                end
            end
        end
        @output <<"\n"
    end

    def match_homonym(pos: nil)
        if !@lokahead[:pos] && pos
            this_pos = pos
        else
            this_pos = @lokahead[:pos]
        end
        lk = Homonym.new(num: @lokahead[:num], lex: @lokahead[:lx], pos: this_pos, dscr: @lokahead[:dscr])
        if @output[@output.length - 2] == "\n"
            @output << "\\lx #{@current_lex} \n"
        else
            @output << "\n\\lx #{@current_lex} \n"
        end
        @output << "#{lk.convert}"
        while (1)
            @lokahead = @lexer.scan
            if @lokahead[:tag] == "end of file"
                @end_of_file = true
                break
            elsif @lokahead[:tag] == "darkblue"
                match_darkblue
            elsif @lokahead[:tag] == "example"
                match_example
            else
                @lexer.unget_line
                break
            end
        end
    end

    def match_darkblue(pos: nil)
        if !@lokahead[:pos] && pos
            this_pos = pos
        else
            this_pos = @lokahead[:pos]
        end 
        lk = Darkblue.new(lex: @lokahead [:lx], pos: this_pos, dscr: @lokahead[:dscr])
        @output << "#{lk.convert}"
        while (1)
            @lokahead = @lexer.scan
            if @lokahead[:tag] == "end of file"
                @end_of_file = true
                break
            elsif @lokahead[:tag] == "example"
                match_example
            else
                @lexer.unget_line
                break
            end
        end
    end

    def match_exdarkblue(example)
        lk = Example.new(ex: example)
        flg = false
        while (1)
            @lokahead = @lexer.scan
            if @lokahead[:tag] == "end of file"
                @end_of_file = true
                break
            elsif @lokahead[:tag] == "darkblue"
                flg = true
                lk.add_trslt(@lokahead[:lx])
            else
                if flg
                    @output << "#{lk.convert}"
                end
                @lexer.unget_line
                break
            end
        end
    end

    def match_example
        lk = Example.new(ex: @lokahead [:ex], trslt: @lokahead [:trslt])
        @output << "#{lk.convert}"
    end

    def match_translate()
        lk = Headword.new(lex: @lokahead [:lx], pos:  @lokahead [:pos], dscr: @lokahead [:dscr])
        @output << "#{lk.convert}"
        while (1)
            @lokahead = @lexer.scan
            if @lokahead[:tag] == "end of file"
                @end_of_file = true
                break
            elsif @lokahead[:tag] == "example"
                match_example
            else
                @lexer.unget_line
                break
            end
        end
    end

    def match_referense
        @output << "\\\mn #{@lokahead[:lx]} \n" # Не добавлена ссылка на правильный вариант
        reference = {lx: lokahead[:lx]}
        reference[:ref] = @current_lex
        @references << reference
    end

    def add_reference(mass, index, ref)
        if mass[index + 1].include?("\\hm")
            index += 2
        elsif mass[index + 1].include?("\\va")
            index += 2
        else
            index += 1
        end
        mass[index, 0] = "\\va #{ref}"
    end

    def lx_index_in_mass(mass, lx)
        lx = "\\lx #{lx}"
        for i in 0..mass.length - 1
            if mass[i].include?(lx)
                return i
            end        
        end
        return nil
    end

    def add_references
        @output_mass = @output.split("\n")
        @references.each do |ref_elem|
            lx = ref_elem[:lx]
            ref = ref_elem[:ref]
            index = lx_index_in_mass(@output_mass, lx)
            if index != nil
                add_reference(@output_mass, index, ref)
            end
        end
    end

end
