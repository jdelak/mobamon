<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	
	<node name="Texcoord1" type="texcoord" param="1" />
	<link from="Texcoord1" to="lightmap" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="lightmap.rgb" to="Material.Light" />
</shader>