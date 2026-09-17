--information:アクリルσ@Lens_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:オブジェクトの半透明部分を，磨りガラスのように背景をぼかして透過しているような見た目にします．
--label:Lens_S
--require:${LEAST_AVIUTL_VERSION}
---$tips:この透明度のピクセル ⇒ アクリル背景
---     :ここより不透明 ⇒ アクリル上に描画
---     :ここより透明 ⇒ 半透明 (アンチエイリアス)
---$track:基準透明度, min = 0, max = 100, step = 0.01
local base_alpha = 100

---$tips:アクリル化する半透明部分が単色のとき指定．
---$color:基準色
local base_color = nil

--group:色設定,true
---$tips:背景の輝度の反映率
---$track:透過輝度, min = 0, max = 200, step = 0.01, scale = 0.5
local mul_luma = 50

---$tips:背景の輝度に加算
---$track:輝度補正, min = -100, max = 100, step = 0.01
local add_luma = 0

---$tips:背景の彩度の反映率
---$track:透過彩度, min = 0, max = 200, step = 0.01, scale = 0.5
local mul_chroma = 100

---$tips:アクリル部分に色を付けます．
---$color:着色
local tint_color = 0x4050ff

---$tips:指定色の輝度の反映率
---$track:着色輝度, min = 0, max = 100, step = 0.01
local tint_luma = 0

---$tips:指定色の彩度の反映率
---$track:着色彩度, min = 0, max = 100, step = 0.01
local tint_chroma = 0

--group:ぼかし設定,true
---$track:blur::範囲, min = 0, max = 1000, step = 0.01, scale = 0.2
local blur = 20

---$track:blur::縦横比, min = -100, max = 100, step = 0.001
local blur_aspect = 0

---$track:blur::光の強さ, min = 0, max = 60, step = 0.1
local blur_luma_weight = 0

---$track:noise::ノイズ, min = 0, max = 100, step = 0.01, scale = 0.1
local noise_intensity = 4

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:noise::シード, min = -65536, max = 65535, step = 1
local noise_seed = 10000

--group:背景配置,false
---$track:移動X, min = -4000, max = 4000, step = 0.01
local move_x = 0

---$track:移動Y, min = -4000, max = 4000, step = 0.01
local move_y = 0

--trackgroup@move_x,move_y:MoveXY
---$track:拡大率, min = 1, max = 10000, step = 0.001, scale = 0.02
local scale = 100

---$track:回転, min = -1440, max = 1440, step = 0.01, scale = 0.25
local rotate = 0

--group:その他,false
---$tips:オブジェクトの背景に透明ピクセルがある場合に指定．加工されずに表示されてしまう背景を隠します．
---$color:背景色
local back_color = nil

---$nolang: name
---$tips:PI = {
---     :  base_alpha: number?,
---     :  base_color: number?,
---     :  mul_luma: number?,
---     :  add_luma: number?,
---     :  mul_chroma: number?,
---     :  tint_color: number?,
---     :  tint_luma: number?,
---     :  tint_chroma: number?,
---     :  blur: number?,
---     :  blur_aspect: number?,
---     :  blur_luma_weight: number?,
---     :  noise_intensity: number?,
---     :  noise_seed: number?,
---     :  move_x: number?,
---     :  move_y: number?,
---     :  scale: number?,
---     :  rotate: number?,
---     :  back_color: number|false|nil,
---     :}
---$value:PI
local PI = {}

--[[pixelshader@back_proj:
---$include "back_proj.hlsl"
]]
--[[pixelshader@combine:
---$include "../ibukihash.hlsl"
---$include "combine.hlsl"
]]
local obj, math, tonumber, unpack = obj, math, tonumber, unpack;
local lens_s = require("Lens_S")

if obj.getoption("gui") then
	local cx, cy, _ = obj.getvalue("center");
	cx, cy = cx + obj.cx, cy + obj.cy;
	obj.setanchor("move_x,move_y", 0, "line", "offset", cx, cy);
end

-- take parameters.
base_alpha = tonumber(PI.base_alpha) or base_alpha;
base_color = lens_s.PI.color_opt(PI.base_color, base_color);
mul_luma = tonumber(PI.mul_luma) or mul_luma;
add_luma = tonumber(PI.add_luma) or add_luma;
mul_chroma = tonumber(PI.mul_chroma) or mul_chroma;
tint_color = tonumber(PI.tint_color) or tint_color;
tint_luma = tonumber(PI.tint_luma) or tint_luma;
tint_chroma = tonumber(PI.tint_chroma) or tint_chroma;
blur = tonumber(PI.blur) or blur;
blur_aspect = tonumber(PI.blur_aspect) or blur_aspect;
blur_luma_weight = tonumber(PI.blur_luma_weight) or blur_luma_weight;
noise_intensity = tonumber(PI.noise_intensity) or noise_intensity;
noise_seed = tonumber(PI.noise_seed) or noise_seed;
move_x = tonumber(PI.move_x) or move_x;
move_y = tonumber(PI.move_y) or move_y;
scale = tonumber(PI.scale) or scale;
rotate = tonumber(PI.rotate) or rotate;
back_color = lens_s.PI.color_opt(PI.back_color, back_color);

-- normalize parameters.
base_alpha = math.min(math.max(1 - base_alpha / 100, 0), 1);
mul_luma = math.max(mul_luma / 100, 0);
add_luma = add_luma / 100;
mul_chroma = math.max(mul_chroma / 100, 0);
tint_color = math.floor(0.5 + tint_color) % 2 ^ 24;
tint_luma = math.max(tint_luma / 100, 0);
tint_chroma = math.max(tint_chroma / 100, 0);
blur = math.min(math.max(blur, 0), 1000);
blur_aspect = math.min(math.max(blur_aspect / 100, -1), 1);
blur_luma_weight = math.min(math.max(blur_luma_weight, 0), 60);
noise_intensity = math.max(noise_intensity / 100, 0);
noise_seed = math.floor(0.5 + noise_seed);
if noise_seed >= 0 then
	noise_seed = noise_seed
		+  2525 * (obj.id % 2 ^ 20)
		+ 13579 * (obj.effect_id % 2 ^ 20)
		+ 54321 * (obj.index % 2 ^ 20);
end
noise_seed = noise_seed % 2 ^ 20;
scale = math.min(math.max(scale / 100, 0.01), 100);
rotate = 2 * math.pi * ((rotate / 360) % 1);

-- pass to core.
lens_s.effect.acryl(
	base_alpha, base_color,
	mul_luma, add_luma, mul_chroma,
	tint_color, tint_luma, tint_chroma,
	blur * math.min(1 + blur_aspect, 1), blur * math.min(1 - blur_aspect, 1), blur_luma_weight,
	noise_intensity, noise_seed,
	move_x, move_y, scale, rotate,
	back_color);
