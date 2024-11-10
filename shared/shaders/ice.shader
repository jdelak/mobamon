<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />

	<node name="worldBump" type="float3_input" param="WorldBump" />
	<node name="viewBump" type="transform_direction_world_to_view" />
	<link from="worldBump" to="viewBump" />
	
	<node name="sceneRefraction" type="scene_refract" param="500.0 10.0 0.25" />
	<link from="viewBump" to="sceneRefraction" />
	
	<node name="sceneNoSize" type="float2_constant" param="1.0 1.0" />
	<node name="scene0" type="scene_color" />
	<link from="sceneRefraction" to="scene0.Offset" />
	<link from="sceneNoSize" to="scene0.SceneSize" />
	
	<node name="scene2" type="multiply" />
	<link from="scene0.rgb" to="scene2.A" />
	<link from="diffuse.rgb" to="scene2.B" />
	
	<node name="color" type="float4_input" param="vColor" />
	<node name="scene" type="multiply" />
	<link from="scene2.rgb" to="scene.A" />
	<link from="color.rgb" to="scene.B" />
	
	<node name="fresnel" type="fresnel" param="0.05 0.95 3.0" />
	
	<node name="fresnelS" type="one_minus" />
	<link from="fresnel" to="fresnelS" />
	
	<node name="diffuseScaled" type="multiply" />
	<link from="diffuse.rgb" to="diffuseScaled.A" />
	<link from="fresnel" to="diffuseScaled.B" />
	
	<node name="sceneScaled" type="multiply" />
	<link from="scene.rgb" to="sceneScaled.A" />
	<link from="fresnelS" to="sceneScaled.B" />
	
	<node name="Material" type="material" />
	<link from="sceneScaled" to="Material.Emissive" />
	<link from="diffuseScaled" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
</shader>