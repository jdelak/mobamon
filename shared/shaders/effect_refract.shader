<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	<node name="refractionScale" type="float_input" param="Param" />
	
	<node name="refraction" type="sampler_2d" param="refraction" />
	<node name="refractionScaled" type="scale_bias" param="2.0 -1.0" />
	<link from="refraction.xy" to="refractionScaled" />
	
	<node name="refractionScaled2" type="multiply" />
	<link from="refractionScaled" to="refractionScaled2.A" />
	<link from="refractionScale" to="refractionScaled2.B" />
	
	<node name="scene" type="scene_color" />
	<link from="refractionScaled2" to="scene" />
	
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="scene.rgb" to="emissive.A" />
	<link from="color.rgb" to="emissive.B" />
	
	<node name="opacity" type="multiply" />
	<link from="color.a" to="opacity.A" />
	<link from="refraction.a" to="opacity.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="opacity" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>