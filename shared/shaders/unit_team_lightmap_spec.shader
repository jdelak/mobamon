<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="specular" type="sampler_2d" param="specular" />
	<node name="team" type="sampler_2d" param="team" />
	<node name="lightmap" type="sampler_2d" param="lightmap" />
	<node name="shadowed" type="float_constant" param="1.0" />
	
	<node name="teamColor" type="object_color_team" />
	<link from="team.a" to="teamColor.TeamMask" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	<link from="normal" to="Material.Normal" />
	<link from="specular.rgb" to="Material.Specular" />
	<link from="teamColor" to="Material.ObjectColor.Color" />
	<link from="lightmap.rgb" to="Material.Light" />
	<link from="shadowed" to="Material.Shadowed" />
</shader>