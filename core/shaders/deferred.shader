<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="image" type="sampler_2d" param="deferred0" />
	<link from="image" to="PSOutColor" />

	<!--
	<node name="image" type="sampler_2d" param="deferred1" />
	
	<node name="one" type="float_constant" param="1" />
	<node name="scaleValue" type="float_constant" param="0.01" />
	<node name="scale" type="multiply" />
	<link from="image.aaa" to="scale.A" />
	<link from="scaleValue" to="scale.B" />
	
	<node name="color" type="append" />
	<link from="scale" to="color.A" />
	<link from="one" to="color.B" />
	
	<link from="color" to="PSOutColor" />
	-->
	
	<!--
	<node name="image" type="sampler_2d" param="deferred1" />
	<link from="image" to="PSOutColor" />
	-->
	
	<!--
	<node name="deferred1" type="sampler_2d" param="deferred1" />
	
	<node name="pos" type="deferred_view_position" />
	<link from="deferred1.a" to="pos.ViewDistance" />
	
	<node name="pos2" type="float3_constant" param="0.0 0.0 -100.0" />
	
	<node name="direction" type="direction" />
	<link from="pos" to="direction.A" />
	<link from="pos2" to="direction.B" />
	
	<node name="dot" type="dot" />
	<link from="direction" to="dot.A" />
	<link from="deferred1.rgb" to="dot.B" />
	
	<node name="cast" type="float3_cast"  />
	<link from="dot" to="cast" />
		
	<node name="one" type="float_constant" param="1" />
	<node name="color" type="append" />
	<link from="cast" to="color.A" />
	<link from="one" to="color.B" />
	
	<link from="color" to="PSOutColor" />
	-->
	
	<!--
	<node name="deferred3" type="sampler_2d" param="deferred3" />
	<link from="deferred3" to="PSOutColor" />
	-->
	
</shader>