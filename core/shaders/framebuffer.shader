<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="framebuffer" />
	<node name="opacity" type="float_constant" param="1.0" />
	
	<node name="gamma" type="gamma" />
	<link from="diffuse.rgb" to="gamma.Color" />
	
	<node name="append" type="append" />
	<link from="gamma" to="append.A" />
	<link from="opacity" to="append.B" />
	
	<link from="append" to="PSOutColor" />
</shader>
