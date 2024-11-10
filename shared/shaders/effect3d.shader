<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	<node name="texcoord3d" type="append" />
	<node name="texcoord0" type="float2_input" param="Texcoord0" />
	<node name="frame" type="float_input" param="Frame" />
	<link from="texcoord0" to="texcoord3d.A" />
	<link from="frame" to="texcoord3d.B" />

	<node name="diffuse" type="sampler_3d" param="diffuse" />
	<link from="texcoord3d" to="diffuse" />
	
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="emissive.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>