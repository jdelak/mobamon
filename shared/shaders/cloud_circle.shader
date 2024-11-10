<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="vertex_color" />
	<node name="panner" type="panner" param=".25 .5" />
	
	<node name="vertColor" type="vertex_color"/>
	<node name="add" type="add" />
	<node name="mult" type="multiply" />
	
	<link from="vertColor" to="mult.A" />
	<link from="diffuse.a" to="mult.B" />

	<link from="panner" to="diffuse" />
	
	<node name="Material" type="material" />
	<link from="diffuse" to="Material.Diffuse" />
	<link from="mult.r" to="Material.Opacity" />
	<link from="diffuse" to="Material.ObjectColor" />
	<link from="diffuse" to="Material.Emissive" />

</shader>
