<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="source" type="source_object_position" />
	<node name="target" type="target_object_position" />
	
	<node name="sourceNormal" type="source_object_normal" />
	<node name="color" type="float4_input" param="vColor" />
	
	<node name="offset0" type="multiply" />
	<link from="sourceNormal" to="offset0.A" />
	<link from="color.a" to="offset0.B" />
	
	<node name="offsetPosition" type="add" />
	<link from="source" to="offsetPosition.A" />
	<link from="offset0" to="offsetPosition.B" />
	
	<link from="offsetPosition" to="target" />
	
	<node name="one" type="float_constant" param="1.0" />
	<node name="texRotate" type="float_material_parameter" param="fTexRotate" />
	<node name="texOffset" type="float2_constant" param="0.0 0.0" />
	
	<node name="texcoord0" type="2denviro" />
	<node name="texcoord1" type="rotator" />
	<node name="texcoord2" type="panner" />
	<link from="texRotate" to="texcoord1.Speed" />
	<link from="one" to="texcoord1.Time" />
	<link from="texOffset" to="texcoord2.Speed" />
	<link from="one" to="texcoord2.Time" />
	
	<link from="texcoord0" to="texcoord1" />
	<link from="texcoord1" to="texcoord2" />
	
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<link from="texcoord2" to="diffuse" />
	
	<node name="finalColor" type="multiply" />
	<link from="diffuse.rgb" to="finalColor.A" />
	<link from="color.rgb" to="finalColor.B" />
	
	<node name="Material" type="material" />
	<link from="finalColor.rgb" to="Material.Emissive" />
	<link from="diffuse.a" to="Material.Opacity" />
</shader>