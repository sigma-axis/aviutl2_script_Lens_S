--information:レンズσ@Lens_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:オブジェクトの色や形状から曲面を生成し，ガラス塊がレンズ屈折しているように背景を合成します．
--label:Lens_S
--require:${LEAST_AVIUTL_VERSION}
--group:色設定,true
---$tips:背景の輝度の反映率
---$track:透過輝度, min = 0, max = 200, step = 0.01, scale = 0.5
local mul_luma = 80

---$tips:背景の輝度に加算
---$track:輝度補正, min = -100, max = 100, step = 0.01
local add_luma = 0

---$tips:背景の彩度の反映率
---$track:透過彩度, min = 0, max = 200, step = 0.01, scale = 0.5
local mul_chroma = 80

---$tips:元画像の輝度の反映率
---$track:表面輝度, min = 0, max = 200, step = 0.01, scale = 0.5
local face_luma = 20

---$tips:元画像の彩度の反映率
---$track:表面彩度, min = 0, max = 200, step = 0.01, scale = 0.5
local face_chroma = 80

--group:形状設定,true
---$tips:オブジェクトに対する背景の奥行き
---$track:背景距離, min = -1000, max = 1000, step = 0.01, scale = 0.2
local lift = 200

---$tips:全体的なレンズの凹凸の奥行きサイズ
---$track:起伏, min = 0, max = 1000, step = 0.01, scale = 0.2
local lens_amplify = 32

---$tips:全体的なレンズの曲面の横幅サイズ
---$track:丸み, min = 0, max = 4000, step = 0.01, scale = 0.05
local lens_round = 32

---$tips:オブジェクト輪郭部分の起伏
---$track:輪郭起伏, min = -100, max = 100, step = 0.01
local edge_amplify = 50

---$tips:オブジェクト輪郭部分の丸み
---$track:輪郭丸み, min = 0, max = 100, step = 0.01
local edge_round = 50

---$tips:オブジェクトの輝度変化に応じた起伏
---$track:輝度起伏, min = -100, max = 100, step = 0.01
local luma_amplify = 0

---$tips:オブジェクトの輝度変化に応じた丸み
---$track:輝度丸み, min = 0, max = 100, step = 0.01
local luma_round = 50

---$tips:オブジェクトの色境界からの距離に応じた起伏
---$track:色境界起伏, min = -100, max = 100, step = 0.01
local col_amplify = 0

---$tips:オブジェクトの色境界からの距離に応じた丸み
---$track:色境界丸み, min = 0, max = 100, step = 0.01
local col_round = 50

---$tips:オブジェクトの色境界を検出するしきい値
---$track:色境界しきい値, min = 0, max = 100, step = 0.01, scale = 0.2
local col_thresh = 4

---$tips:形状がギザギザしている場合に大きくしてください．
---$track:平滑化, min = 0, max = 1000, step = 0.01, scale = 0.2
local smooth = 100

---$check:形状可視化
local visualize_shape = false

--group:屈折設定,false
---$track:屈折率, min = 100, max = 400, step = 0.01, scale = 0.5
local refr_idx = 150

---$tips:負の値で色の順序が逆転します．
---$track:色収差, min = -100, max = 100, step = 0.001, scale = 0.1
local chrm_abrr = 3

--group:光設定,false
---$tips:0 で真上から，時計回りに正．
---$track:光角度, min = -1440, max = 1440, step = 0.01, scale = 0.25
local light_angle = -20

---$track:光沢, min = 0, max = 100, step = 0.01
local refl_power = 70

---$track:ハイライト, min = 0, max = 400, step = 0.01, scale = 0.25
local refl_light = 30

---$track:シャドウ, min = 0, max = 400, step = 0.01, scale = 0.25
local refl_shadow = 30

---$checksection:光角度を画面基準
local light_screen = false

--group:ぼかし設定,false
---$track:blur::範囲, min = 0, max = 1000, step = 0.01, scale = 0.2
local blur = 0

---$track:blur::縦横比, min = -100, max = 100, step = 0.001
local blur_aspect = 0

---$track:blur::光の強さ, min = 0, max = 60, step = 0.1
local blur_luma_weight = 0

---$track:noise::ノイズ, min = 0, max = 100, step = 0.01, scale = 0.1
local noise_intensity = 0

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:noise::シード, min = -65536, max = 65535, step = 1
local noise_seed = 10000

---$track:noise::ドットサイズ, min = 100, max = 6400, step = 0.01, scale = 0.0625
local noise_size = 100

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

---$checksection:画面基準で配置
local anchor_screen = false

--group:その他,false
---$tips:オブジェクトの背景に透明ピクセルがある場合に指定．加工されずに表示されてしまう背景を隠します．
---$color:背景色
local back_color = nil

---$nolang: options
---$tips:現実世界では RGB が正しい順序．
---$select:色収差順序
---RGB = 0
---GBR = 1
---BRG = 2
local chrm_abrr_order = 0

---$nolang: name
---$tips:PI = {
---     :  mul_luma: number?,
---     :  add_luma: number?,
---     :  mul_chroma: number?,
---     :  face_luma: number?,
---     :  face_chroma: number?,
---     :  lift: number?,
---     :  lens_amplify: number?,
---     :  lens_round: number?,
---     :  edge_amplify: number?,
---     :  edge_round: number?,
---     :  luma_amplify: number?,
---     :  luma_round: number?,
---     :  col_amplify: number?,
---     :  col_round: number?,
---     :  col_thresh: number?,
---     :  smooth: number?,
---     :  refr_idx: number?,
---     :  chrm_abrr: number?,
---     :  light_angle: number?,
---     :  refl_power: number?,
---     :  refl_light: number?,
---     :  refl_shadow: number?,
---     :  light_screen: boolean|number|nil,
---     :  blur: number?,
---     :  blur_aspect: number?,
---     :  blur_luma_weight: number?,
---     :  noise_intensity: number?,
---     :  noise_seed: number?,
---     :  noise_size: number?,
---     :  move_x: number?,
---     :  move_y: number?,
---     :  scale: number?,
---     :  rotate: number?,
---     :  anchor_screen: boolean|number|nil,
---     :  back_color: number|false|nil,
---     :  chrm_abrr_order: string?,
---     :}
---$value:PI
local PI = {}
--[[pixelshader@dist_init:
---$include "dist_header.hlsl"
---$include "dist_init.hlsl"
]]
--[[pixelshader@dist_step:
---$include "dist_header.hlsl"
---$include "dist_step.hlsl"
]]
--[[pixelshader@dist_fin:
---$include "dist_header.hlsl"
---$include "dist_fin.hlsl"
]]
--[[computeshader@calc_lens:
---$include "calc_lens.hlsl"
]]
--[[pixelshader@combine:
---$include "../ibukihash.hlsl"
---$include "combine.hlsl"
]]
--[[computeshader@visualize:
---$include "visualize.hlsl"
]]
local obj, math, tonumber = obj, math, tonumber;
local lens_s = require("Lens_S");

if obj.getoption("gui") then
	if anchor_screen then
		obj.setanchor("move_x,move_y", 0, "line", "screen");
	else
		local cx, cy, _ = obj.getvalue("center");
		cx, cy = cx + obj.cx, cy + obj.cy;
		obj.setanchor("move_x,move_y", 0, "line", "offset", cx, cy);
	end
else visualize_shape = false end

--#region PI / normalize parameters.

-- take parameters.
mul_luma = tonumber(PI.mul_luma) or mul_luma;
add_luma = tonumber(PI.add_luma) or add_luma;
mul_chroma = tonumber(PI.mul_chroma) or mul_chroma;
face_luma = tonumber(PI.face_luma) or face_luma;
face_chroma = tonumber(PI.face_chroma) or face_chroma;
lift = tonumber(PI.lift) or lift;
lens_amplify = tonumber(PI.lens_amplify) or lens_amplify;
lens_round = tonumber(PI.lens_round) or lens_round;
edge_amplify = tonumber(PI.edge_amplify) or edge_amplify;
edge_round = tonumber(PI.edge_round) or edge_round;
luma_amplify = tonumber(PI.luma_amplify) or luma_amplify;
luma_round = tonumber(PI.luma_round) or luma_round;
col_amplify = tonumber(PI.col_amplify) or col_amplify;
col_round = tonumber(PI.col_round) or col_round;
col_thresh = tonumber(PI.col_thresh) or col_thresh;
smooth = tonumber(PI.smooth) or smooth;
refr_idx = tonumber(PI.refr_idx) or refr_idx;
chrm_abrr = tonumber(PI.chrm_abrr) or chrm_abrr;
light_angle = tonumber(PI.light_angle) or light_angle;
refl_power = tonumber(PI.refl_power) or refl_power;
refl_light = tonumber(PI.refl_light) or refl_light;
refl_shadow = tonumber(PI.refl_shadow) or refl_shadow;
light_screen = lens_s.PI.as_bool(PI.light_screen, light_screen);
blur = tonumber(PI.blur) or blur;
blur_aspect = tonumber(PI.blur_aspect) or blur_aspect;
blur_luma_weight = tonumber(PI.blur_luma_weight) or blur_luma_weight;
noise_intensity = tonumber(PI.noise_intensity) or noise_intensity;
noise_seed = tonumber(PI.noise_seed) or noise_seed;
move_x = tonumber(PI.move_x) or move_x;
noise_size = tonumber(PI.noise_size) or noise_size;
move_y = tonumber(PI.move_y) or move_y;
scale = tonumber(PI.scale) or scale;
rotate = tonumber(PI.rotate) or rotate;
anchor_screen = lens_s.PI.as_bool(PI.anchor_screen, anchor_screen);
back_color = lens_s.PI.color_opt(PI.back_color, back_color);
if PI.chrm_abrr_order then
	local name2num = {
		["RGB"] = 0, ["GBR"] = 1, ["BRG"] = 2,
	};
	chrm_abrr_order = name2num[PI.chrm_abrr_order] or chrm_abrr_order;
end

-- normalize parameters.
mul_luma = math.max(mul_luma / 100, 0);
add_luma = add_luma / 100;
mul_chroma = math.max(mul_chroma / 100, 0);
face_luma = math.max(face_luma / 100, 0);
face_chroma = math.max(face_chroma / 100, 0);
lens_amplify = math.max(lens_amplify, 0);
lens_round = math.max(lens_round, 0);
edge_amplify = edge_amplify * lens_amplify / 100;
edge_round = math.max(edge_round * lens_round / 100, 0);
luma_amplify = luma_amplify * lens_amplify / 100;
luma_round = math.min(math.max(luma_round * lens_round / 200, 0), 1000);
col_amplify = col_amplify * lens_amplify / 100;
col_round = math.max(col_round * lens_round / 100, 0);
col_thresh = math.min(math.max(col_thresh / 100, 0), 1);
smooth = math.min(math.max(lens_round ^ 0.5 * smooth / 100, 0), 1000);
refr_idx = math.max(refr_idx / 100, 1);
chrm_abrr = math.min(math.max(chrm_abrr / 100, -1), 1);
light_angle = 2 * math.pi * ((light_angle / 360) % 1);
refl_power = 1.5 * 128 ^ math.min(math.max(refl_power / 100, 0), 1);
refl_light = math.max(refl_light / 100, 0);
refl_shadow = math.max(refl_shadow / 100, 0);
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
noise_size = math.max(noise_size / 100, 1);
scale = math.min(math.max(scale / 100, 0.01), 100);
rotate = 2 * math.pi * ((rotate / 360) % 1);
chrm_abrr_order = math.min(math.max(math.floor(0.5 + chrm_abrr_order), 0), 2);

--#endregion PI / normalize parameters.

-- pass to core.
lens_s.effect.lens(
	mul_luma, add_luma, mul_chroma, face_luma, face_chroma,
	lift, edge_amplify, edge_round, luma_amplify, luma_round, col_amplify, col_round, col_thresh, smooth,
	refr_idx, chrm_abrr,
	light_angle, refl_power, refl_light, refl_shadow, light_screen,
	blur * math.min(1 + blur_aspect, 1), blur * math.min(1 - blur_aspect, 1), blur_luma_weight,
	noise_intensity, noise_seed, noise_size,
	move_x, move_y, scale, rotate, anchor_screen,
	back_color, chrm_abrr_order,
	visualize_shape);
