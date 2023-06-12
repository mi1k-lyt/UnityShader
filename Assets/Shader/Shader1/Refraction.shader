Shader "MyShader/Refraction"
{
    Properties
    {
        _ColorTint ("Color Tint", Color) = (1,1,1,1)
        _RefractColor ("Refract Color", Color) = (1,1,1,1)
        _RefractAmount ("Refract Amount", Range(0, 1)) = 1
        _RefractRatio ("Refract Ratio", Range(0.1, 1)) = 0.5
        _CubeMap ("Cube Map", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            Tags {"LihgtMode" = "ForwardBase"}

            CGPROGRAM

            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _ColorTint;
            fixed4 _RefractColor;
            float _RefractAmount;
            float _RefractRatio;
            samplerCUBE _CubeMap;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefrDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

                o.worldRefrDir = refract(normalize(-o.worldViewDir), normalize(o.worldNormal), _RefractRatio);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _ColorTint.rgb * max(0, dot(worldNormal, worldLightDir));

                fixed3 refraction = texCUBE(_CubeMap, i.worldRefrDir).rgb * _RefractColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) ;//* atten;

                return fixed4(color, 1.0);
            }


            ENDCG
        }
    }
}
