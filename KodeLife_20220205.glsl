#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;
uniform sampler2D prevPass;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;

mat2 rot(float a)
{
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float sdBox(vec3 p,vec3 s)
{
    vec3 d=abs(p)-s;
    return length(max(d,0.))+min(max(max(d.y,d.z),d.x),0.);
}

float sdCircle(vec2 p,float r)
{
    return length(p)-r;
}

float sdSphere(vec3 p,float r)
{
    return length(p)-r;
}

float sdTorus(vec3 p)
{
    return length(vec2(length(p.xy)-.3,p.z))-.1;
}


vec3 rep(vec3 p,float n)
{
    return abs(mod(p,n))-n*.5;
}

float map(vec3 p)
{
    //p=rep(p,2.);
    p.xy*=rot(time);
    p.xz*=rot(time);
    float sdf2d=sdCircle(p.xy,.5);
    return sdCircle(vec2(sdf2d,p.z),.1);
}

vec3 makeN(vec3 p)
{
    vec2 eps=vec2(.001,0.);
    return normalize(vec3(map(p+eps.xyy)-map(p-eps.xyy),
                          map(p+eps.yxy)-map(p-eps.yxy),
                          map(p+eps.yyx)-map(p-eps.yyx)));
}

void main(void)
{
    vec2 uv = (gl_FragCoord.xy*2.-resolution)/resolution.y;
    float dist,hit,i=0.;
    vec3 ro=vec3(0.,0.,5.),
         rd=normalize(vec3(uv,-1.)),
         rp=ro+rd*dist,
         L=normalize(vec3(1.)),
         col=vec3(0.);
    for(;i<128;i++)
    {
        dist=map(rp);
        hit+=dist;
        rp=ro+rd*hit;
        if(dist<.001)
        {
            vec3 N=makeN(rp);
            float diff=dot(N,L);
            col=vec3(1.)*diff;
        }
    }
    fragColor = vec4(col,1.);
}