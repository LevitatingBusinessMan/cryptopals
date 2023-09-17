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
