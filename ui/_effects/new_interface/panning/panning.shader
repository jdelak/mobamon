<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	
	<node name="scroll" type="float2_material_parameter" param="vUVScroll" />
	<node name="texcoord" type="panner" />
	<link from="scroll" to="texcoord.Speed" />
	<node name="vertColor" type="vertex_color"/>
	
	<node name="mult" type="multiply" />
	
	<link from="vertColor" to="mult.A" />
	<link from="diffuse.a" to="mult.B" />
	
	<link from="texcoord" to="diffuse" />
	<link from="texcoord" to="normal" />
	
	
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="mult.r" to="Material.Opacity" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	
</shader>

<!--
	<node name="mult" type="multiply" />
	
	<link from="vertColor" to="mult.A" />
	<link from="diffuse.a" to="mult.B" />

	<link from="panner" to="diffuse" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="mult" to="Material.Opacity" />
	<link from="diffuse" to="Material.ObjectColor" />
	<link from="diffuse" to="Material.Emissive" />
-->
