<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="diffuse1" type="sampler_2d" param="diffuse1"/>
	<node name="diffuse2" type="sampler_2d" param="diffuse2"/>
	<node name="diffuse3" type="sampler_2d" param="diffuse3"/>
	
	<node name="texcoord0" type="texcoord" param="0"/>	
	<node name="texcoord1" type="texcoord" param="1"/>		
	<node name="texcoord2" type="texcoord" param="1"/>	
	<node name="texcoord3" type="texcoord" param="1"/>	
	
		
	
	<link from="texcoord0" to="diffuse" />
	<link from="texcoord1" to="diffuse1" />	
	<link from="texcoord2" to="diffuse2" />		
	<link from="texcoord3" to="diffuse3" />	

		
	<node name="vertPan" type="panner" param=".2 1"/>
	<link from="vertPan" to="texcoord1"/>	
	
	<node name="vertPan2" type="panner" param="0 -.01"/>
	<link from="vertPan2" to="texcoord0"/>	


	
	<node name="vertPan3" type="panner" param="0 0"/>
	<link from="vertPan3" to="texcoord3"/>	
	
	<node name="vertPan4" type="panner" param="0 -.01"/>
	<link from="vertPan4" to="texcoord2"/>	
	
	<!--	-->
	<node name="diffuseCombine" type="multiply"/>
	<link from="diffuse" to="diffuseCombine.A" />
	<link from="diffuse1" to="diffuseCombine.B" />		
	
	
	<node name="diffuseCombine1" type="multiply"/>
	<link from="diffuse2" to="diffuseCombine1.A" />
	<link from="diffuse3.a" to="diffuseCombine1.B" />	

	<node name="diffuseCombine2" type="add"/>
	<link from="diffuseCombine" to="diffuseCombine2.A" />
	<link from="diffuseCombine1" to="diffuseCombine2.B" />		
	
	
	<node name="fresnel" type="fresnel" param=".4 11 10"/>	
	
	
	<node name="fresnelCombine" type="multiply"/>
	<link from="diffuseCombine2" to="fresnelCombine.A" />
	<link from="fresnel" to="fresnelCombine.B" />		

	
	<node name="vertColor" type="vertex_color"/>
	
	<node name="mult" type="multiply" />
	<link from="vertColor" to="mult.A" />
	<link from="fresnelCombine" to="mult.B" />

	
	<node name="Material" type="material" />
	<link from="mult.rgb" to="Material.Diffuse" />

	
</shader>