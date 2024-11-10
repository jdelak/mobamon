<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	
	<node name="i" type="float3_input" param="WorldPositionOffset" />
	<node name="n" type="float3_input" param="WorldBump" />
	
	<node name="reflect" type="reflect" />
	<link from="i" to="reflect.I" />
	<link from="n" to="reflect.N" />
	
	<node name="reflectParam" type="float_input" param="fReflect" />
	<node name="fresnel0" type="fresnel" param="1.0 0.0 0.0" />
	
	<node name="fresnel" type="multiply" />
	<link from="reflectParam" to="fresnel.A" />
	<link from="fresnel0" to="fresnel.B" />
	
	<node name="reflectStrength" type="multiply" />
	<link from="fresnel" to="reflectStrength.A" />
	<link from="diffuse.a" to="reflectStrength.B" />
	
	<node name="diffuseStrength" type="one_minus" />
	<link from="reflectStrength" to="diffuseStrength" />
	
	<node name="enviro" type="sampler_cube" param="cube" />	
	<link from="reflect" to="enviro.Texcoord" />
	
	<node name="enviroColor" type="float3_constant" param="1.0. 1.0 1.0" />
	<node name="enviroBlend" type="multiply" />	
	<link from="enviro.rgb" to="enviroBlend.A" />
	<link from="enviroColor" to="enviroBlend.B" />
	
	<node name="diffuseScale" type="multiply" />
	<link from="diffuse.rgb" to="diffuseScale.A" />
	<link from="diffuseStrength" to="diffuseScale.B" />
	
	<node name="specularScale" type="multiply" />
	<link from="normal.a" to="specularScale.A" />
	<link from="diffuseStrength" to="specularScale.B" />
	
	<node name="enviroScale" type="multiply" />
	<link from="enviroBlend" to="enviroScale.A" />
	<link from="reflectStrength" to="enviroScale.B" />
	
	<node name="Material" type="material" />
	<link from="enviroScale" to="Material.Emissive" />
	<link from="diffuseScale" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="specularScale" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />
</shader>