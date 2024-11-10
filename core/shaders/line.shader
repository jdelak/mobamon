<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />
	
	<node name="vertexColor" type="vertex_color" />
	<node name="materialColor" type="float4_input" param="vColor" />
	<node name="color" type="multiply" />
	<link from="vertexColor" to="color.A" />
	<link from="materialColor" to="color.B" />
	
	<node name="Material" type="material" />
	<link from="color.rgb" to="Material.Emissive" />
	<link from="color.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>