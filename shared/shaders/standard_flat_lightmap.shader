<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="lightmap.rgb" to="Material.Light" />
</shader>