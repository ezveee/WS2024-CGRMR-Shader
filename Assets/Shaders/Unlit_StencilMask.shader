Shader "Custom/StencilMask"
{
    Properties
    {
        [IntRange] _StencilID("Stencil ID", Range(0, 10)) = 1 
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry-1" }

        Pass
        {
            ColorMask 0
            ZWrite Off

            Stencil
            {
                Ref [_StencilID]
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _StencilID;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(0,0,0,0);
            }
            ENDCG
        }
    }
}
