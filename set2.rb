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
