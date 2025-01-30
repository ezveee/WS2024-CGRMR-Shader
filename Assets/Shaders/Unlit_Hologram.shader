Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightPosition ("Light Position", Vector) = (0, 10, 0, 0)
        _RimColor("Rim Color", Color) = (0,1,1,1)
        _RimPower("Rim Power", Range(0.5, 10)) = 5.0
        _RimIntensity("Rim Intensity", Range(0.25,25)) = 20
        [IntRange] _StencilRef("Stencil Ref", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Always

        Pass
        {
            Stencil
            {
                Ref [_StencilRef]
                Comp Equal
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float rim = 1 - saturate(dot(i.viewDir, i.normal));
                half4 col = _RimColor * pow(rim,_RimPower) * _RimIntensity;
                col.a = pow(rim,_RimPower);
                return col;
            }
            ENDCG
        }
    }
}
