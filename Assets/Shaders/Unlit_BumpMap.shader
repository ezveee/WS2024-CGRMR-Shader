Shader "Custom/BumpMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightPosition ("Light Position", Vector) = (0, 10, 0, 0)
        _NormalMap ("Normal", 2D) = "white" {}
        _NormalIntensity ("Intensity", Range(0, 10)) = 1
        [IntRange] _StencilID("Stencil ID", Range(0, 10)) = 1 // if i remove this line, you can only see the walls through the "windows"
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            Stencil
            {
                Ref [_StencilID]
                Comp NotEqual
                Pass Keep
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            float _NormalIntensity;
            float4 _LightColor;
            float4 _LightPosition;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.tangent, o.normal); 
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float normalIntensity = _NormalIntensity / 30;
                
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normals = i.normal;

                float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                normals = normalMap.r * i.tangent * normalIntensity + 
                          normalMap.g * i.bitangent * normalIntensity + 
                          normalMap.b * i.normal;
                normals = normalize(normals);

                float3 lightDir = normalize(_LightPosition.xyz - i.vertex.xyz);
                float ambient = 0.2;
                float3 diffuse = max(0.0, dot(normals, lightDir)) + ambient;
                diffuse = saturate(diffuse);

                float3 finalLighting = diffuse * _LightColor;
                float3 finalColor = col * finalLighting;
                
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
