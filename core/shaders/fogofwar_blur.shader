<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d_ref" param="image" />
	<node name="color" type="vertex_color" />
	<node name="blend" type="multiply" />
	<node name="blur" type="blur" />
	<node name="swizzle" type="alpha_texture_swizzle" />
	<link from="diffuse" to="blur" />
	<link from="blur" to="swizzle" /> 
	<link from="swizzle" to="blend.A" />
	<link from="color" to="blend.B" />
	<link from="blend" to="PSOutColor" />
</shader>
