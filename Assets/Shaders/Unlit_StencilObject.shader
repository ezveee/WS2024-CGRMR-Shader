Shader "Custom/StencilObject"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float3 viewDir : TEXCOORD4; // View direction for lighting calculations
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _SpecIntensity;
            float _SpecPower;

            float4 _LightColor; // color of light in rgb
            float4 _LightPosition; // set position of light

            float _StencilRef;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // Compute view direction (camera space)
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normals = i.normal;
                
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
