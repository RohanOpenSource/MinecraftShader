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

uniform sampler2D texture;

uniform float rainStrength;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

void main() {

	vec4 tex = texture2D(texture, texcoord.st);

/* DRAWBUFFERS:0NNN4 */

	vec3 indlmap = mix(pow(min(lmcoord.t+0.1,1.0),2.0),1.0,lmcoord.s)*texture2D(texture,texcoord.xy).rgb*color.rgb;
	gl_FragData[0] = vec4(indlmap,texture2D(texture,texcoord.xy).a*color.a);

	gl_FragDepth = gl_FragCoord.z;

	gl_FragData[4] = vec4(0.0, 1.0, lmcoord.s, 1.0);
}
