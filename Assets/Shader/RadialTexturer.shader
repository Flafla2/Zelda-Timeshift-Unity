Shader "Custom/Radial Texturer" {
	Properties {
		_DiffuseFar ("Diffuse (Far)", 2D) = "white" {} // Far textures are outside of the orb's sphere of influence
		_NormalFar ("Normal (Far)", 2D) = "bump" {}
		_SpecFar ("Specular (Far)", 2D) = "black" {}
		_DiffuseNear ("Diffuse (Near)", 2D) = "black" {} // Near textures are inside of the orb's sphere of influence
		_NormalNear ("Normal (Near)",2D) = "bump" {}
		_SpecNear ("Specular (Near)",2D) = "black" {}
		
		_Specularity ("Specularity", Float) = 1.0 // 
		
		_BorderColor ("Border Color", Color) = (1,1,1,1)
		_BorderWidth ("Border Width", Float) = 0.1
		_LightPos ("Texturer Position", Vector) = (0,0,0,0)
		_LightRad ("Texturer Radius", Float) = 1.0
		[MaterialToggle] _Cylindrical ("Cylindrical (Ignore Y axis)", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf ColoredSpecular

		sampler2D _DiffuseFar;
		sampler2D _NormalFar;
		sampler2D _SpecFar;
		sampler2D _DiffuseNear;
		sampler2D _NormalNear;
		sampler2D _SpecNear;
		
		float _LightRad;
		float _BorderWidth;
		float _Cylindrical;
		half _Specularity;
		float4 _LightPos;
		fixed4 _BorderColor;
		
		struct CustomSurfaceOutput {
		    half3 Albedo;
		    half3 Normal;
		    half3 Emission;
		    half Specular;
		    half3 GlossColor;
		    half Alpha;
		};
		
		struct Input {
			float2 uv_DiffuseFar;
			float2 uv_DiffuseNear;
			float3 worldPos;
		};
		 
		// Custom lighting is required to 
		inline half4 LightingColoredSpecular (CustomSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
		  half3 h = normalize (lightDir + viewDir);
		 
		  half diff = max (0, dot (s.Normal, lightDir));
		 
		  float nh = max (0, dot (s.Normal, h));
		  float spec = pow (nh, _Specularity)*s.Specular;
		  half3 specCol = spec * s.GlossColor;
		 
		  half4 c;
		  c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * specCol) * (atten * 2);
		  c.a = s.Alpha;
		  return c;
		}
		 
		inline half4 LightingColoredSpecular_PrePass (CustomSurfaceOutput s, half4 light)
		{
		    half3 spec = light.a * s.GlossColor;
		   
		    half4 c;
		    c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
		    c.a = s.Alpha + spec * _SpecColor.a;
		    return c;
		}

		void surf (Input IN, inout CustomSurfaceOutput o) {
			float3 d = (float3)_LightPos-IN.worldPos;
			// Using Distance Squared eliminates the need for a costly square root calculation
			float distSq = d.x*d.x + d.z*d.z + (1.0f-_Cylindrical)*d.y*d.y;
			float farDistSq = _LightRad+_BorderWidth/2; farDistSq *= farDistSq;
			float nearDistSq = _LightRad-_BorderWidth/2; nearDistSq *= nearDistSq;
			
			float alpha = saturate((distSq-nearDistSq)/(farDistSq-nearDistSq));
			float border_alpha = (int)abs(alpha*2-1);
			half4 c_f = tex2D (_DiffuseFar, IN.uv_DiffuseFar);
			half4 c_n = tex2D (_DiffuseNear, IN.uv_DiffuseNear);
			half4 s_f = tex2D(_SpecFar,IN.uv_DiffuseFar);
			half4 s_n = tex2D(_SpecNear,IN.uv_DiffuseNear);
			o.Albedo = lerp(fixed3(0,0,0),lerp(c_n.rgb,c_f.rgb,alpha),border_alpha);;
			o.Alpha = lerp(c_n.a,c_f.a,alpha);
			o.GlossColor = lerp(s_n.rgb,s_f.rgb,alpha);
			o.Specular = lerp(s_n.a,s_f.a,alpha);
			
			o.Emission = lerp((fixed3)_BorderColor,fixed3(0,0,0),border_alpha);
		}
		ENDCG
	} 
	FallBack "Diffuse"
}