<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="vertex_color" />	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Emissive" />
	<node name="fresnel" type="fresnel" param="-0.0 2 5"/>	
	
	<node name="invertFresnel" type="one_minus" />
	<link from="fresnel" to="invertFresnel" />	
	
	<node name="horzPanner" type="panner" param="-3 0.0" />
	<link from="horzPanner" to="diffuse"/>		
	
	
	<node name="multFresnel" type="multiply"/>
	<link from="invertFresnel" to="multFresnel.A" />
	<link from="color" to="multFresnel.B" />	

	<node name="multVertColor" type="multiply"/>
	<link from="multFresnel" to="multVertColor.A" />
	<link from="Material.ObjectColor" to="multVertColor.B" />
	
	
	
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="multVertColor" to="emissive.B" />	
	
	
	
	<link from="emissive" to="Material.Emissive"/>
</shader>