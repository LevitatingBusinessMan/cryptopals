require "base64"
require_relative "util"

module Challenge9
    p "YELLOW SUBMARINE".ljust(20, 0x4.chr)
end

module Challenge10
    require "openssl"
    INPUT = Base64.decode64 File.read "10.txt"
    BLOCKSIZE = 16
    KEY = "YELLOW SUBMARINE"
    abort "Need to pad" if INPUT.length % BLOCKSIZE != 0
    BLOCKS = INPUT.chars.each_slice(BLOCKSIZE).map(&:join)
    IV = 0.chr * BLOCKSIZE # Unnecessary cause xorring this doesn't do much
    last = IV
    plaintext = ""
    BLOCKS.each do |block|
        plaintext << (AES::decrypt_ebc(block, KEY) ^ last)
        last = block
    end
    p plaintext
end
