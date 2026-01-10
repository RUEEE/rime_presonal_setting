单纯的个人配置


jap_input.lua:
输入jJ后可以输入罗马音获得假名


mathcal.lua：
输入mM后可以输入近似latex：
输入\xx可以获得对应符号
输入^xxx或_yyy可以将xxx变为上标，yyy变成下标（需要字符支持）
如果没匹配上则为正常符号
例如：

\int\alphadx  ->  ∫αdx
\beta^32\+1   -> β³²+1（输入\之后无匹配上标，从而退出上标模式，\之后无对应符号，从而退出符号模式）



custom_phrase：
里面塞了一堆元素周期表内容，直接打大写就能获得

thd.dict.yaml：
车万词库