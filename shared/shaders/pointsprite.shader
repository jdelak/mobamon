<?xml version="1.0" encoding="UTF-8"?>
<shader psize="true">
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="sprite_vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuse" to="emissive.A" />
	<link from="color" to="emissive.B" />

	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="emissive.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
</shader>