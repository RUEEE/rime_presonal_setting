-- mathcal.lua
-- 仿 LaTeX 语法的数学符号输入脚本
-- 2024.05.29

local M = {}

-- =======================================================
-- 1. 配置区域：在这里定义哪些符号可以被转换
-- =======================================================

-- 采用贪婪匹配，例如定义了 'a' 和 'aa'，输入 \aa 会优先匹配 'aa'
local latex_map = {
    -- 希腊字母
   ["alpha"]="α",
   ["beta"]="β",
   ["gamma"]="γ",
   ["delta"]="δ",
   ["epsilon"]="ε",
   ["zeta"]="ζ",
   ["eta"]="η",
   ["theta"]="θ",
   ["iota"]="ι",
   ["kappa"]="κ",
   ["lambda"]="λ",
   ["mu"]="μ",
   ["nu"]="ν",
   ["xi"]="ξ",
   ["omicron"]="ο",
   ["pi"]="π",
   ["rho"]="ρ",
   ["sigma"]="σ",
   ["tau"]="τ",
   ["upsilon"]="υ",
   ["phi"]="φ",
   ["chi"]="χ",
   ["psi"]="ψ",
   ["omega"]="ω",
   
   ["Alpha"]="Α",
   ["Beta"]="Β",
   ["Gamma"]="Γ",
   ["Delta"]="Δ",
   ["Epsilon"]="Ε",
   ["Zeta"]="Ζ",
   ["Eta"]="Η",
   ["Theta"]="Θ",
   ["Iota"]="Ι",
   ["Kappa"]="Κ",
   ["Lambda"]="Λ",
   ["Mu"]="Μ",
   ["Nu"]="Ν",
   ["Xi"]="Ξ",
   ["Omicron"]="Ο",
   ["Pi"]="Π",
   ["Rho"]="Ρ",
   ["Sigma"]="Σ",
   ["Tau"]="Τ",
   ["Upsilon"]="Υ",
   ["Phi"]="Φ",
   ["Chi"]="Χ",
   ["Psi"]="Ψ",
   ["Omega"]="Ω",

    
    -- 常用数学符号
    ["int"] = "∫",
	["iint"] = "∬",
	["iiint"] = "∭",
	["oint"] = "∮",
	["oiint"] = "∯",
    ["sum"] = "∑",
	["prod"] = "∏",
    ["sqrt"] = "√",
	["perp"] = "⊥",
	["angle"] = "∠",
    ["parallel"] = "∥",
	["wedge"] = "∧",
	["vee"] = "∨",
    ["cap"] = "∩",
	["cup"] = "∪",
    ["in"] = "∈",
	["notin"] = "∉",
	["subset"] = "⊂",
	["supset"] = "⊃",
    ["forall"] = "∀",
    
	["exists"] = "∃",
	["empty"] = "∅",
    ["nabla"] = "∇",
	["partial"] = "∂",
	["infty"] = "∞",
	
	-- 域
	
    ["defC"] = "ℂ",
	["defH"] = "ℍ",
	["defN"] = "ℕ",
	["defP"] = "ℙ",
	["defQ"] = "ℚ",
	["defR"] = "ℝ",
	["defZ"] = "ℤ",
	
    -- 关系运算符
    ["neq"] = "≠",
	["leq"] = "≤",
	["geq"] = "≥", 
    ["approx"] = "≈",
	["equiv"] = "≡",
	["cong"] = "≅",
    ["sim"] = "∼",
	["propto"] = "∝",
    ["pm"] = "±",
	["times"] = "×",
	["div"] = "÷",
	["cdot"] = "·",
    
    -- 箭头
    ["to"] = "→",
	["gets"] = "←",
    ["leftarrow"] = "←",
	["rightarrow"] = "→", 
    ["uparrow"] = "↑",
	["downarrow"] = "↓",
    ["leftrightarrow"] = "↔",
	["Rightarrow"] = "⇒",
	["Leftarrow"] = "⇐",
    
    -- 杂项
    ["dots"] = "…",
	["cdots"] = "⋯",
	
	-- others
	["any"] = "∀",
	["fumo"] = "ᗜˬᗜ",
	["fuemo"] = "ᗜ‸ᗜ",
	["star"] = "✰",
	["quest"] = "?",
	["iquest"] = "¿",
	["yinyang"] = "☯",
	["ben"] = "⌬",
	["dbs"] = "§",
	
	["end"] = "@"
}

-- 上标映射表 (Superscript Map): ^X -> value
local sup_map = {
    ["0"]="⁰", ["1"]="¹", ["2"]="²", ["3"]="³", ["4"]="⁴", 
    ["5"]="⁵", ["6"]="⁶", ["7"]="⁷", ["8"]="⁸", ["9"]="⁹",
    ["+"]="⁺", ["-"]="⁻", ["="]="⁼", ["("]="⁽", [")"]="⁾",
	
    ["a"]="ᵃ", ["b"]="ᵇ", ["c"]="ᶜ", ["d"]="ᵈ", ["e"]="ᵉ", ["f"]="ᶠ", ["g"]="ᵍ",
    ["h"]="ʰ", ["i"]="ⁱ", ["j"]="ʲ", ["k"]="ᵏ", ["l"]="ˡ", ["m"]="ᵐ", ["n"]="ⁿ",
    ["o"]="ᵒ", ["p"]="ᵖ",            ["r"]="ʳ", ["s"]="ˢ", ["t"]="ᵗ",
	["u"]="ᵘ", ["v"]="ᵛ", ["w"]="ʷ", ["x"]="ˣ", ["y"]="ʸ", ["z"]="ᶻ",
	
	["T"]="ᵀ",
	
}

-- 下标映射表 (Subscript Map): _X -> value
local sub_map = {
    ["0"]="₀", ["1"]="₁", ["2"]="₂", ["3"]="₃", ["4"]="₄", 
    ["5"]="₅", ["6"]="₆", ["7"]="₇", ["8"]="₈", ["9"]="₉",
    ["+"]="₊", ["-"]="₋", ["="]="₌", ["("]="₍", [")"]="₎",
    ["a"]="ₐ", ["e"]="ₑ", ["o"]="ₒ", ["x"]="ₓ", ["h"]="ₕ", ["k"]="ₖ",

}

-- =======================================================
-- 2. 核心逻辑
-- =======================================================

-- 辅助函数：将字符串分割为 UTF-8 字符数组
local function utf8_to_table(str)
    local t = {}
    for _, code in utf8.codes(str) do
        table.insert(t, utf8.char(code))
    end
    return t
end

-- 配置文件路径
local path = 'recognizer/patterns/mathcal'

function M.func(input, seg, env)
    -- 检查是否为 mathcal segment
    if not seg:has_tag("mathcal") or input == '' then return end

    -- 获取触发前缀 (recognizer/patterns/mathcal 的第 2 个字符)
    if not env.mathcal_keyword then
        -- 默认值为 "MM" (取第二个 M)，防止读取配置失败报错
        local pattern = env.engine.schema.config:get_string(path) or "mM"
        -- 取第2个字节/字符作为触发键。注意：如果前缀是汉字需小心，这里假设是 ASCII
        env.mathcal_keyword = pattern:sub(2, 3) 
    end

    local prefix = env.mathcal_keyword
    
    -- 简单的匹配：必须以触发键开头
    if not input:find("^" .. prefix) then return end
    
    -- 提取触发键之后的内容
    local content = input:sub(#prefix + 1)
    if content == "" then return end

    -- 将输入转换为字符数组，方便处理
    local chars = utf8_to_table(content)
    local result = ""
    local i = 1
    
    while i <= #chars do
        local c = chars[i]
        
        if c == "\\" then
            -- [逻辑 1] 反斜杠：贪婪匹配命令
            local matched = false
            -- 从剩余字符串的最长可能长度开始尝试匹配 (贪婪)
            -- 限制最大命令长度为 20，避免性能问题
            local max_len = math.min(#chars - i, 20)
            
            for len = max_len, 1, -1 do
                -- 拼接从 i+1 开始的 len 个字符
                local key = table.concat(chars, "", i + 1, i + len)
                if latex_map[key] then
                    result = result .. latex_map[key]
                    i = i + 1 + len -- 跳过 '\' 和 key
                    matched = true
                    break
                end
            end
            
            if not matched then
                -- 示例要求：\2 -> 2 (反斜杠匹配不到任何东西，直接忽略反斜杠，读取下一个字符)
                -- 所以这里单纯只跳过反斜杠，不添加任何东西，让循环进入下一次处理 '2'
                i = i + 1
            end
            
        elseif c == "^" then
            -- [逻辑 2] 上标：连续读取
            -- 跳过 '^' 本身
            i = i + 1
            -- 循环读取后续字符，直到遇到不支持上标的字符
            while i <= #chars do
                local next_char = chars[i]
                if sup_map[next_char] then
                    result = result .. sup_map[next_char]
                    i = i + 1
                else
                    -- 遇到不支持的字符，停止上标模式，不消费该字符
                    break
                end
            end
            
        elseif c == "_" then
            -- [逻辑 2] 下标：连续读取 (逻辑同上标)
            i = i + 1
            while i <= #chars do
                local next_char = chars[i]
                if sub_map[next_char] then
                    result = result .. sub_map[next_char]
                    i = i + 1
                else
                    break
                end
            end
        else
            -- [逻辑 3] 其他符号：原样输出
            result = result .. c
            i = i + 1
        end
    end

    -- 生成候选项
    -- text 为转换后的文本，comment 为原文提示
    local cand = Candidate("mathcal", seg.start, seg._end, result, "   (Math)")
    cand.quality = 100000000
    yield(cand)
end

return M.func
