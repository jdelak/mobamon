<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal" type="sampler_normalmap_rxgb" param="normalmap" />
	<node name="specular" type="sampler_2d" param="specular" />
	<node name="team" type="sampler_2d" param="team" />

	<node name="shadowed" type="float_constant" param="1.0" />

	<node name="diffuseAdditional" type="sampler_2d" param="diffuse" />

	<node name="zMultiplier" type="float3_material_parameter" param="zPercentage" />

	<node name="mult" type="multiply" />
	<link from="zMultiplier" to="mult.A" />
	<link from="diffuseAdditional.rgb" to="mult.B" />

	<node name="teamColor" type="object_color_team" />
	<link from="team.a" to="teamColor.TeamMask" />
	
	<node name="Material" type="material" />
	<link from="diffuse.rgb" to="Material.Diffuse" />
	
	<link from="mult" to="Material.Emissive" />
	<link from="normal" to="Material.Normal" />
	<link from="specular.rgb" to="Material.Specular" />
	<link from="diffuse.a" to="Material.Opacity" />
	<link from="teamColor" to="Material.ObjectColor.Color" />

	<link from="shadowed" to="Material.Shadowed" />
</shader>