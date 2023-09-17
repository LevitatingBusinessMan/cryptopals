require "base64"
require_relative "util"

module Challenge1
	INPUT = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
	OUTPUT = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
	puts "Matched" if Base64.strict_encode64(p INPUT.from_hex).strip == OUTPUT
end

module Challenge2
	INPUT1 = "1c0111001f010100061a024b53535009181c"
	INPUT2 = "686974207468652062756c6c277320657965"
	OUTPUT = "746865206b696420646f6e277420706c6179"

	puts "Matched" if (p INPUT1.from_hex ^ INPUT2.from_hex).unpack("H*").first == OUTPUT
end

module Challenge3
	INPUT = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
	puts ((0..255).to_a.map do |x|
		[x, INPUT.from_hex.unpack("C*").map{|y| y ^ x}.pack("C*")]
	end).filter {|x,t| t.bytes.all? {|y| y.between?(0x20, 0x7f)}}
	#88
	#Cooking MC's like a pound of bacon
end

module Challenge4
	INPUT = File.read("4.txt")
	lines = INPUT.split("\n").map(&:from_hex)
	puts
	puts (lines.map do |l|
		[l.unpack("H*"), ((0..255).to_a.map do |x|
			[x, l.bytes.map{|y| y ^ x}.pack("C*")]
		end).filter{|x,t| t.bytes.all? {|y| y.between?(0x20, 0x7e) || y.between?(0x7,0xd)}}]
	end).filter{|x| !x[1].empty?}
	#7b5a4215415d544115415d5015455447414c155c46155f4058455c5b523f
	#53
	#Now that the party is jumping\n
end

module Challenge5
	INPUT="Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"
	KEY="ICE"
	i = -1
	p INPUT.bytes.map{|c| c^KEY[(i+=1) > 2 ? i = 0 : i].ord }.pack("C*").unpack("H*").first
end

module Challenge6
	puts
	INPUT = Base64.decode64 File.read "6.txt"
	p INPUT
	# Keysizes to test
	KEYSIZES = 2..40
	abort "Not good" if "this is a test".distance("wokka wokka!!!") != 37
	guesses = KEYSIZES.map{|keysize|
		a,b = INPUT.chars.each_slice(keysize).map(&:join)[0..1]
		p [keysize, a.distance(b) / keysize.to_f]
	}.sort_by{|a,b|b}.map{|x|x[0]}

	for guess in guesses
		puts "Guess: #{guess}"
		# This padding should work if the key is human readable
		# A solution would be to remove the padding from the final block
		remainder = INPUT.length % guess
		pad = remainder > 0 ? guess - remainder : 0
		blocks = (INPUT + "\x00" * pad).chars.each_slice(guess).to_a
		begin
			transposed = blocks.transpose.map(&:join)
		rescue
			next
		end
		pos_keys = transposed.map{|t|
			(1..255).filter {|k|
				t.bytes.map{|c| c^k}.all? {|y| y.between?(0x20, 0x7e) || y == 0xa}
			}
		}

		p pos_keys
		# Try all possibilities of the possible keys
		for key in pos_keys.reduce(&:product).map(&:flatten) # This is a cool trick to get all permutations
			key =  key.pack("C*")
			i = -1
			p "Key: #{key}", INPUT.bytes.map{|c| c^key[(i+=1) > key.length-1 ? i = 0 : i].ord }.pack("C*")
		end
	end

	# key = "Terminator X: Bring the noise"
end

module Challenge7
	require "openssl"
	INPUT = Base64.decode64 File.read "7.txt"
	cipher = OpenSSL::Cipher.new "aes-128-ecb"
	cipher.decrypt
	cipher.key = "YELLOW SUBMARINE"
	p cipher.update(INPUT) + cipher.final
end

module Challenge8
	INPUT = File.read "8.txt"
	KEYSIZE = 16
	CIPHERTEXT_BLOCKS = INPUT.split("\n").map{|t| t.from_hex}.map{|t| t.chars.each_slice(KEYSIZE).map(&:join)}
	CIPHERTEXT_BLOCKS.each_with_index {|blocks, i|
		blocks.each_with_index {|block,j|
			# Compare to blocks ahead
			for k in j+1..blocks.length-1
				distance =  block.distance(blocks[k])
				if distance < 10
					puts "Low distance of #{distance} found in #{i}. Comparing block #{j} with #{k}"
				end
			end
		}
	}

	# Ciphertext 132
end
