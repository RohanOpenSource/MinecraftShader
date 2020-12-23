#version 120

varying vec4 texcoord;
varying vec4 texture;

void main() {
	gl_Position = ftransform();


	texcoord = gl_MultiTexCoord0;
	texture = gl_MultiTexCoord0;
}
