<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Emissive" />
	<link from="diffuse.a" to="Material.Opacity" />
	

	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="Material.ObjectColor" to="emissive.B" />

	<link from="emissive" to="Material.Emissive"/>	
</shader>