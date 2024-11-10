<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="position" type="float3_input" param="Position" />
	<node name="transform" type="transform_position" />
	<link from="position" to="transform.ObjectPosition" />
	
	<node name="white" type="float4_constant" param="1.0 1.0 1.0 1.0" />
	<link from="white" to="PSOutColor" />
	<link from="white" to="PSOutColor0" />
	<link from="white" to="PSOutColor1" />
	<link from="white" to="PSOutColor2" />
	<link from="white" to="PSOutColor3" />
</shader>