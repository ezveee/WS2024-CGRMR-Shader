Shader "Custom/StencilMask"
{
    Properties
    {
        _StencilRef("Stencil Ref", Range(0, 10)) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry -1" /*Start shader early in rendering phase*/ }

        Pass
        {
            ColorMask 0 //Dont write any colot to screen
            ZWrite Off //Dont write depth information

            Stencil
            {
                Ref [_StencilRef]
                Comp Always //Every pixel is accepted
                Pass Replace //Value 1 written in stencil buffer for every pixel of object (use with other stencil shaders)
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

            float _StencilRef;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(0,0,0,0); //returns color 0
            }
            /*Stencil {
                    Ref 1
                    Comp Equal
                } dann sieht man was durch DIESES window
                */
            ENDCG
        }
    }
}
