<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="zero" type="float_constant" param="0" />
	<node name="one" type="float_constant" param="1" />
	
	<node name="fresnel" type="fresnel" param=".2 1 2" />
	


	<node name="vColorOverride" type="float4_constant" param=".2 .2 .25 1" />
	
	<node name="mult" type="add" />
	<link from="fresnel" to="mult.A" />
	<link from="vColorOverride" to="mult.B" />

	<node name="multAgain" type="multiply" />
	<link from="mult" to="multAgain.A" />
	<link from="Material.Shadowed" to="multAgain.B" />

	
	
	<node name="Material" type="material" />

	<link from="normal" to="Material.Normal" />
	<link from="multAgain.a" to="Material.Opacity" />
	<link from="multAgain.rgb" to="Material.Emissive" />

</shader>