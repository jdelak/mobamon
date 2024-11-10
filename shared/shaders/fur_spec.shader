<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="furPS" type="fur_ps" />
	<node name="specular" type="float3_constant" param="1 1 1" />
	<node name="diffuse" type="fur_sampler_2d">
		<parameter name="diffuse0" value="diffuse0" />
		<parameter name="diffuse1" value="diffuse1" />
	</node>
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="specular" to="Material.Specular" />
	
	<node name="Phong" type="phong_fur" />
	<node name="Deffer" type="deffer_fur" />
</shader>