<?xml version="1.0" encoding="UTF-8"?>
<shader>
	

	
	




	
	
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	<node name="half" type="float_constant" param="0.5" />
	<node name="rot" type="rotator" param="0.5" />

	<node name="diffuseRed" type="sampler_2d" param="diffuse" />
	
	<link from="rot" to="diffuseRed"/>
	
	<node name="emissive" type="multiply" />
	<link from="diffuseRed" to="emissive.A" />

	
	<node name="emissive2" type="subtract" />
	<link from="emissive.rgb" to="emissive2.A" />
	<link from="half" to="emissive2.B" />

	<node name="emissive3" type="multiply" />
	<link from="emissive2" to="emissive3.A" />


	<node name="emissive4" type="add" />
	<link from="emissive3" to="emissive4.A" />
	<link from="half" to="emissive4.B" />

	<node name="Material" type="material"/>

	<link from="emissive4.rgb" to="Material.Emissive"/>
	<link from="emissive.rgba" to="Material.Opacity" />
	
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />


</shader>



<!--
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="sun" type="float3_input" param="vSunColor" />
	<node name="ambient" type="float3_input" param="vAmbient" />
	<node name="light" type="add" />
	<link from="sun" to="light.A" />
	<link from="ambient" to="light.B" />
	
	<node name="emissive2" type="multiply" />
	<link from="emissive.rgb" to="emissive2.A" />
	<link from="light" to="emissive2.B" />
	
	<node name="Material" type="material" />
	<link from="emissive2.rgb" to="Material.Emissive" />
	<link from="emissive.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>
-->