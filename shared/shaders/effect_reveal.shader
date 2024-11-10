<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="reveal" type="sampler_2d" param="reveal" />
	
	<node name="frame" type="float_input" param="Frame" />
	
	<node name="reveal0" type="subtract" />
	<link from="reveal.a" to="reveal0.A" />
	<link from="frame" to="reveal0.B" />
	
	<node name="reveal1" type="scale_bias" param="255.0 0.0" />
	<link from="reveal0" to="reveal1" />
	
	<node name="reveal2" type="saturate" />
	<link from="reveal1" to="reveal2" />
		
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="emissive2" type="multiply" />
	<link from="emissive" to="emissive2.A" />
	<link from="reveal2" to="emissive2.B" />
	
	<node name="Material" type="material" />
	<link from="emissive2.rgb" to="Material.Emissive" />
	<link from="emissive2.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>