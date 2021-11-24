def part_of_speech? (str)
    parts_of_speech = ["межд.", "част.", "нар.", "числ.", "мест.", "союз"]
    if parts_of_speech.include?(str)
        return true
    else
        return false
    end
end