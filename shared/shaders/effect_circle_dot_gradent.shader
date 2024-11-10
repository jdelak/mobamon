<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<!-- Shader Art Start -->
	
	<node name="diffuse1" type="art_circle" >
		<parameter name="Thickness" value="0.001" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Alpha" value="1.0" />
	</node>
	<node name="diffuse2" type="art_round_gradient" >
		<parameter name="Alpha" value="0.5" />
	</node>
	<node name="diffuse3" type="art_circle" >
		<parameter name="Thickness" value="0.5" />
		<parameter name="BlurThickness" value="0.00001" />
		<parameter name="Offset" value="0.01" />
	</node>
	
	<node name="diffuseAdd" type="add" /> 
	<link from="diffuse1" to="diffuseAdd.B" />
	<link from="diffuse2" to="diffuseAdd.A" />
	
	<node name="diffuseOut" type="add" /> 
	<link from="diffuseAdd" to="diffuseOut.B" />
	<link from="diffuse3" to="diffuseOut.A" />
	
	<!-- Shader Art End -->
	
	<node name="color" type="vertex_color" />
	<node name="emissive" type="multiply" />
	<link from="diffuseOut" to="emissive.A" />
	<link from="color" to="emissive.B" />
	
	<node name="Material" type="material" />
	<link from="emissive.rgb" to="Material.Emissive" />
	<link from="emissive.a" to="Material.Opacity" />
	<link from="vColorOverride" to="Material.ObjectColor.Color" />
	<link from="zero" to="Material.Fog" />
	<link from="one" to="Material.Fogofwar" />
</shader>