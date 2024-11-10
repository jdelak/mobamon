<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="vColorOverride" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<node name="zero" type="float_constant" param="0.0" />
	<node name="one" type="float_constant" param="1.0" />

	<!-- Shader Art Start -->
	
	<node name="diffuse1" type="art_circle" >
		<parameter name="Thickness" value="0.002" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Alpha" value="0.9" />
	</node>
	<node name="diffuse2" type="art_circle" >
		<parameter name="Thickness" value="0.004" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Offset" value="0.99" />
		<parameter name="Alpha" value="0.25" />
	</node>
	<node name="diffuse3" type="art_circle_spikes" >
		<parameter name="Alpha" value="10.0" />
		<parameter name="Lenght" value="5.75" />
		<parameter name="Offset" value="1.0" />
		<parameter name="Size" value="0.25" />
		<parameter name="Spacing" value="0.125" />
	</node>
	<node name="diffuse4" type="art_circle" >
		<parameter name="Thickness" value="0.1" />
		<parameter name="BlurThickness" value="0.005" />
		<parameter name="Offset" value="0.015" />
	</node>
	
	<node name="diffuseAdd" type="add" /> 
	<link from="diffuse2" to="diffuseAdd.B" />
	<link from="diffuse1" to="diffuseAdd.A" />
	
	<node name="diffuseMin" type="min" /> 
	<link from="diffuse3" to="diffuseMin.B" />
	<link from="diffuseAdd" to="diffuseMin.A" />
	
	<node name="diffuseOut" type="max" /> 
	<link from="diffuseMin" to="diffuseOut.B" />
	<link from="diffuse4" to="diffuseOut.A" />
	
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