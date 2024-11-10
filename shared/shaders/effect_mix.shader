<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<node name="diffuse0" type="sampler_2d" param="diffuse0" />
	<node name="diffuse1" type="sampler_2d" param="diffuse1" />
	<node name="frame0" type="float_input" param="Frame" />
	
	<node name="frame" type="saturate" />
	<link from="frame0" to="frame" />
	
	<node name="diffuse" type="lerp" />
	<link from="diffuse0" to="diffuse.A" />
	<link from="diffuse1" to="diffuse.B" />
	<link from="frame" to="diffuse.S" />
	
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