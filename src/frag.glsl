uniform float iTime;

float random3 (vec3 p3){
    p3  = fract(p3 * 0.3331);
    p3 += dot(p3,p3.yzx + 33.3);
    return fract((p3.x + p3.y) * p3.z);
}

float noise (in vec3 _st) {
    vec3 i = floor(_st);
    vec3 fr = fract(_st);

    // Four corners in 2D of a tile
    float a = random3(i);
    float b = random3(i + vec3(1.0, 0.0, 0.0));
    float c = random3(i + vec3(0.0, 1.0, 0.0));
    float d = random3(i + vec3(1.0, 1.0, 0.0));
    
    float e = random3(i + vec3(0.0, 0.0, 1.0));
    float f = random3(i + vec3(1.0, 0.0, 1.0));
    float g = random3(i + vec3(0.0, 1.0, 1.0));
    float h = random3(i + vec3(1.0, 1.0, 1.0));

    vec3 u = fr * fr * (3.0 - 2.0 * fr);
    
    float bf = mix(a,b,u.x);
    float bb = mix(c,d,u.x);
    
    float bot = mix(bf,bb,u.y);
    
    float tf = mix(e,f,u.x);
    float tb = mix(g,h,u.x);
    
    float top = mix(tf,tb,u.y); 

    return -1.+2.*mix(bot,top,u.z);
}

float ridgeNoise3(vec3 _st, float t){
    //float n = abs(simnoise(_st));

    float n = abs(noise(_st));
    while(n > t){
        n = t - (n - t);
        if(n < 0.) {n = -n;}
    }
    
    return pow(n/t,0.3); // this value is good for tweaking
    
}

float detailScale = 2.;

float map2( in vec3 p )
{

    // p *= 2.5;
	vec3 q = p - vec3(0.0,0.1,1.0)*0.;
    // q*= detailScale;

    q.x += -iTime/1.;
	float f;
    f  = 0.50000*noise( q ); q = q*2.02;
    f += 0.25000*noise( q );
	//return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
    // return f;
    //return clamp(0.5 - max(abs(p.y*1.+1.)-1.,0.) + 1.2*f, 0.0, 1.0 );
    // return clamp(0.5 - max(length(p.xyz)-1.,0.) + 2.2*f, 0.0, 1.0 );
    // float circle = smoothstep(0.5*detailScale,0.45*detailScale,length(p));
    // return clamp(20.2*f,0.,1.)*circle;
    // return clamp(0.5 - max(length(p.xyz)-1.,0.) + 2.2*f, 0.0, 1.0 );
    return clamp(0.5 - max(length(p.xyz*vec3(0.5,1.2,1.2))-1.,0.) + 2.2*f, 0.0, 1.0 );
}

float map3( in vec3 p )
{
    // p *= 2.5;
    vec3 q = p - vec3(0.0,0.1,1.0)*0.;
    // q*= detailScale;
    q.x += iTime;
    float f;
    f  = 0.50000*noise( q ); q = q*2.02;
    f += 0.25000*noise( q ); q = q*2.03;
    f += 0.12500*noise( q ); 
    //return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
    return f;
    //return clamp(0.5 - max(abs(p.y*1.+1.)-1.,0.) + 1.2*f, 0.0, 1.0 );
    // return clamp(0.5 - max(length(p.xyz)-1.,0.) + 2.2*f, 0.0, 1.0 );
    // float circle = smoothstep(0.5*detailScale,0.45*detailScale,length(p));
    // return clamp(20.2*f,0.,1.)*circle;
    // return clamp(0.5 - max(length(p.xyz*vec3(0.5,1.2,1.2))-1.,0.) + 2.2*f, 0.0, 1.0 );
}

float fbmN(vec3 _st, int n){
    float v = 0.;
    for (int i = 0;i<4;i++){
        if(i>=n) break;
        v= map2(_st + v*0.5);
    }
    // return clamp(0.5 - max(length(_st.xyz*vec3(0.5,1.2,1.2))-1.,0.) + 2.2*v, 0.0, 1.0 );
    return v;
}



vec3 sundir = normalize( vec3(1.0,0.0,1.0) );

vec4 rayMarch(vec3 ro, vec3 rd, float startT){

	float t = startT;
    // float travel = 0.;
	vec4 sum = vec4(0.);
	vec3 pos = ro + t*rd;

	for(int i = 0; i<80; i++){
		pos = ro + t*rd;
        float outX = 1.-step(2.001,abs(pos.x));
        float outY = 1.-step(1.001,abs(pos.y));
        float outZ = 1.-step(1.001,abs(pos.z));
        float oob = outX*outY*outZ;
        pos.zyx *= 2.;
        // pos*= detailScale;
		if((sum.a > 0.99) || (oob == 0.)) break;
		float den = map2(pos);
		if(den > 0.05){
            float dif = clamp((den - map2(pos+0.3*sundir))/0.6, 0.0, 1.0 );
            vec3  lin = vec3(0.65,0.7,0.75)*1.4 + vec3(0.) + vec3(1.0,0.6,0.3)*dif*1.;
			vec4 col = vec4( mix( vec3(1.0,0.95,0.8)*1., vec3(0.25,0.3,0.35)*1., den ), den );
            col.xyz *= lin;
            // col.xyz += 0.15;



            vec3 bgcol = vec3(0.,0.,0.8);

            // col.xyz = mix(col.xyz,bgcol, 1.0-exp2(-0.075*t));
            col.a *= 0.4;
			col.rgb *= col.a;
			sum += col*(1.-sum.a);
		}
		// t += max(0.05/2.,0.05*(t-startT));
        t+= 0.05;
	}

    // for(int i = 0; i<40; i++){
    //     pos = ro + t*rd;
    //     float outX = 1.-step(2.001,abs(pos.x));
    //     float outY = 1.-step(1.001,abs(pos.y));
    //     float outZ = 1.-step(1.001,abs(pos.z));
    //     float oob = outX*outY*outZ;
    //     // pos*= detailScale;
    //     pos.zyx *= 2.;
    //     if((sum.a > 0.99) || (oob == 0.)) break;
    //     float den = map2(pos);
    //     if(den > 0.01){
    //         float dif = clamp((den - map2(pos+0.3*sundir))/0.6, 0.0, 1.0 );
    //         vec3  lin = vec3(0.65,0.7,0.75)*1.4 + vec3(1.0,0.6,0.3)*dif;
    //         vec4 col = vec4( mix( vec3(1.0,0.95,0.8), vec3(0.25,0.3,0.35), den ), den );
    //         col.xyz *= lin;
    //         vec3 bgcol = vec3(0.,0.,0.8);

    //         // col.xyz = mix(col.xyz,bgcol, 1.0-exp2(-0.075*t));
    //         col.a *= 0.4;
    //         col.rgb *= col.a;
    //         sum += col*(1.-sum.a);
    //     }
    //     t += max(0.05/2.,0.04*(t-startT));
    //     // t+= 0.05;
    // }


	return clamp(sum,0.,1.);
}





varying vec3 pos;

void main() {
    
	vec3 col = vec3(0.5);
	col = pos;

	vec3 rd = (pos - cameraPosition);
	float startT = length(rd);
	rd = normalize(rd);
	vec4 density = rayMarch(cameraPosition,rd,startT);

	// float circle = 1.-smoothstep(0.6,0.7,length(pos));

	col = vec3(density.xyz);



    gl_FragColor = vec4(col,pow(density.w,8.));
  }