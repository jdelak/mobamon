<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="mask" type="sampler_2d" param="mask" />	
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />	
	<node name="diffuse3" type="sampler_2d" param="diffuse3" />	
	
	<node name="color" type="vertex_color" />		
	<node name="Material" type="material" />	
	
	<node name="panner" type="panner" param="0.005 0.0" />
	<link from="panner" to="mask"/>
	
	<node name="panner1" type="panner" param="0.01 0.4" />
	<link from="panner1" to="diffuse2"/>
		
	<node name="panner2" type="panner" param="0.02 0.6" />
	<link from="panner2" to="diffuse3"/>		
		
		
		
		
		
	<node name="multVertColor" type="multiply"/>
	<link from="diffuse3" to="multVertColor.A" />
	<link from="color" to="multVertColor.B" />
	
	
	<node name="multiplyCombine1" type="add"/>
	<link from="diffuse2" to="multiplyCombine1.A" />
	<link from="diffuse3" to="multiplyCombine1.B" />
		
	
		
	<node name="multiplyMask" type="multiply"/>
	<link from="multiplyCombine1" to="multiplyMask.A" />
	<link from="mask" to="multiplyMask.B" />		
		
		
	<node name="multiplyEmissive" type="multiply"/>
	<link from="multiplyMask" to="multiplyEmissive.A" />
	<link from="mask" to="multiplyEmissive.B" />			
	
	<link from="multiplyMask.rgb" to="Material.Diffuse" />
	
</shader>