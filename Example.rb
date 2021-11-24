class Example
    attr_reader :tag, :formatted_text
    attr_accessor :ex, :trslt
    
    def initialize(ex: , trslt: nil)
        self.ex = ex
        self.trslt = []
        if trslt
            @trslt << trslt
        end
    end

    def format
        # @formatted_text = []
        @formatted_text = ""
        @formatted_text << "\\xv_Ady #{@ex} \n"
        @formatted_text << "\\x_Rus "
        @trslt.each do |t|
            @formatted_text << "#{t}; "
        end
        @formatted_text.chomp!('; ')
        @formatted_text << "\n"
    end

    def convert
        self.format
        return @formatted_text
    end

    def add_trslt(trslt)
        @trslt << trslt
    end

end