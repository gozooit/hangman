require 'json'

class Word
  attr_accessor :str, :length, :array, :display, :compared

  def initialize(str = pick_random_word)
    @str = str.chomp
    @array = @str.split('')
    @length = @str.length
    @display = @array.join(' ')
    @compared = @array.map.with_index { |l, i| i.zero? ? l : '_' }.join
  end

  def pick_random_word
    loop do
      random_word = File.readlines('wordlist.txt').sample
      break random_word.chomp if random_word.length.between?(5, 12)
    end
  end
end

class Game
  def initialize
    @secret_word = Word.new
    @remaining_guess = 6
    @compared_words = @secret_word.array.map.with_index { |l, i| i.zero? ? l : '_' }.join
  end

  def compare(word1, word2 = @secret_word)
    return true if word1.str == word2.str

    res = word1.array.map.with_index do |letter, index|
      letter == word2.array[index] ? letter : '_'
    end
    res.each_with_index { |l, i| @compared_words[i] = res[i] if l != '_' }
  end

  def player_input
    puts "Please enter a word of #{@secret_word.length.to_s} character. #{@remaining_guess} guesses remaining."
    puts @compared_words
    input = gets
    puts
    Word.new(input)
  end

  def play
    loop do
      @guess = player_input
      @remaining_guess -= 1
      res = compare(@guess)
      break if res == true || @remaining_guess.zero?
    end
    puts @guess.str == @secret_word.str ? 'You found it !' : 'Too many tries..'
    puts "The word was #{@secret_word.str}"
  end

  def save
    json_object = JSON.dump(
      {
        secret_word: @secret_word,
        guess: @guess,
        remaining_guess: @remaining_guess,
        compared_words: @compared_words
      }
    )
    File.open('save.json', 'w') { |file| file.puts json_object }
  end

  def self.load
    data = File.open('save.json', )
  end
end

new_game = Game.new

loop do
  begin
    new_game.play
  rescue Interrupt
    puts 'Do you want to save ?'
    input = gets.chomp
    new_game.save if input == 'yes'
  end
  break if false
end
