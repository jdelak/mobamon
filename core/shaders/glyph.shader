<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="white" type="float3_constant" param="1.0 1.0 1.0" />
	<node name="diffuse" type="sampler_2d_alpha" param="image" />
	<node name="append" type="append" />
	<link from="white" to="append.A" />
	<link from="diffuse" to="append.B" />
	<link from="append" to="PSOutColor" />
</shader>
