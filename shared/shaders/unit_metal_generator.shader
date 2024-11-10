<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="unshadowed" type="float_constant" param="1.0" />
	<node name="normalize" type="bool_constant" param="true" />

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="specular" type="sampler_2d" param="specular" />
	
	<node name="i" type="float3_input" param="WorldPositionOffset" />
	<node name="n" type="float3_input" param="WorldBump" />
	
	<node name="reflect" type="reflect" />
	<link from="i" to="reflect.I" />
	<link from="n" to="reflect.N" />
	
	<node name="fresnelParams" type="float3_constant" param="-.8 4 .2" />
	<node name="fresnel0" type="fresnel" />
	<link from="fresnelParams" to="fresnel0.FresnelParams" />
	
	<node name="reflectParam" type="float_input" param="fReflect" />
	<node name="fresnel" type="multiply" />
	<link from="reflectParam" to="fresnel.A" />
	<link from="fresnel0" to="fresnel.B" />
	
	<node name="reflectStrength" type="multiply" />
	<link from="fresnel" to="reflectStrength.A" />
	<link from="specular.a" to="reflectStrength.B" />
	
	<node name="diffuseStrength" type="one_minus" />
	<link from="reflectStrength" to="diffuseStrength" />
	
	<node name="enviro" type="sampler_cube" param="cube" />	
	<link from="reflect" to="enviro.Texcoord" />
	
	<node name="enviroColor" type="float3_constant" param="1.4 1.35 1.3"/>
	<node name="enviroBlend" type="multiply" />	
	<link from="enviro.rgb" to="enviroBlend.A" />
	<link from="enviroColor" to="enviroBlend.B" />

	<node name="diffuseScale" type="multiply" />
	<link from="diffuse.rgb" to="diffuseScale.A" />
	<link from="diffuseStrength" to="diffuseScale.B" />
	
	<node name="enviroScale" type="multiply" />
	<link from="enviroBlend" to="enviroScale.A" />
	<link from="reflectStrength" to="enviroScale.B" />
	
	<node name="Material" type="material" />
	<link from="enviroScale" to="Material.Emissive" />
	<link from="diffuseScale" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="specular.rgb" to="Material.Specular" />
	<link from="teamColor" to="Material.ObjectColor.Color" />
	<link from="unshadowed" to="Material.Shadowed" />
	<link from="normalize" to="Material.NormalizeNormal" />
</shader>