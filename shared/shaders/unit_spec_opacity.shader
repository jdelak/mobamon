<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="specular" type="sampler_2d" param="specular" />
	<node name="shadowed" type="float_constant" param="1.0" />
	
	<node name="Material" type="material" />	
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="specular.rgb" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />
	<link from="shadowed" to="Material.Shadowed" />
</shader>