<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="zero" type="float_constant" param="0" />
	<node name="one" type="float_constant" param="1" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	<node name="fresnel" type="fresnel" param=".2 5 5" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />

	<node name="vColorOverride" type="float4_constant" param=".2 .2 0 1" />
	
	<node name="mult" type="multiply" />
	<link from="fresnel" to="mult.A" />
	<link from="vColorOverride" to="mult.B" />

	<node name="multAgain" type="multiply" />
	<link from="mult" to="multAgain.A" />
	<link from="Material.Shadowed" to="multAgain.B" />

	<link from="multAgain" to="Material.Emissive" />
	<link from="lightmap.rgb" to="Material.Light" />
</shader>