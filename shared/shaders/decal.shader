<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="disable" type="bool_constant" param="false" />
	<node name="selfOcclusionScaleBias" type="float2_constant" param="5.0 -1.0" />

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="diffuse.a" to="Material.Opacity" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="disable" to="Material.GroundAmbient" />
	<link from="selfOcclusionScaleBias" to="Material.SelfOcclusionScaleBias" />
</shader>