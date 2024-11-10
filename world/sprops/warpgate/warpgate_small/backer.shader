<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="mask" type="sampler_2d" param="mask" />	
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />	

	
	<node name="color" type="vertex_color" />		
	<node name="Material" type="material" />	
	
	<node name="panner" type="panner" param="0.005 0.0" />
	<link from="panner" to="mask"/>
	
	<node name="panner1" type="panner" param="0.01 0.1" />
	<link from="panner1" to="diffuse2"/>
		
	
		
			
		
	<node name="multiplyMask" type="multiply"/>
	<link from="diffuse2" to="multiplyMask.A" />
	<link from="mask" to="multiplyMask.B" />		
		
	
	<link from="multiplyMask.rgb" to="Material.Diffuse" />
	<link from="multiplyMask.rgb" to="Material.Emissive" />
	
</shader>