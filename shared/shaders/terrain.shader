<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="selfOcclusionScaleBias" type="float2_constant" param="5.0 -1.0" />

	<node name="texcoord0" type="texcoord" param="0" />
	<node name="texcoord1" type="texcoord" param="1" />
	
	<node name="alpha" type="sampler_2d" param="alpha" />
	<node name="color" type="sampler_2d" param="color" />
	<link from="texcoord1" to="alpha" />
	<link from="texcoord1" to="color" />

	<node name="diffuse0" type="sampler_2d" param="diffuse0" />
	<node name="diffuse1" type="sampler_2d" param="diffuse1" />
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />
	<link from="texcoord0" to="diffuse0" />
	<link from="texcoord0" to="diffuse1" />
	<link from="texcoord0" to="diffuse1" />
	
	<node name="alpha0" type="multiply" />
	<link from="alpha.r" to="alpha0.A" />
	<link from="diffuse1.a" to="alpha0.B" />
	
	<node name="alpha1" type="multiply" />
	<link from="alpha.g" to="alpha1.A" />
	<link from="diffuse2.a" to="alpha1.B" />
	
	<node name="diffuseBlend0" type="lerp" />
	<link from="diffuse0.rgb" to="diffuseBlend0.A" />
	<link from="diffuse1.rgb" to="diffuseBlend0.B" />
	<link from="alpha0.r" to="diffuseBlend0.S" />
	
	<node name="diffuseBlend1" type="lerp" />
	<link from="diffuseBlend0" to="diffuseBlend1.A" />
	<link from="diffuse2.rgb" to="diffuseBlend1.B" />
	<link from="alpha1.r" to="diffuseBlend1.S" />
	
	<node name="diffuse" type="multiply" />
	<link from="diffuseBlend1" to="diffuse.A" />
	<link from="color.rgb" to="diffuse.B" />
	
	<node name="normalmap0" type="sampler_terrain_normalmap" param="normalmap0" />
	<node name="normalmap1" type="sampler_terrain_normalmap" param="normalmap1" />
	<node name="normalmap2" type="sampler_terrain_normalmap" param="normalmap2" />
	<link from="texcoord0" to="normalmap0" />
	<link from="texcoord0" to="normalmap1" />
	<link from="texcoord0" to="normalmap2" />
	
	<node name="normalmapBlend0" type="lerp" />
	<link from="normalmap0.rgb" to="normalmapBlend0.A" />
	<link from="normalmap1.rgb" to="normalmapBlend0.B" />
	<link from="alpha0.r" to="normalmapBlend0.S" />
	
	<node name="normalmap" type="lerp" />
	<link from="normalmapBlend0" to="normalmap.A" />
	<link from="normalmap2.rgb" to="normalmap.B" />
	<link from="alpha1.r" to="normalmap.S" />
	
	<node name="specularBlend0" type="lerp" />
	<link from="normalmap0.a" to="specularBlend0.A" />
	<link from="normalmap1.a" to="specularBlend0.B" />
	<link from="alpha0.r" to="specularBlend0.S" />
	
	<node name="specular" type="lerp" />
	<link from="specularBlend0" to="specular.A" />
	<link from="normalmap2.a" to="specular.B" />
	<link from="alpha1.r" to="specular.S" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="normalmap" to="Material.Normal" />
	<link from="specular" to="Material.Specular" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="disable" to="Material.GroundAmbient" />
	<link from="selfOcclusionScaleBias" to="Material.SelfOcclusionScaleBias" />
	<link from="disable" to="Material.NormalizeNormal" />
</shader>