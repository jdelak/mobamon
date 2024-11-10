<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="image" />
	<node name="grayscale" type="desaturate" />
	<link from="diffuse.rgb" to="grayscale" />
	<node name="append" type="append" />
	<link from="grayscale" to="append.A" />
	<link from="diffuse.a" to="append.B" />
	<link from="append" to="PSOutColor" />
</shader>