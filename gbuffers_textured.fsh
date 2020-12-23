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

varying vec4 color;
varying vec4 texcoord;

void main() {
/* DRAWBUFFERS:0NNN4 */


	gl_FragData[0] = texture2D(texture,texcoord.xy)*color;
	gl_FragDepth = gl_FragCoord.z;

	gl_FragData[4] = vec4(0.0, 0.0, 1.0, 0.0);

}
