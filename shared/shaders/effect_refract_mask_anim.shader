<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="disable" type="bool_constant" param="false" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	<node name="refractionScale" type="float_input" param="Param" />
	
	<node name="mask" type="sampler_2d" param="mask" />
	
	<node name="texcoord1" type="texcoord" />
	<node name="texOffset" type="float2_material_parameter" param="vTexOffset" />
	<node name="texcoordOffset" type="add" />
	<link from="texcoord1" to="texcoordOffset.A" />
	<link from="texOffset" to="texcoordOffset.B" />
	
	<node name="refraction" type="sampler_2d" param="refraction" />
	<link from="texcoordOffset" to="refraction" />
	
	<node name="refractionMasked" type="multiply" />
	<link from="refractionScaled4" to="refractionMasked.A" />
	<link from="mask" to="refractionMasked.B" />
	
	<node name="refractionScaled" type="scale_bias" param="2.0 -1.0" />
	<link from="refraction.xy" to="refractionScaled" />
	
	<node name="refractionScaled4" type="append" />
	<link from="refractionScaled2" to="refractionScaled4.A" />
	<link from="refraction.zw" to="refractionScaled4.B" />
	
	<node name="refractionScaled2" type="multiply" />
	<link from="refractionScaled" to="refractionScaled2.A" />
	<link from="refractionScale" to="refractionScaled2.B" />
	
	<node name="scene" type="scene_color" />
	<link from="refractionMasked.xy" to="scene" />
	
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="scene" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="color.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>