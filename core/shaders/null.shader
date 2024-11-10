<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="float3_input" param="ErrorDiffuse" />
	<node name="emissive" type="float3_input" param="ErrorEmissive" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="emissive" to="Material.Emissive" />
</shader>