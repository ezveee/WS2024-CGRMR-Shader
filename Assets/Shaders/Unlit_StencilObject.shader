Shader "Custom/StencilObject"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightPosition ("Light Position", Vector) = (0, 10, 0, 0)
        [FloatRange] _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.2
        [IntRange] _StencilID("Stencil ID", Range(0, 10)) = 1 
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Stencil
            {
                Ref [_StencilID]
                Comp Equal
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _LightColor;
            float4 _LightPosition;
            float _AmbientStrength;

            float _StencilID;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normals = i.normal;
                
                float3 lightDir = normalize(_LightPosition.xyz - i.vertex.xyz);
                float diffuse = max(0.0, dot(normals, lightDir));
                diffuse = lerp(_AmbientStrength, 1.0, diffuse);

                float3 finalLighting = diffuse * _LightColor;

                float3 finalColor = col * finalLighting;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
