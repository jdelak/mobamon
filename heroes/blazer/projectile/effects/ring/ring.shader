<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />

	<node name="fresnel" type="fresnel" param="2.2 -3 0.75"/>	

	<node name="fresnelCombine" type="multiply"/>
	<link from="diffuse" to="fresnelCombine.A" />
	<link from="fresnel" to="fresnelCombine.B" />		

	<node name="Material" type="material" />
	<link from="fresnelCombine.rgb" to="Material.Diffuse" />	
</shader>