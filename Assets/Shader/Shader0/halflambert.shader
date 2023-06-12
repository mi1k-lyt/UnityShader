Shader "MyShader/halflambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags {"LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v) {
                v2f o;
                
                // 变换顶点
                o.pos = UnityObjectToClipPos(v.vertex);
                // 变换法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 记录世界空间的顶点
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                // 获得环境光颜色
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 获得世界空间法线(这里经过硬件，已经完成插值)
                fixed3 worldNormal = normalize(i.worldNormal);
                // 获得世界空间下光源方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                // 计算diffuse项,这里使用half_lambert
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5*dot(worldNormal, worldLightDir)+0.5);
                // 计算diffuse项,这里使用lambert
                fixed3 _diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                // 获得世界空间的观察方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // 获得half_Vector
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // 计算specular项
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed3 color = ambient + _diffuse + specular;

                return fixed4(color, 1);

            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
