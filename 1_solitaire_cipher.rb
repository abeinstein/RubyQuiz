class Encrypter
  def encrypt(string)
    decrypt_str = string
    
    # Remove non-letter chars, make uppercase
    decrypt_str = decrypt_str.gsub(/[^A-Za-z]+/, '').upcase
    
    # Group into 5 letters each, padding at the end
    decrypt_str = group_by_five_and_pad(decrypt_str)
    
    # Generate keystream
    keystream_str = keystream(decrypt_str)
    
    # Change letters to numbers
    decrypt_str_nums = []
    keystream_str_nums = []
    decrypt_str.gsub(/([A-Z])/) { |c| decrypt_str_nums << (c.ord - 64 )}
    keystream_str.gsub(/([A-Z])/) { |c| keystream_str_nums << (c.ord - 64)}
    
    # Add the two arrays together
    sums = sum_two_arrays(decrypt_str_nums, keystream_str_nums)
    
    # Change back to letters
    alphabet = ('A'..'Z').to_a
    final_str = ""
    sums.each do |num|
      final_str << alphabet[num-1]
    end
    final_str = group_by_five_and_pad(final_str)

    return final_str
  end
  
  def decrypt(encoded_string)
    # Generate keystream
    keystream_str = keystream(encoded_string)
    
    # Change letters to numbers
    encoded_str_nums = []
    keystream_str_nums = []
    encoded_string.gsub(/([A-Z])/) { |c| encoded_str_nums << (c.ord - 64 )}
    keystream_str.gsub(/([A-Z])/) { |c| keystream_str_nums << (c.ord - 64)}
    
    # Subtract two arrays
    diffs = sub_two_arrays(encoded_str_nums, keystream_str_nums)
    
    # Change back to letters
    alphabet = ('A'..'Z').to_a
    final_str = ""
    diffs.each do |num|
      final_str << alphabet[num-1]
    end
    final_str = group_by_five_and_pad(final_str)
    
    return final_str 
  end
  
  # This adds two arrays, mod 26
  def sum_two_arrays(array1, array2)
    sums = array1.zip(array2)
    sums.map! do |p|
      s = p[0] + p[1]
      if s > 26
        s -= 26
      end
      s
    end
    return sums
  end
  
  def sub_two_arrays(array1, array2)
    diffs = array1.zip(array2)
    diffs.map! do |p|
      d = p[0] - p[1]
      if d <= 0
        d += 26
      end
      d
    end
    return diffs
  end
  
  def keystream(string)
    deck = Deck.new
    keystream_string = ""
    string.split("").each do |c|
      unless c == " " 
        deck = solitaire_shuffle(deck)
        if l = deck.find_output_letter
          keystream_string << l
        else
          until l
            deck = solitaire_shuffle(deck)
            l = deck.find_output_letter
          end
          keystream_string << l
        end 
      end
    end
    group_by_five_and_pad(keystream_string)
    #keystream_string
  end
  
  def solitaire_shuffle(deck)
    deck.move_card_down('A', 1)
    deck.move_card_down('B', 2)
    deck.triple_cut
    deck.count_cut
    return deck
  end
    
  def group_by_five_and_pad(string)
    groups_of_five = string.scan(/.{1,5}/)
    if groups_of_five.last.length != 5
      last = groups_of_five.last
      until last.length == 5
        last << "X"
      end
      groups_of_five.pop
      groups_of_five.push(last)
    end
    
    return groups_of_five.join(" ")
  end
end

class Deck
  attr_accessor :cards
  def initialize
    @cards = (1..52).to_a << 'A' << 'B'
  end
  
  # This function moves the card down. It can never become the first card.
  def move_card_down(card, num_spots)
    card_index = @cards.index(card)
    new_index = (card_index + num_spots)
    if new_index > 53
      new_index = (new_index % 54) + 1 # The plus 1 prevents it from becoming the first card
    end
    @cards.delete_at(card_index)
    @cards.insert(new_index, card)
  end
  
  # This finds the two Jokers, and switches the cards around them
  def triple_cut
    a_joker_index = @cards.index('A')
    b_joker_index = @cards.index('B')
    first_j_index = [a_joker_index, b_joker_index].min
    last_j_index = [a_joker_index, b_joker_index].max
    first_cut = @cards[0...first_j_index]
    middle_cut = @cards[first_j_index..last_j_index]
    last_cut = @cards[(last_j_index + 1)..53]
    @cards = last_cut + middle_cut + first_cut
  end
  
  def count_cut
    bottom_card_value = get_card_value(@cards[53])
    
    
    cut_from_top = @cards[0...bottom_card_value]
    rest_of_deck = @cards[bottom_card_value..53]
    insert_at = rest_of_deck.size - 1
    @cards = rest_of_deck.insert(insert_at, cut_from_top).flatten
  end
  
  def find_output_letter
    top_card_value = get_card_value(@cards.first)
    final_card = @cards[top_card_value]
    output_letter = card_to_letter(final_card)
    return output_letter # Can be nil
  end
  
  def card_to_letter(card)
    alphabet = ('A'..'Z').to_a
    card_value = get_card_value(card)
    if card_value == 53
      return nil
    elsif card_value > 26
      card_value_index = (card_value % 27)
    else
      card_value_index = card_value - 1
    end
    return alphabet[card_value_index]
  end
  
  def get_card_value(card)
    if card == "A" || card == "B"
      return 53
    else
      return card.to_i
    end
  end
  
  def to_s
    @cards.join(" ")
  end
end

# Main Code
input = ARGV[0]
en = Encrypter.new

if input.match(/[A-Z]{5}+$/)
  puts en.decrypt(input)
else
  puts en.encrypt(input)
end
