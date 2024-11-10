<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="shadowed" type="float_input" param="Shadowed" />
	<node name="one" type="float_constant" param="1.0" />

	<node name="expanded" type="float3_cast" />
	<link from="shadowed" to="expanded" />
	
	<node name="appended" type="append" />
	<link from="expanded" to="appended.A" />
	<link from="one" to="appended.B" />
	
	<link from="appended" to="PSOutColor" />
</shader>