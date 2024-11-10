<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	
	<node name="diffuse" type="sampler_3d" param="diffuse" />
	<node name="texcoord3d" type="append" />
	<node name="texcoord0" type="float2_input" param="Texcoord0" />
	<node name="frame" type="float_input" param="Frame" />
	<link from="texcoord0" to="texcoord3d.A" />
	<link from="frame" to="texcoord3d.B" />
	<link from="texcoord3d" to="diffuse" />


	<node name="lightmap" type="sampler_2d" param="lightmap" />
	


	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />

	<node name="light" type="add" />
	<link from="lightmap" to="light.A" />
	<link from="emissive" to="light.B" />
	

	<node name="Material" type="material" />
	<link from="light.rgb" to="Material.Emissive" />
	<link from="emissive.a" to="Material.Opacity" />
	<link from="lightmap" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />

	
</shader>