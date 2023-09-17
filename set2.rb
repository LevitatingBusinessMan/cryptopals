require "base64"
require_relative "util"

module Challenge9
    p "YELLOW SUBMARINE".ljust(20, 0x4.chr)
end

module Challenge10
    INPUT = Base64.decode64 File.read "10.txt"
    KEY = "YELLOW SUBMARINE"
    p AES::decrypt_cbc(INPUT, KEY)
end

module Challenge11
    5.times do
        puts cbc_ebc_detector &AES.method(:encryption_oracle)
    end
end

module Challenge12
    KEY = Random.bytes 16
    def self.encrypt plaintext
        plaintext = plaintext + Base64.decode64("Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK")
        AES.encrypt_ebc(plaintext.pad_to(AES::BLOCKSIZE), KEY)
    end
    # Find the blocksize
    for blocksize in 1..128
        ciphertext = encrypt "A" * blocksize * 2
        break if ciphertext.pad_to(blocksize).detect_low_distance(blocksize, 0).include? [0,0,1]
    end
    puts "Blocksize detected: #{blocksize}"
    
    i = 0
    known = ""
    exit = false
    loop do
        payload = "A" * (blocksize-1-(i%blocksize))
        ciphertext = encrypt payload
        break if ciphertext.length == i/blocksize*blocksize
        (0..127).each do |j|
            c = j.chr
            # It's a mess but it works flawlessly
            if encrypt("A" * (blocksize-1-(i%blocksize)) + known + c)[i/blocksize*blocksize..blocksize-1+(i/blocksize*blocksize)].distance(ciphertext[i/blocksize*blocksize..blocksize-1+(i/blocksize*blocksize)]) == 0
                known << c
                print c
                break
            end
        end
        i += 1
    end
    p known
end
