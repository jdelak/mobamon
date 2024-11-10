<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="image" />
	<node name="color" type="vertex_color" />
	<node name="blend" type="multiply" />
	<node name="grayscale" type="desaturate" param="0.3" />
	<node name="grayscale4" type="append" />
	
	<link from="diffuse.rgb" to="grayscale" />
	<link from="grayscale" to="grayscale4.A" />
	<link from="diffuse.a" to="grayscale4.B" />
	<link from="grayscale4" to="blend.A" />
	<link from="color" to="blend.B" />
	<link from="blend" to="PSOutColor" />
</shader>