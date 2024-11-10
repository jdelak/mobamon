<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="furPS" type="fur_ps" />
	<node name="specular" type="float3_constant" param="1 1 1" />
	<node name="diffuse" type="fur_sampler_2d">
		<parameter name="diffuse0" value="diffuse0" />
		<parameter name="diffuse1" value="diffuse1" />
	</node>
	
	<node name="fresnel" type="fresnel" param=".01 5 5" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="specular" to="Material.Specular" />

	<node name="vColorOverride" type="float4_constant" param=".15 .3 .3 1" />
	
	<node name="mult" type="multiply" />
	<link from="fresnel" to="mult.A" />
	<link from="vColorOverride" to="mult.B" />

	<node name="multAgain" type="multiply" />
	<link from="mult" to="multAgain.A" />
	<link from="Material.Shadowed" to="multAgain.B" />

	<link from="multAgain" to="Material.Emissive" />
	
	<node name="Phong" type="phong_fur" />
	<node name="Deffer" type="deffer_fur" />
</shader>