class String
	def from_hex
		[self].pack("H*")
	end
	def distance s2
		throw "Unequal lengths" if self.length != s2.length
		self.bytes.zip(s2.bytes).map{|a,b|(a^b).to_s(2).count("1")}.sum
	end
	def ^ key
		case key
		when String
            throw "Unequal lengths #{self.length} #{key.length}" if self.length != key.length
			self.bytes.zip(key.bytes).map{|a,b| a ^ b}.pack("C*")
		when Integer
			self.bytes.map{|a| a ^ key}.pack("C*")
		end
	end
    # ljust to a multiple
    def pad_to n
        remainder = self.length % n
        if remainder != 0
            self + 0.chr * (n - remainder) 
        else
            self
        end
    end
    def detect_low_distance blocksize, threshold
        throw "Need to pad" if self.length % blocksize != 0
        blocks = self.chars.each_slice(blocksize).map(&:join)
        results = []
        blocks.each_with_index {|block,j|
            # Compare to blocks ahead
            for k in j+1..blocks.length-1
                distance =  block.distance(blocks[k])
                if distance <= threshold
                    results << [distance, j, k]
                end
            end
        }
        results
    end
end

module AES
    require "openssl"
    BLOCKSIZE = 16

    def self.encrypt_ebc plaintext, key
        throw "Needs padding" if plaintext.length % BLOCKSIZE != 0
        cipher = OpenSSL::Cipher.new "aes-128-ecb"
        cipher.encrypt
        cipher.key = key
        cipher.padding = 0
        cipher.update(plaintext) + cipher.final
    end
    def self.decrypt_ebc ciphertext, key
        cipher = OpenSSL::Cipher.new "aes-128-ecb"
        cipher.decrypt
        cipher.key = key
        cipher.padding = 0
        cipher.update(ciphertext) + cipher.final
    end
    def self.decrypt_cbc ciphertext, key, iv=0.chr * BLOCKSIZE
        blocks = ciphertext.chars.each_slice(BLOCKSIZE).map(&:join)
        last = iv
        plaintext = ""
        blocks.each do |block|
            plaintext << (AES::decrypt_ebc(block, key) ^ last)
            last = block
        end
        plaintext
    end
    def self.encrypt_cbc plaintext, key, iv=0.chr * BLOCKSIZE
        blocks = plaintext.chars.each_slice(BLOCKSIZE).map(&:join)
        last = iv
        ciphertext = ""
        blocks.each do |block|
            last = AES::encrypt_ebc(block  ^ last, key)
            ciphertext << last
        end
        ciphertext
    end
    # Who knows what it will create
    def self.encryption_oracle plaintext
        key = Random.bytes BLOCKSIZE
        plaintext = (Random.bytes(rand(5..10)) + plaintext + Random.bytes(rand(5..10))).pad_to BLOCKSIZE
        case rand().round
        when 1
            encrypt_ebc plaintext, key
        when 0
            encrypt_cbc plaintext, key, iv=Random.bytes(BLOCKSIZE)
        end
    end
end

# Return ebc if the function creates a ciphertext with identical blocks
# otherwise returns cbc
def cbc_ebc_detector blocksize=AES::blocksize
    ciphertext = yield 0.chr * 1024
    ciphertext.detect_low_distance(blocksize, 0).empty? ? "cbc" : "ebc"
end
