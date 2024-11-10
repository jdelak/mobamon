<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	
	
	<node name="Material" type="material" />

	<none name="sourceCoords" type="texcoord"/>
	
	<node name="pan" type="panner">
		

	</node>
	
	
	
	<node name="scrollSpeed" type="float2_material_parameter" param="scrollSpeed"/>
	
	
	<node name="invert" type="one_minus" />	
	<node name="point5" type="float_constant" param="0.3"/>
	
	
	
	<node name="desaturate" type="desaturate"/>
	
	
	
	<link from="scrollSpeed" to="pan.Speed"/>
	
	<link from="pan" to="diffuse.Texcoord" />
	
	<link from="pan" to="normal.Texcoord" />
	
	<link from="diffuse.rgb" to="desaturate"/>
	
	
	
	
	<link from="desaturate.r" to="Material.Opacity" />	
	<link from="diffuse.rgb" to="invert" />		
	
	<link from="invert" to="Material.Diffuse" />
	
	<link from="normal" to="Material.Normal" />
	<link from="normal.a" to="Material.Specular" />
</shader>