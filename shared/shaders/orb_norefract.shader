<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="one" type="float_constant" param="1.0" />
	<node name="noShadows" type="float_constant" param="1.0" />
	<node name="noGroundAmbient" type="bool_constant" param="false" />
	
	<node name="texcoord0" type="texcoord" param="0" />
	<node name="texcoord1" type="texcoord" param="1" />
	
	<node name="Tex0a" type="float2_material_parameter" param="vTex0a" />
    <node name="Tex0b" type="float2_material_parameter" param="vTex0b" />
	<node name="Tex1a" type="float2_material_parameter" param="vTex1a" />
    <node name="Tex1b" type="float2_material_parameter" param="vTex1b" />
	
	<node name="texcoordA" type="add" />
	<link from="texcoord0" to="texcoordA.A" />
	<link from="Tex0a" to="texcoordA.B" />
	
	<node name="texcoordB" type="add" />
	<link from="texcoord0" to="texcoordB.A" />
	<link from="Tex0b" to="texcoordB.B" />
	
	<node name="texcoordC" type="add" />
	<link from="texcoord1" to="texcoordC.A" />
	<link from="Tex1a" to="texcoordC.B" />
	
	<node name="texcoordD" type="add" />
	<link from="texcoord1" to="texcoordD.A" />
	<link from="Tex1b" to="texcoordD.B" />
	
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal1" type="sampler_normalmap_rxgb" param="normalmap1" />
	<node name="normal2" type="sampler_normalmap_rxgb" param="normalmap2" />
	<node name="normal3" type="sampler_normalmap_rxgb" param="normalmap3" />
	
	<link from="texcoordC" to="diffuse" />
	<link from="texcoordA" to="normal1" />
	<link from="texcoordB" to="normal2" />
	<link from="texcoordC" to="normal3" />
	
	<node name="normal12" type="add" />
	<link from="normal1.rgb" to="normal12.A" />
	<link from="normal2.rgb" to="normal12.B" />
	
	<node name="normal123" type="add" />
	<link from="normal12.rgb" to="normal123.A" />
	<link from="normal3.rgb" to="normal123.B" />
	
	<node name="normal" type="normalize" />
	<link from="normal123" to="normal" />

	<node name="worldBump" type="float3_input" param="WorldBump" />
	<node name="viewBump" type="transform_direction_world_to_view" />
	<link from="worldBump" to="viewBump" />
	
	<node name="sceneRefraction" type="scene_refract" param="200.0 80.0 0.25" />
	<link from="viewBump" to="sceneRefraction" />
	
	<node name="color" type="float4_input" param="vColor" />
	<node name="scene" type="multiply" />
	<link from="diffuse.rgb" to="scene.A" />
	<link from="color.rgb" to="scene.B" />
	
	<node name="fresnel" type="fresnel" param="0.2 0.8 7.0" />
	
	<node name="fresnelS" type="one_minus" />
	<link from="fresnel" to="fresnelS" />
	
	<node name="opacity" type="multiply" />
	<link from="diffuse.a" to="opacity.A" />
	<link from="fresnel" to="opacity.B" />
	
	<node name="Material" type="material" />
	<link from="scene" to="Material.Diffuse" />
	<link from="opacity" to="Material.Opacity" />
	<link from="normal" to="Material.Normal" />
	<link from="one" to="Material.Specular" />
	<link from="noShadows" to="Material.Shadowed" />
	<link from="noGroundAmbient" to="Material.GroundAmbient" />
	
</shader>