<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />	
	
	<node name="texcoord0" type="texcoord" param="0"/>	
	<link from="texcoord0" to="vertPan" />
		
	<node name="vertPan" type="panner" param="-5 01.03"/>
	<link from="vertPan" to="diffuse"/>
	
	
	<node name="fresnel" type="fresnel" param="0 11 4"/>	
	<node name="fresnel2" type="fresnel" param="0 11 7"/>	
	
	
	
	<node name="fresnelCombine" type="multiply"/>
	<link from="diffuse" to="fresnelCombine.A" />
	<link from="fresnel" to="fresnelCombine.B" />		

	<node name="fresnelCombine2" type="add"/>
	<link from="fresnelCombine" to="fresnelCombine2.A" />
	<link from="fresnel2" to="fresnelCombine2.B" />
	
	<node name="Material" type="material" />
	<link from="fresnelCombine2.rgb" to="Material.Diffuse" />	
</shader>