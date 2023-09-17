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
            throw "Unequal lengths" if self.length != key.length
			self.bytes.zip(key.bytes).map{|a,b| a ^ b}.pack("C*")
		when Integer
			self.bytes.map{|a| a ^ key}.pack("C*")
		end
	end
end

module AES
    require "openssl"
    BLOCKSIZE = 16
    IV = 0.chr * BLOCKSIZE # Unnecessary cause xorring this doesn't do much

    def self.encrypt_ebc plaintext, key
        cipher = OpenSSL::Cipher.new "aes-128-ecb"
        cipher.encrypt
        cipher.key = key
        cipher.update(plaintext) + cipher.final
    end
    def self.decrypt_ebc ciphertext, key
        cipher = OpenSSL::Cipher.new "aes-128-ecb"
        cipher.decrypt
        cipher.key = key
        cipher.padding = 0
        cipher.update(ciphertext) + cipher.final
    end
    def self.decrypt_cbc ciphertext, key
        abort "Need to pad" if ciphertext.length % BLOCKSIZE != 0
        blocks = ciphertext.chars.each_slice(BLOCKSIZE).map(&:join)
        last = IV
        plaintext = ""
        blocks.each do |block|
            plaintext << (AES::decrypt_ebc(block, key) ^ last)
            last = block
        end
        plaintext
    end
end
