#version 120

//------------------------------------
//datLax' OnlyWater v2.0
//
//If you have questions, suggestions or bugs you want to report, please comment on my minecraftforum.net thread:
//http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2381727-shader-pack-datlax-onlywater-only-water
//
//This code is free to use,
//but don't forget to give credits! :)
//------------------------------------

uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D gaux1;

varying vec4 texcoord;

varying vec3 ambient_color;
varying float TimeMidnight;

uniform int worldTime;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

vec3 aux = texture2D(gaux1, texcoord.st).rgb;

float land = aux.b;
float torch_lightmap = aux.b;
float sky_lightmap = aux.g;
float landx = 1.0-step(land, 0.01);
float iswater = 0.0;
float pixeldepth = texture2D(depthtex0,texcoord.xy).x;

float pw = 1.0/ viewWidth;
float ph = 1.0/ viewHeight;


float callwaves(vec2 pos) {
	float wsize = 2.9;
	float wspeed = 0.025f;

	float rs0 = abs(sin((worldTime*wspeed/5.0) + (pos.s*wsize) * 20.0)+0.2);
	float rs1 = abs(sin((worldTime*wspeed/7.0) + (pos.t*wsize) * 27.0));
	float rs2 = abs(sin((worldTime*wspeed/2.0) + (pos.t*wsize) * 60.0 - sin(pos.s*wsize) * 13.0)+0.4);
	float rs3 = abs(sin((worldTime*wspeed/1.0) - (pos.s*wsize) * 20.0 + cos(pos.t*wsize) * 83.0)+0.1);

	float wsize2 = 1.7;
	float wspeed2 = 0.017f;

	float rs0a = abs(sin((worldTime*wspeed2/4.0) + (pos.s*wsize2) * 24.0));
	float rs1a = abs(sin((worldTime*wspeed2/11.0) + (pos.t*wsize2) * 77.0 )+0.3);
	float rs2a = abs(sin((worldTime*wspeed2/6.0) + (pos.s*wsize2) * 50.0 - (pos.t*wsize2) * 23.0)+0.12);
	float rs3a = abs(sin((worldTime*wspeed2/14.0) - (pos.t*wsize2) * 4.0 + (pos.s*wsize2) * 98.0));

	float wsize3 = 0.3;
	float wspeed3 = 0.03f;

	float rs0b = abs(sin((worldTime*wspeed3/4.0) + (pos.s*wsize3) * 14.0));
	float rs1b = abs(sin((worldTime*wspeed3/11.0) + (pos.t*wsize3) * 37.0));
	float rs2b = abs(sin((worldTime*wspeed3/6.0) + (pos.t*wsize3) * 47.0 - cos(pos.s*wsize3) * 33.0 + rs0a + rs0b));
	float rs3b = abs(sin((worldTime*wspeed3/14.0) - (pos.s*wsize3) * 13.0 + sin(pos.t*wsize3) * 98.0 + rs0 + rs1));

	float waves = (rs1 * rs0 + rs2 * rs3)/2.0f;
	float waves2 = (rs0a * rs1a + rs2a * rs3a)/2.0f;
	float waves3 = (rs0b + rs1b + rs2b + rs3b)*0.25;


	return (waves + waves2 + waves3)/3.0f;
}

//----------------MAIN------------------

void main() {

	if(aux.g > 0.01 && aux.g < 0.07) {
		iswater = 1.0;
	}

	vec4 fragposition = gbufferProjectionInverse * vec4(texcoord.s * 2.0f - 1.0f, texcoord.t * 2.0f - 1.0f, 2.0f * pixeldepth - 1.0f, 1.0f);
	fragposition /= fragposition.w;

	float dist = length(fragposition.xyz);
	vec4 worldposition = vec4(0.0);
	worldposition = gbufferModelViewInverse * fragposition;
	vec3 color = texture2D(gcolor, texcoord.st).rgb;
	const float rspread = 0.30f;

	float wave = 0.0;
	if (iswater == 1.0) {
		wave = callwaves(worldposition.xz*0.02)*2.0-1.0;
		wave = wave;

		const float wnormalclamp = 0.05f;

		float rdepth = pixeldepth;
		float waves = wave;
		float wnormal_x1 = texture2D(depthtex0, texcoord.st + vec2(pw, 0.0f)).x - texture2D(depthtex0, texcoord.st).x;
		float wnormal_x2 = texture2D(depthtex0, texcoord.st).x - texture2D(depthtex0, texcoord.st + vec2(-pw, 0.0f)).x;
		float wnormal_x = 0.0f;

		if(abs(wnormal_x1) > abs(wnormal_x2)){
			wnormal_x = wnormal_x2;
		} else {
			wnormal_x = wnormal_x1;
		}

		wnormal_x /= 1.0f - rdepth;
		wnormal_x = clamp(wnormal_x, -wnormalclamp, wnormalclamp);
		wnormal_x *= rspread;

		float wnormal_y1 = texture2D(depthtex0, texcoord.st + vec2(0.0f, ph)).x - texture2D(depthtex0, texcoord.st).x;
		float wnormal_y2 = texture2D(depthtex0, texcoord.st).x - texture2D(depthtex0, texcoord.st + vec2(0.0f, -ph)).x;
		float wnormal_y;

		if(abs(wnormal_y1) > abs(wnormal_y2)){
			wnormal_y = wnormal_y2;
		} else {
			wnormal_y = wnormal_y1;
		}
		wnormal_y /= 1.0f - rdepth;

		wnormal_y = clamp(wnormal_y, -wnormalclamp, wnormalclamp);

		wnormal_y *= rspread;

		//Calculate distance of objects behind water
		float refractdist = 0.2 * 10.0f;

		//Perform refraction
		float refractamount = 500.1154f*0.35f*refractdist;
		float refractamount2 = 0.0214f*0.05f*refractdist;
		float refractamount3 = 0.214f*0.15f*refractdist;
		float waberration = 0.105;

		vec3 refracted = vec3(0.0f);
		float refractedmask = 0.0;
		float bigWaveRefract = 0.0;
		float bigWaveRefractScale = 0.0;

		vec2 bigRefract = vec2(wnormal_x*bigWaveRefract, wnormal_y*bigWaveRefract);

		vec2 refractcoord_r = texcoord.st;
		vec2 refractcoord_g = texcoord.st;
		vec2 refractcoord_b = texcoord.st;

		for (int i = 0; i < 1; ++i) {
			refractcoord_r = texcoord.st * (1.0f + waves*refractamount3) - (waves*refractamount3/2.0f) + vec2( waves*refractamount2 + (-wnormal_x*0.4f) - bigRefract.x,  waves*refractamount2 + (-wnormal_y*0.4f) - bigRefract.y) * (waberration * 2.0f + 1.0f);
			refractcoord_r = refractcoord_r * vec2(1.0f - abs(wnormal_x) * bigWaveRefractScale, 1.0f - abs(wnormal_y) * bigWaveRefractScale) + vec2(abs(wnormal_x) * bigWaveRefractScale * 0.5f, abs(wnormal_y) * bigWaveRefractScale * 0.5f);

			refractcoord_r.s = clamp(refractcoord_r.s, 0.001f, 0.999f);
			refractcoord_r.t = clamp(refractcoord_r.t, 0.001f, 0.999f);

			if (refractcoord_r.s > 1.0 || refractcoord_r.s < 0.0 || refractcoord_r.t > 1.0 || refractcoord_r.t < 0.0) {
				break;
			}

			refracted.rgb = texture2D(gcolor, refractcoord_r).rgb;

			refractedmask = texture2D(gaux1, refractcoord_r).g;
			if(refractedmask > 0.01 && refractedmask < 0.07) {
				refractedmask = 1.0;
			}else refractedmask = 0.0;
		}

		color.rgb = mix(color.rgb, refracted.rgb, vec3(refractedmask));

	}

	wave = wave*0.5+0.5;
	if (iswater > 0.9){
		wave += 0.02;
	}else{
		wave = 0.0;
	}

	if (landx == 1.0) {
		//vec3 torchcolor = vec3(1.0, 0.675, 0.415);
		vec3 torchcolor = vec3(0.8, 0.7, 0.3);
		vec3 torchlight_lightmap = torch_lightmap * torchcolor;

		color = color * torchlight_lightmap * TimeMidnight + color * ambient_color;

	}

	/* DRAWBUFFERS:3 */

	gl_FragData[0] = vec4(color, 1.0);


/* DRAWBUFFERS:NNN3N5 */

    gl_FragData[5] = vec4(0.0, wave, 0.0, 0.0);
	gl_FragData[3] = vec4(color, land);
}
