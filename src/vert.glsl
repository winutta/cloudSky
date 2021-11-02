varying vec3 pos;
uniform float iTime;

void main()
  {
  	pos = position;
  	vec3 offset = vec3(fract(iTime/10./7.)*7.-3.5,0.,0.)*0.; 

    vec4 modelViewPosition = modelViewMatrix * vec4(position + offset,1.0);
    gl_Position = projectionMatrix * modelViewPosition;

  }