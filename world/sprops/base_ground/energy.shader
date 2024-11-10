<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />	
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />	
	<node name="diffuse3" type="sampler_2d" param="diffuse3" />	
	
	
	<node name="color" type="vertex_color" />		
	<node name="Material" type="material" />	
	
	
	<node name="vertPanner" type="panner" param="0 -0.04" />
	<link from="vertPanner" to="diffuse"/>
		
	<node name="horzPanner" type="panner" param=".1 -0.12" />
	<link from="horzPanner" to="diffuse2"/>	
	
	<node name="vertPanner2" type="panner" param="-.1 -0.3" />
	<link from="vertPanner2" to="diffuse3"/>	
	

	

	<node name="diffuseCombine" type="multiply"/>
	<link from="diffuse" to="diffuseCombine.A" />
	<link from="diffuse2" to="diffuseCombine.B" />	

	<node name="diffuseCombine2" type="multiply"/>
	<link from="diffuseCombine" to="diffuseCombine2.A" />
	<link from="diffuse3" to="diffuseCombine2.B" />	
	
		
	
	
	
	<node name="multVertColor" type="multiply"/>
	<link from="diffuseCombine2" to="multVertColor.A" />
	<link from="color" to="multVertColor.B" />
	
	
	
		
	
	<link from="multVertColor.rgb" to="Material.Diffuse" />
	<link from="multVertColor.rgb" to="Material.Emissive" />
</shader>