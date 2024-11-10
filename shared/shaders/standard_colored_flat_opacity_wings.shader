<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="vertex_color" />
	<node name="panner" type="panner" param="-.5 0" />
	
	<node name="vertColor" type="vertex_color"/>
	<node name="mult" type="multiply" />
	
	<link from="vertColor" to="mult.A" />
	<link from="diffuse" to="mult.B" />
	
	<link from="panner" to="diffuse" />
	
	<node name="Material" type="material" />
	<link from="mult" to="Material.Diffuse" />
	<link from="diffuse.a" to="Material.Opacity" />
	<link from="color" to="Material.ObjectColor" />
	
	
	
</shader>