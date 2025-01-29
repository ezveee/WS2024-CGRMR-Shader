Shader "Custom/BumpMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal", 2D) = "white" {}
        _NormalIntensity ("Intensity", Range(0,5)) = 1
        _SpecIntensity ("Spec Intensity" , Range(0, 50)) = 1
        _SpecPower ("Spec Power" , Range(1, 50)) = 1
        _LightColor ("Light Color", Color) = (1, 1, 1, 1) // white light as default
        _LightPosition ("Light Position", Vector) = (0, 5, 0, 0) // Default light position
        _StencilRef("Stencil Ref", Range(0, 10)) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Stencil
            {
                Ref [_StencilRef]
                Comp NotEqual
                Pass Keep
            //Makes brickwall see through with stencil!!!
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 viewDir : TEXCOORD4; // View direction for lighting calculations
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            float _NormalIntensity;
            float _SpecIntensity;
            float _SpecPower;

            float4 _LightColor; // color of light in rgb
            float4 _LightPosition; // set position of light

            float _StencilRef;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.tangent, o.normal); 

                // Compute view direction (camera space)
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float normalIntensity = _NormalIntensity/30;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normals = i.normal;

                float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                normals = normalMap.r * i.tangent * normalIntensity + 
                          normalMap.g * i.bitangent * normalIntensity + 
                          normalMap.b * i.normal; //Intensity wouldnt change anything if applied to all 3
                normals = normalize(normals);
                
                float3 lightDir = normalize(_LightPosition.xyz - i.vertex.xyz); // calc direction of light

                //Phong
                float3 reflex = reflect(lightDir, normals);
                float3 phongSpec = pow(max(0, dot(reflex, -i.viewDir)), _SpecPower) * _SpecIntensity; //reflection * viewdirection ^ shiny factor (with adapted intensity)

                //Blinn
                float3 h = normalize(lightDir + i.viewDir); //h vector, normal of view dir and light dir
                float3 blinnSpec = pow(max(0, dot(normals, h)), _SpecPower) * _SpecIntensity; //normal * (normal to view and light dir) ^shiny factor (with adapted intensity)
                
                //Lambert
                float3 diffuse = max(0.0, dot(normals, lightDir)); // calculate diffuse lighting (can only be positive!!!)
                
                float3 finalLighting = (phongSpec + blinnSpec + diffuse) * _LightColor; //Apply light color instead of unity _LightColor0
                
                float3 finalColor = col * finalLighting;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}
