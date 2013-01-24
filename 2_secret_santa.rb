require 'mail'

class SecretSanta
  attr_accessor :participants, :matches, :secret_santas
  
  def initialize
    @participants = []
    @matches = {}
    File.open("secret_santa_input.txt", "r").each_line do |line|
      line.match(/(\w+) (\w+)\s+<(\w+@\w+.\w+)>/)
      person = Person.new($1, $2, $3)
      @participants << person
    end
    @secret_santas = choose_santas
  end
  
  def email_santas
    @secret_santas.each do |santa, receiver|
      mail = Mail.new do
        from 'andrew.beinstein@gmail.com'
        to santa.email
        subject 'Your Secret Santa Assignment'
        body 'You are the Secret Santa for ' + receiver.first_name + ' ' + receiver.last_name
      end
      mail.delivery_method :sendmail
      mail.deliver
    end
  end
  
  def get_families
    families = {} # {last_name => [People]}
    @participants.each do |p|
      if families.keys.member?(p.last_name)
        families[p.last_name] << p
      else
        families[p.last_name] = [p]
      end
    end
    return families
  end
  
  # Chooses from largest family, excluding the last family chosen
  def choose_santas
    families = get_families
    matches_list = []
    previous_family = nil # updates with the last family added to the list
    until matches_list.size == 7
      # Find largest family
      largest_family = get_largest_family_excluding_last(families, previous_family)
      matches_list << families[largest_family][0]
      families[largest_family].delete_at(0)
      previous_family = largest_family
    end
    return create_hash(matches_list)
  end
  
  # Takes an ordered list of families from choose_santas
  def create_hash(ordered_family)
    santas = {}
    ordered_family.each_with_index do |person, index|
      santas[person] = ordered_family[(index + 1) % ordered_family.size]
    end
    return santas
  end
  
  # This gets the largest family after omission (so that the matches_list)
  # won't have two members of the same family next to each other.
  def get_largest_family_excluding_last(families, family_to_omit)
    max_size = 0
    largest_family = nil
    families_copy = families.clone
    families_copy.delete(family_to_omit)
    #puts families
    families_copy.each do |last_name, person_list|
          if person_list.length > max_size
            max_size = person_list.length
            largest_family = last_name
          end
        end
    return largest_family
  end
  
  
end

class Person
  attr_accessor :first_name, :last_name, :email
  
  def initialize(first, last, email)
    @first_name = first
    @last_name = last
    @email = email
  end
  
  def to_s
    @first_name + " " + @last_name + " " + "<" + @email + ">"
  end
end

#main
ss = SecretSanta.new
ss.secret_santas.each do |p1, p2|
  puts p1.to_s + " >> " + p2.to_s
end


