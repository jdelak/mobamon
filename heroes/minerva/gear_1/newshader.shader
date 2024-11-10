<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />


	<node name="Pos" type="float3_input" param="ObjectPosition" />
	<node name="ModConstant" type="float_constant" param="0.0025" />
	<node name="Mod" type="multiply"/>
	<link from="Pos.y" to="Mod.A" />
	<link from="ModConstant" to="Mod.B" />

	<node name="SinBase" type="float_constant" param="1" />
	<node name="Frequency" type="float_constant" param="4" />
	<node name="Sin" type="sin" />
	<link from="Frequency" to="Sin.Frequency" />
	<link from="Mod" to="Sin.Phase" />
	<link from="SinBase" to="Sin.Amplitude" />

	<node name="RangeMap" type="rangemap" param="-1 1 0.75 2.25" />
	<link from="Sin" to="RangeMap.Value" />

	<node name="Mult" type="multiply" />
	<link from="lightmap.rgb" to="Mult.A" />
	<link from="RangeMap" to="Mult.B" />

	<link from="Mult.rgb" to="Material.Emissive" /> 
	
</shader>