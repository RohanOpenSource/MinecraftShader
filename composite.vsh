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

varying vec4 texcoord;

varying float TimeMidnight;
varying float TimeSunset;
varying float TimeNoon;
varying float TimeSunrise;

varying vec3 ambient_color;

uniform int worldTime;

void main() {
	gl_Position = ftransform();

	texcoord = gl_MultiTexCoord0;

	float timefract = float(worldTime);
	 TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0-(clamp(timefract, 0.0, 6000.0)/6000.0));
	 TimeNoon     = ((clamp(timefract, 0.0, 6000.0)) / 6000.0) - ((clamp(timefract, 6000.0, 12000.0) - 6000.0) / 6000.0);
	 TimeSunset   = ((clamp(timefract, 6000.0, 12000.0) - 6000.0) / 6000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
	 TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

	vec3 sunrise_amb;
	 sunrise_amb.r = TimeSunrise;
	 sunrise_amb.g = TimeSunrise;
	 sunrise_amb.b = TimeSunrise;

	vec3 noon_amb;
	 noon_amb.r = TimeNoon;
	 noon_amb.g = TimeNoon;
	 noon_amb.b = TimeNoon;

	vec3 sunset_amb;
	 sunset_amb.r = 0.95*TimeSunset;
	 sunset_amb.g = 0.95*TimeSunset;
	 sunset_amb.b = 0.95*TimeSunset;

	vec3 midnight_amb;
	 midnight_amb.r =  0.45*TimeMidnight;
	 midnight_amb.g =  0.45*TimeMidnight;
	 midnight_amb.b =  0.7*TimeMidnight;

	ambient_color.r = sunrise_amb.r + noon_amb.r + sunset_amb.r + midnight_amb.r;
	ambient_color.g = sunrise_amb.g + noon_amb.g + sunset_amb.g + midnight_amb.g;
	ambient_color.b = sunrise_amb.b + noon_amb.b + sunset_amb.b + midnight_amb.b;
}
