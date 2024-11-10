<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />	
	<node name="diffuse2" type="sampler_2d" param="diffuse2" />	
	<node name="diffuse3" type="sampler_2d" param="diffuse3" />	
	
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	
	<node name="color" type="vertex_color" />		

	<node name="vertPanner" type="panner" param="0 0.1" />
	<link from="vertPanner" to="diffuse"/>
		
	<node name="vertPannerNormal" type="panner" param="0 0.17" />
	<link from="vertPannerNormal" to="normal"/>
	
	<node name="vertPannerWhite" type="panner" param="0 0.131" />
	<link from="vertPannerWhite" to="diffuse2"/>
	

	<node name="whiteWater" type="multiply"/>
	<link from="diffuse2" to="whiteWater.A" />
	<link from="diffuse2.a" to="whiteWater.B" />
	
	
	<node name="addWhite" type="add"/>
	<link from="diffuse" to="addWhite.A" />
	<link from="whiteWater" to="addWhite.B" />
			
	
	<node name="multVertColor2" type="multiply"/>
	<link from="multVertColor" to="multVertColor2.A" />
	<link from="color" to="multVertColor2.B" />		
	
	
	
	<node name="Material" type="material" />
	<link from="emissive" to="Material.Emissive" />	
	<link from="addWhite" to="Material.Diffuse" />
	<link from="color.r" to="Material.Opacity" />
	<link from="normal" to="Material.Normal" />
	<link from="diffuse.a" to="Material.Specular" />
	
</shader>
