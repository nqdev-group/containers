-- Bitwise AND function (manual implementation)
local function band(a, b)
    local result = 0
    local shift = 0
    while a > 0 or b > 0 do
        local bit_a = a % 2
        local bit_b = b % 2
        if bit_a == 1 and bit_b == 1 then
            result = result + 2^shift
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift + 1
    end
    return result
end

-- CIDR matching function with error handling
function cidr_match(ip_address, cidr)
    -- Validate IP address format
    local function is_valid_ip(ip)
        local a, b, c, d = ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
        return a and b and c and d and tonumber(a) < 256 and tonumber(b) < 256 and tonumber(c) < 256 and tonumber(d) < 256
    end

    -- Validate CIDR format (IPv4 format)
    local function is_valid_cidr(cidr)
        local prefix, mask = cidr:match("([^/]+)(/[%d]+)")
        return prefix and mask and tonumber(mask:sub(2)) and tonumber(mask:sub(2)) >= 0 and tonumber(mask:sub(2)) <= 32
    end

    -- Check if IP is valid
    if not is_valid_ip(ip_address) then
        return false, "Invalid IP address format"
    end

    -- Check if CIDR is valid
    if not is_valid_cidr(cidr) then
        return false, "Invalid CIDR format"
    end

    -- Convert IP to integer
    local function ip_to_int(ip)
        local a, b, c, d = ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
        return (tonumber(a) * 16777216) + (tonumber(b) * 65536) + (tonumber(c) * 256) + tonumber(d)
    end

    -- Convert CIDR to network and mask
    local function cidr_to_netmask(cidr)
        local prefix, mask = cidr:match("([^/]+)(/[%d]+)")
        local mask_len = tonumber(mask:sub(2))
        return ip_to_int(prefix), 0xFFFFFFFF - (2^(32 - mask_len) - 1)
    end

    -- Get IP and CIDR network and mask
    local ip_int = ip_to_int(ip_address)
    local network, netmask = cidr_to_netmask(cidr)

    -- Check if the IP matches the CIDR range
    return band(ip_int, netmask) == band(network, netmask)
end
