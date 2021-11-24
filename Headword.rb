require_relative 'lib.rb'

class Headword
    attr_accessor :lex, :pos, :dscr, :reference
    attr_reader :tag, :formatted_text
    # @formatted_text = ""

    def initialize(lex: nil, pos: nil, dscr: nil, reference: nil)
        # self.tag = "\g_Rus"
        if lex == nil && tag_i != nil
            self.lex = tag_i
        else
            self.lex = lex
        end
        self.pos = pos
        self.dscr = dscr
        self.reference = reference
    end

    def format
        @formatted_text = ""
        # @formatted_text = []
        self.add_part_of_speech
        @formatted_text << "\\g_Rus #{@lex}\n"
        self.add_description_of_the_meaning
    end

    def convert
        self.format
        return @formatted_text
    end

    def add_part_of_speech
        if pos
            @formatted_text << "\\ps_Rus #{@pos}\n"
        end
    end
    
    def add_description_of_the_meaning # tag \o_Rus
        if @dscr
            for i in 0..@dscr.length - 1 
            # @dscr.each do |d|
            # puts @dscr[i]
                @formatted_text << "\\o_Rus #{@dscr[i]}\n"    
            end
        end
    end
    
    def show_formatted_text
        self.format
        puts @formatted_text
    end
end

class Homonym < Headword
    attr_accessor :num
    # @formatted_text = ""

    def initialize(num: 1, lex: nil, pos: nil, dscr: nil, reference: nil)
        # self.tag = "hm"
        self.num = num
        self.lex = lex
        self.pos = pos
        self.dscr = dscr
        self.reference = reference
    end
    
    def format
        # @formatted_text = []
        @formatted_text = ""
        @formatted_text << "\\hm #{@num}\n"
        self.add_part_of_speech
        if @lex 
            @formatted_text << "\\g_Rus #{@lex}\n"
        end
        self.add_description_of_the_meaning
    end

end

class Darkblue < Headword
    # @formatted_text = ""
    
    def initialize(lex: nil, pos: nil, dscr: nil, reference: nil)
        # self.tag = "\g_Rus"
        self.lex = lex
        self.pos = pos
        self.dscr = dscr
        self.reference = reference
    end

    def format
        @formatted_text = ""
        # @formatted_text = []
        self.add_part_of_speech
        @formatted_text << "\\g_Rus #{@lex}\n"
        self.add_description_of_the_meaning
    end

end
