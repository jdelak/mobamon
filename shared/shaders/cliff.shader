<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="selfOcclusionScaleBias" type="float2_constant" param="5.0 -1.0" />
	
	<node name="texcoordBase" type="texcoord" param="0" />
	<node name="terrainTexcoord0" type="float2_input" param="TerrainTexcoord0" />
	<node name="terrainTexcoord1" type="float2_input" param="TerrainTexcoord1" />
	
	<node name="diffuseBase" type="sampler_2d" param="diffuse" />
	<node name="normalBase" type="sampler_normalmap_rxgb" param="normalmap" />
	<link from="texcoordBase" to="diffuseBase" />
	<link from="texcoordBase" to="normalBase" />
	
	<node name="alpha" type="sampler_2d" param="alpha" />
	<node name="color" type="sampler_2d" param="color" />
	<link from="terrainTexcoord1" to="alpha" />
	<link from="terrainTexcoord1" to="color" />

	<node name="diffuse0" type="sampler_2d" param="terrain_diffuse0" />
	<node name="diffuse1" type="sampler_2d" param="terrain_diffuse1" />
	<node name="diffuse2" type="sampler_2d" param="terrain_diffuse2" />
	<link from="terrainTexcoord0" to="diffuse0" />
	<link from="terrainTexcoord0" to="diffuse1" />
	<link from="terrainTexcoord0" to="diffuse2" />
	
	<node name="alpha0" type="multiply" />
	<link from="alpha.r" to="alpha0.A" />
	<link from="diffuse1.a" to="alpha0.B" />
	
	<!--
	<node name="alpha1" type="multiply" />
	<link from="alpha.g" to="alpha1.A" />
	<link from="diffuse2.a" to="alpha1.B" />
	-->
	<node name="alpha1" type="float_constant" param="0.0" />
	
	<node name="diffuseBlend0" type="lerp" />
	<link from="diffuse0.rgb" to="diffuseBlend0.A" />
	<link from="diffuse1.rgb" to="diffuseBlend0.B" />
	<link from="alpha0" to="diffuseBlend0.S" />
	
	<node name="diffuseBlend1" type="lerp" />
	<link from="diffuseBlend0" to="diffuseBlend1.A" />
	<link from="diffuse2.rgb" to="diffuseBlend1.B" />
	<link from="alpha1" to="diffuseBlend1.S" />
	
	<node name="diffuseBlend2" type="multiply" />
	<link from="diffuseBlend1" to="diffuseBlend2.A" />
	<link from="color.rgb" to="diffuseBlend2.B" />
	
	<node name="diffuse" type="lerp" />
	<link from="diffuseBlend2" to="diffuse.A" />
	<link from="diffuseBase.rgb" to="diffuse.B" />
	<link from="diffuseBase.a" to="diffuse.S" />
	
	<node name="normalmap0" type="sampler_terrain_normalmap" param="terrain_normalmap0" />
	<node name="normalmap1" type="sampler_terrain_normalmap" param="terrain_normalmap1" />
	<node name="normalmap2" type="sampler_terrain_normalmap" param="terrain_normalmap2" />
	<link from="terrainTexcoord0" to="normalmap0" />
	<link from="terrainTexcoord0" to="normalmap1" />
	<link from="terrainTexcoord0" to="normalmap2" />
	
	<node name="normalmapBlend0" type="lerp" />
	<link from="normalmap0.rgb" to="normalmapBlend0.A" />
	<link from="normalmap1.rgb" to="normalmapBlend0.B" />
	<link from="alpha0" to="normalmapBlend0.S" />
	
	<node name="normalmapBlend1" type="lerp" />
	<link from="normalmapBlend0" to="normalmapBlend1.A" />
	<link from="normalmap2.rgb" to="normalmapBlend1.B" />
	<link from="alpha1" to="normalmapBlend1.S" />
	
	<node name="specularBlend0" type="lerp" />
	<link from="normalmap0.a" to="specularBlend0.A" />
	<link from="normalmap1.a" to="specularBlend0.B" />
	<link from="alpha0" to="specularBlend0.S" />
	
	<node name="specularBlend1" type="lerp" />
	<link from="specularBlend0" to="specularBlend1.A" />
	<link from="normalmap2.a" to="specularBlend1.B" />
	<link from="alpha1" to="specularBlend1.S" />
	
	<node name="specular" type="lerp" />
	<link from="specularBlend1" to="specular.A" />
	<link from="normalBase.a" to="specular.B" />
	<link from="diffuseBase.a" to="specular.S" />
	
	<node name="cliffBlendNormals" type="cliff_material_world_bump" priority="2" />
	<link from="normalBase.rgb" to="cliffBlendNormals.Normal" />
	<link from="normalmapBlend1" to="cliffBlendNormals.TerrainNormal" />
	<link from="diffuseBase.a" to="cliffBlendNormals.Blend" />
	
	<node name="cliffBlendNormals2" type="cliff_material_view_bump" priority="2" />
	<link from="normalBase.rgb" to="cliffBlendNormals2.Normal" />
	<link from="normalmapBlend1" to="cliffBlendNormals2.TerrainNormal" />
	<link from="diffuseBase.a" to="cliffBlendNormals2.Blend" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="specular" to="Material.Specular" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="disable" to="Material.GroundAmbient" />
	<link from="selfOcclusionScaleBias" to="Material.SelfOcclusionScaleBias" />
</shader>