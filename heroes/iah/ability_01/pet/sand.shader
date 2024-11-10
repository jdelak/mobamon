<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="opacity" type="sampler_2d" param="opacity" />
	
	<node name="scroll" type="float2_material_parameter" param="vUVScroll" />
	<node name="texcoord" type="panner" />
	<link from="scroll" to="texcoord.Speed" />
	
	<link from="texcoord" to="diffuse" />
	<link from="texcoord" to="normal" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="opacity.a" to="Material.Opacity" />	
	<link from="normal.a" to="Material.Specular" />
</shader>