<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	<node name="blur" type="sampler_2d" param="blur" />
	<node name="scene" type="sampler_2d_ref" param="scene" />
	
	<node name="param" type="float_input" param="Param" />
	
	<node name="sceneTexcoord" type="scene_texcoord" />
	<node name="sceneTexelSize" type="float2_input" param="vTexelSize" />
	
	<node name="blurVector0" type="scale_bias" param="2.0 -1.0" />
	<link from="blur.xy" to="blurVector0" />
	
	<node name="blurVector" type="multiply" />
	<link from="blurVector0" to="blurVector.A" />
	<link from="param" to="blurVector.B" />
	
	<node name="sceneBlur" type="directional_blur" />
	<link from="scene" to="sceneBlur.Sampler" />
	<link from="sceneTexcoord" to="sceneBlur.Texcoord" />
	<link from="sceneTexelSize" to="sceneBlur.TexelSize" />
	<link from="blurVector" to="sceneBlur.Blur" />
	
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="sceneBlur" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="blur.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>