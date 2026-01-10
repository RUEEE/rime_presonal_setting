-- jap_input.lua
-- 罗马音转日文假名脚本
-- 触发：jJ (可在 schema 中配置)

local M = {}

-- =======================================================
-- 1. 数据映射表
-- =======================================================

-- 罗马音 -> 平假名 映射表
-- 包含基础五十音、浊音、半浊音、拗音
-- 采用贪婪匹配，长的键放在前面或依靠代码逻辑优先匹配长键
local romaji_map = {
    -- 基础元音
    ["a"]="あ", ["i"]="い", ["u"]="う", ["e"]="え", ["o"]="お",
    
    -- K
    ["ka"]="か", ["ki"]="き", ["ku"]="く", ["ke"]="け", ["ko"]="こ",
    ["kya"]="きゃ", ["kyu"]="きゅ", ["kyo"]="きょ",
    
    -- S
    ["sa"]="さ", ["si"]="し", ["shi"]="し", ["su"]="す", ["se"]="せ", ["so"]="そ",
    ["sha"]="しゃ", ["shu"]="しゅ", ["sho"]="しょ",
    
    -- T
    ["ta"]="た", ["ti"]="ち", ["chi"]="ち", ["tu"]="つ", ["tsu"]="つ", ["te"]="て", ["to"]="と",
    ["cha"]="ちゃ", ["chu"]="ちゅ", ["cho"]="ちょ",
    ["tha"]="てゃ", ["thi"]="てぃ", ["thu"]="てゅ", ["the"]="てぇ", ["tho"]="てょ",
    
    -- N
    ["na"]="な", ["ni"]="に", ["nu"]="ぬ", ["ne"]="ね", ["no"]="の",
    ["nya"]="にゃ", ["nyu"]="にゅ", ["nyo"]="にょ",
    
    -- H
    ["ha"]="は", ["hi"]="ひ", ["hu"]="ふ", ["fu"]="ふ", ["he"]="へ", ["ho"]="ほ",
    ["hya"]="ひゃ", ["hyu"]="ひゅ", ["hyo"]="ひょ",
    
    -- M
    ["ma"]="ま", ["mi"]="み", ["mu"]="む", ["me"]="め", ["mo"]="も",
    ["mya"]="みゃ", ["myu"]="みゅ", ["myo"]="みょ",
    
    -- Y
    ["ya"]="や", ["yu"]="ゆ", ["yo"]="よ",
    
    -- R
    ["ra"]="ら", ["ri"]="り", ["ru"]="る", ["re"]="れ", ["ro"]="ろ",
    ["rya"]="りゃ", ["ryu"]="りゅ", ["ryo"]="りょ",
    
    -- W
    ["wa"]="わ", ["wi"]="うぃ", ["wu"]="う", ["we"]="うぇ", ["wo"]="を",
    
    -- G (K浊音)
    ["ga"]="が", ["gi"]="ぎ", ["gu"]="ぐ", ["ge"]="げ", ["go"]="ご",
    ["gya"]="ぎゃ", ["gyu"]="ぎゅ", ["gyo"]="ぎょ",
    
    -- Z (S浊音)
    ["za"]="ざ", ["zi"]="じ", ["ji"]="じ", ["zu"]="ず", ["ze"]="ぜ", ["zo"]="ぞ",
    ["ja"]="じゃ", ["ju"]="じゅ", ["jo"]="じょ",
    
    -- D (T浊音)
    ["da"]="だ", ["di"]="ぢ", ["du"]="づ", ["de"]="で", ["do"]="ど",
    ["dyu"]="でゅ", ["dya"]="でゃ", 
    
    -- B (H浊音)
    ["ba"]="ば", ["bi"]="び", ["bu"]="ぶ", ["be"]="べ", ["bo"]="ぼ",
    ["bya"]="びゃ", ["byu"]="びゅ", ["byo"]="びょ",
    
    -- P (H半浊音)
    ["pa"]="ぱ", ["pi"]="ぴ", ["pu"]="ぷ", ["pe"]="ぺ", ["po"]="ぽ",
    ["pya"]="ぴゃ", ["pyu"]="ぴゅ", ["pyo"]="ぴょ",
    
    -- 特殊
    ["n"]="ん", ["nn"]="ん",
    ["-"]="ー",
    
    -- 小假名 (x前缀 或 l前缀)
    ["xa"]="ぁ", ["xi"]="ぃ", ["xu"]="ぅ", ["xe"]="ぇ", ["xo"]="ぉ",
    ["la"]="ぁ", ["li"]="ぃ", ["lu"]="ぅ", ["le"]="ぇ", ["lo"]="ぉ",
    ["xtu"]="っ", ["xtsu"]="っ", 
}

-- 大写字母 -> 英文读音（片假名）
local alpha_map = {
    ["A"]="エー", ["B"]="ビー", ["C"]="シー", ["D"]="ディー", ["E"]="イー",
    ["F"]="エフ", ["G"]="ジー", ["H"]="エイチ", ["I"]="アイ", ["J"]="ジェー",
    ["K"]="ケー", ["L"]="エル", ["M"]="エム", ["N"]="エヌ", ["O"]="オー",
    ["P"]="ピー", ["Q"]="キュー", ["R"]="アール", ["S"]="エス", ["T"]="ティー",
    ["U"]="ユー", ["V"]="ブイ", ["W"]="ダブリュー", ["X"]="エックス", ["Y"]="ワイ",
    ["Z"]="ズィー"
}

-- =======================================================
-- 2. 辅助函数
-- =======================================================

-- 将平假名转换为片假名
-- 平假名 Unicode 范围一般在 0x3041-0x3096
-- 片假名 Unicode 范围一般在 0x30A1-0x30F6
-- 偏移量为 0x60 (96)
local function hira_to_kata(str)
    local res = ""
    for _, code in utf8.codes(str) do
        -- 简单范围判断：如果是平假名范围，加上偏移量
        if code >= 0x3041 and code <= 0x3096 then
            res = res .. utf8.char(code + 0x60)
        else
            -- 保持原样 (例如长音符 'ー' U+30FC，或者已经是片假名的字符)
            res = res .. utf8.char(code)
        end
    end
    return res
end

local function utf8_to_table(str)
    local t = {}
    for _, code in utf8.codes(str) do
        table.insert(t, utf8.char(code))
    end
    return t
end

-- 判断是否为元音
local function is_vowel(char)
    return char == 'a' or char == 'i' or char == 'u' or char == 'e' or char == 'o'
end

-- =======================================================
-- 3. 核心逻辑
-- =======================================================

local path = 'recognizer/patterns/jap_input'

function M.func(input, seg, env)
    -- 1. 触发判断
    -- 读取配置，如果未配置则硬编码检测是否以 jJ 开头
    if not env.jpa_input_keyword then
        -- 默认值为 "MM" (取第二个 M)，防止读取配置失败报错
        local pattern = env.engine.schema.config:get_string(path) or "jJ"
        -- 取第2个字节/字符作为触发键。注意：如果前缀是汉字需小心，这里假设是 ASCII
        env.jpa_input_keyword = pattern:sub(2, 3) 
    end

    local prefix = env.jpa_input_keyword
    
    -- 这里的正则逻辑稍微简化，直接判断前缀
    if not input:find("^" .. prefix) then return end
    
    -- 2. 准备处理
    local context = input:sub(#prefix + 1)
    if context == "" then return end
    
    local chars = utf8_to_table(context)
    local result = ""
    local is_katakana_mode = false -- 默认平假名
    
    local i = 1
    while i <= #chars do
        local c = chars[i]
        
        -- [情况A] 切换模式标志 ^
        if c == "^" then
            is_katakana_mode = not is_katakana_mode
            i = i + 1
            
        -- [情况B] 大写字母：映射为英文读音 (强制片假名，忽略 toggle 状态)
        elseif alpha_map[c] then
            result = result .. alpha_map[c]
            i = i + 1
            
        -- [情况C] 罗马音转换
        else
            -- 贪婪匹配：尝试匹配最长的罗马音 (最大长度设为 4，如 tshu, xtsu)
            local matched = false
            local max_len = math.min(#chars - i + 1, 4)
            
            for len = max_len, 1, -1 do
                -- 构造 key，例如 "k", "ky", "kyo"
                local key = table.concat(chars, "", i, i + len - 1)
                
                if romaji_map[key] then
                    local converted = romaji_map[key]
                    
                    -- 如果当前是片假名模式，将结果转为片假名
                    if is_katakana_mode then
                        converted = hira_to_kata(converted)
                    end
                    
                    result = result .. converted
                    i = i + len
                    matched = true
                    break
                end
            end
            
            -- 如果没匹配到 (Matched = false)
            if not matched then
                -- [情况D] 促音处理 (Double Consonant)
                -- 逻辑：如果当前字符和下一个字符相同，且不是元音，也不是 n (n有单独逻辑)，则视为促音
                local next_c = chars[i+1]
                if next_c and c == next_c and not is_vowel(c) and c ~= 'n' then
                    local sokuon = is_katakana_mode and "ッ" or "っ"
                    result = result .. sokuon
                    -- 只跳过当前字符，下一个重复字符留给下一轮循环作为声母处理
                    -- 例: kk -> っk -> (下一轮) ka -> っか
                    i = i + 1 
                else
                    -- [情况E] 完全无法识别，原样输出
                    result = result .. c
                    i = i + 1
                end
            end
        end
    end
    
    -- 3. 输出候选项
	local cand = Candidate("jap", seg.start, seg._end, result, "  (假名)")
    cand.quality = 100000000
    yield(cand)
end

return M.func
