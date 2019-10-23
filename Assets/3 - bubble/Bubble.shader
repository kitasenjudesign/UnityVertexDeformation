Shader "custom/Bubble" 
  {
    Properties 
    {
      _MainTex ("Texture", 2D) = "white" {}
      _Cube ("Cubemap", CUBE) = "" {}
      _AlphaCubemap ("Alpha Cubemap", CUBE) = "" {}

      _Scale ("Scale", Range(0.1, 15.0)) = 3.0
      _Bias ("Bias", Range(-5, 5.0)) = 3.0
      _Power ("Power", Range(0.1, 15.0)) = 3.0

      _Mult ("Mult", Range(0,1)) = 1.0
    }
    SubShader 
    {    
      Tags 
      {
        "Queue"="Transparent" 
        "RenderType"="Transparent" 
      }

      CGPROGRAM
      #pragma surface surf Standard fullforwardshadows alpha:fade

      struct Input 
      {
          float2 uv_MainTex;
          float3 worldRefl;
          float3 viewDir;
      };
            
      sampler2D _MainTex;
      samplerCUBE _Cube;
      samplerCUBE _AlphaCubemap;

      float _Bias;
      float _Power;
      float _Scale;
      float _Mult;

      float randomNum(in float2 uv)
		  {
     		float2 noise = (frac(sin(dot(uv, float2(12.9898,78.233)*2.0)) * 43758.5453));
     		return abs(noise.x + noise.y) * 0.1;
      }


      void surf (Input IN, inout SurfaceOutputStandard o) 
      {
        float3 cubeSample = texCUBE (_Cube, IN.worldRefl);
        float3 alphaSample = texCUBE (_AlphaCubemap, IN.worldRefl);
        float3 textureSample = tex2D(_MainTex, IN.uv_MainTex);
        
        float fresnelTerm = _Scale * o.Normal + _Bias; //- _Bias;
        float refl2Refr = 1 - fresnelTerm - .3;
        //o.Alpha = 1 - (pow(alphaSample, _Power) + refl2Refr);

        alphaSample = pow (alphaSample, _Power);

        o.Albedo = lerp (cubeSample, cubeSample * textureSample, 1 - alphaSample); //Makes it brighter
        o.Emission = lerp (cubeSample, cubeSample * textureSample, 1 - alphaSample);
        o.Alpha = 1 - dot(IN.viewDir, o.Normal);
        //o.Alpha = lerp(_Mult, 1.0, refl2Refr + alphaSample);
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }
  