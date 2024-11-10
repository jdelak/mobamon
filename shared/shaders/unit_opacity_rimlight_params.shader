<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />


	<node name="fresnelColor" type="float4_material_parameter" param="vFresnelColor" />
	<node name="fresnelParams" type="float3_material_parameter" param="vFresnelScale" />
	
	
	<node name="fresnelNew" type="fresnel" />
	<link from="fresnelParams" to="fresnelNew.FresnelParams" />
	


	
	<node name="mult" type="multiply" />
	<link from="fresnelNew" to="mult.A" />
	<link from="fresnelColor" to="mult.B" />
	
	
	
	

	<node name="multAgain" type="multiply" />
	<link from="mult" to="multAgain.A" />
	<link from="Material.Shadowed" to="multAgain.B" />
	



	
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="multAgain" to="Material.Emissive" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />
	
	

</shader>