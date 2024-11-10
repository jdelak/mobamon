<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />	
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />	
	<node name="diffuse3" type="sampler_2d" param="diffuse3" />	
	
	
	<node name="color" type="vertex_color" />		
	<node name="Material" type="material" />	
	
	
	<node name="vertPanner" type="panner" param="0 -0.1" />
	<link from="vertPanner" to="diffuse"/>
		
	<node name="horzPanner" type="panner" param=".1 -0.0" />
	<link from="horzPanner" to="diffuse2"/>	
	
	<node name="vertPanner2" type="panner" param="-.1 -0.2" />
	<link from="vertPanner2" to="diffuse3"/>	
	
	<node name="fresnel" type="fresnel" param="-0.0 2 5"/>	
	

	<node name="diffuseCombine" type="multiply"/>
	<link from="diffuse" to="diffuseCombine.A" />
	<link from="diffuse2" to="diffuseCombine.B" />	

	<node name="diffuseCombine2" type="multiply"/>
	<link from="diffuseCombine" to="diffuseCombine2.A" />
	<link from="diffuse3" to="diffuseCombine2.B" />	
	
		
	
	<node name="invertFresnel" type="one_minus" />
	<link from="fresnel" to="invertFresnel" />	
	
	<node name="multVertColor" type="multiply"/>
	<link from="diffuseCombine2" to="multVertColor.A" />
	<link from="color" to="multVertColor.B" />
	
	
	<node name="multFresnel" type="multiply"/>
	<link from="invertFresnel" to="multFresnel.A" />
	<link from="multVertColor" to="multFresnel.B" />		
		
	
	<link from="multFresnel.rgb" to="Material.Diffuse" />
	<link from="multFresnel.rgb" to="Material.Emissive" />
</shader>