<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="zero" type="float_constant" param="0.0" />

	<node name="diffuse" type="sampler_cube" param="skybox" />
	<node name="color" type="float4_input" param="MaterialObjectColor" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="zero" to="Material.Fog" />
	<link from="zero" to="Material.Fogofwar" />
</shader>