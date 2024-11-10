<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="zero" type="float_constant" param="0" />
	<node name="one" type="float_constant" param="1" />
	
	<node name="fresnel" type="fresnel" param=".02 13 5" />	
	<node name="Material" type="material" />
	
	
	<node name="invertFresnel" type="one_minus" />	
	<link from="fresnel" to="invertFresnel" />
	
	<node name="vColorOverride" type="float4_constant" param="0 .2 .2 0" />	
	
	
	<node name="edgeColor" type="add" />	
	<link from="invertFresnel" to="edgeColor.A" />
	<link from="vColorOverride" to="edgeColor.B" />
	

	
	<node name="lerp" type="lerp" />
	<link from="vColorOverride" to="lerp.A" />
	<link from="diffuse" to="lerp.B" />	
	<link from="invertFresnel" to="lerp.S" />	
	
	<node name="multAgain" type="multiply" />
	<link from="lerp" to="multAgain.A" />
	<link from="Material.Shadowed" to="multAgain.B" />

	
	<link from="multAgain.rgb" to="Material.Diffuse" />
	<link from="normal.rgb" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />


</shader>