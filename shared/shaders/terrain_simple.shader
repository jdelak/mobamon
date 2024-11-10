<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="selfOcclusionScaleBias" type="float2_constant" param="5.0 -1.0" />

	<node name="texcoord0" type="texcoord" param="0" />
	<node name="texcoord1" type="texcoord" param="1" />
	
	<node name="color" type="sampler_2d" param="color" />
	<link from="texcoord1" to="color" />

	<node name="diffuse0" type="sampler_2d" param="diffuse0" />
	<link from="texcoord0" to="diffuse0" />
		
	<node name="diffuse" type="multiply" />
	<link from="diffuse0.rgb" to="diffuse.A" />
	<link from="color.rgb" to="diffuse.B" />
	
	<node name="normalmap0" type="sampler_normalmap_nx" param="normalmap0" />
	<link from="texcoord0" to="normalmap0" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="normalmap0.rgb" to="Material.Normal" />
	<link from="normalmap0.a" to="Material.Specular" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="disable" to="Material.GroundAmbient" />
	<link from="selfOcclusionScaleBias" to="Material.SelfOcclusionScaleBias" />
	<link from="disable" to="Material.NormalizeNormal" />
</shader>