<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	
	<node name="shadowed" type="float_constant" param="1.0" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="diffuse.a" to="Material.Opacity" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="lightmap.rgb" to="Material.Light" />
	<link from="shadowed" to="Material.Shadowed" />
</shader>