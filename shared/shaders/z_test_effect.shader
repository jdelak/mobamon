<?xml version="1.0" encoding="UTF-8"?>
<shader>

	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="color" type="float4_input" param="MaterialObjectColor" />
	<node name="emissive" type="multiply" />
	<node name="rot" type="rotator" param=".5" />

<!-- i tryed doing <link from="rot" to="diffuse.r" /> but it wouldn't spin the red channel. well nothing spun.
so, i went with <link from="rot" to="diffuse" /> which obviously spins the whole diffuse. 
(still trying to figure out how to make one channel spin at a time. ugh!!!) -->

	<link from="rot" to="diffuse" />
	<link from="diffuse.r" to="emissive.A" />
	<link from="color" to="emissive.B" />

<!-- i tryed adding textcoords to possibly separate out the channels somehow, but i'm assuming these only work for models/geometry? -->
<!--
	<node name="Texcoord1" type="texcoord" param="1" />
	<link from="rot" to="Texcoord1" />
	<link from="Texcoord1" to="diffuse.r" />
	<link from="Texcoord1" to="emissive.r" />

	<node name="Texcoord2" type="texcoord" param="1" />
	<link from="rot1" to="Texcoord2" />
	<link from="Texcoord1" to="diffuse.g" />
	<link from="Texcoord2" to="emissive.g" />
-->

	<node name="Material" type="material" />
	<link from="emissive.r" to="Material.Emissive" />
	<link from="emissive.r" to="Material.Opacity" />

	
	

<!-- last resort... i created another sampler that uses another .tga and i am apparently doing this wrong too because when this section is
uncommented out the sprite goes completely white. however, on it's own this section works fine and spins the whitedot in the opposite direction. -->
<!--
	<node name="diffuseWhitedot" type="sampler_2d" param="diffuse1" />
	<node name="colorWhitedot" type="float4_input" param="MaterialObjectColor" />
	<node name="emissiveWhitedot" type="multiply" />
	<node name="rotBackwards" type="rotator" param="-.5" />

	<link from="rotBackwards" to="diffuseWhitedot" />
	<link from="diffuseWhitedot" to="emissiveWhitedot.A" />
	<link from="colorWhitedot" to="emissiveWhitedot.B" />
	
	<node name="Material1" type="material" />
	<link from="emissiveWhitedot" to="Material1.Emissive" />
	<link from="emissiveWhitedot" to="Material1.Opacity" />
-->
	
</shader>
