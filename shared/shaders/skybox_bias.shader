<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="zero" type="float_constant" param="0.0" />
	<node name="alphaLeak" type="float_material_parameter" param="fAlphaLeak" />

	<node name="diffuse" type="sampler_cube" param="skybox" />
	<node name="color" type="float4_input" param="MaterialObjectColor" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="alpha0" type="one_minus" />
	<link from="alphaLeak" to="alpha0" />
	
	<node name="alpha1" type="multiply" />
	<link from="alpha0" to="alpha1.A" />
	<link from="color.a" to="alpha1.B" />
	
	<node name="alpha2" type="add" />
	<link from="alpha1" to="alpha2.A" />
	<link from="alphaLeak" to="alpha2.B" />
	
	<node name="alpha" type="saturate" />
	<link from="alpha2" to="alpha" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="alpha" to="Material.Opacity" />
	<link from="zero" to="Material.Fog" />
	<link from="zero" to="Material.Fogofwar" />
</shader>