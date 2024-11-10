<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<!-- Shader Art Start -->
	
	<node name="diffuse1" type="art_circle" >
		<parameter name="Thickness" value="0.002" />
		<parameter name="BlurThickness" value="0.01" />
		<parameter name="Alpha" value="0.35" />
		<parameter name="Offset" value="0.98" />
	</node>
	<node name="diffuse2" type="art_round_gradient" >
		<parameter name="Alpha" value="0.25" />
		<parameter name="Offset" value="1.2" />
		<parameter name="Fade" value="7.5" />
	</node>
	<node name="diffuse3" type="art_circle" >
		<parameter name="Thickness" value="0.5" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Offset" value="0.02" />
		<parameter name="Alpha" value="0.35" />
	</node>
	<node name="diffuse4" type="art_round_gradient" >
		<parameter name="Alpha" value="2.0" />
		<parameter name="Offset" value="0.125" />
		<parameter name="Fade" value="5.0" />
	</node>
	<node name="diffuse5" type="art_circle" >
		<parameter name="Thickness" value="0.002" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Alpha" value="0.2" />
		<parameter name="Offset" value="0.37" />
	</node>
	
	<node name="diffuseAdd1" type="add" /> 
	<link from="diffuse1" to="diffuseAdd1.B" />
	<link from="diffuse2" to="diffuseAdd1.A" />
	
	<node name="diffuseAdd2" type="add" /> 
	<link from="diffuseAdd1" to="diffuseAdd2.B" />
	<link from="diffuse3" to="diffuseAdd2.A" />
	
	<node name="diffuseAdd3" type="add" /> 
	<link from="diffuseAdd2" to="diffuseAdd3.B" />
	<link from="diffuse4" to="diffuseAdd3.A" />
	
	<node name="diffuseOut" type="add" /> 
	<link from="diffuseAdd3" to="diffuseOut.B" />
	<link from="diffuse5" to="diffuseOut.A" />
	
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