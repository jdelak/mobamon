<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="waternormalmap1Ref" type="sampler_2d_ref" param="waternormalmap1" />
	<node name="waternormalmap2Ref" type="sampler_2d_ref" param="waternormalmap2" />
	<node name="cubeRef" type="sampler_cube_ref" param="cube" />
	
	<node name="alphaParams" type="float3_material_parameter" param="vAlphaParams" />
	<node name="textureParams" type="float3_material_parameter" param="vTextureParams" />

	<node name="waterVS" type="water_directional_vs" />
	
	<node name="waterPS" type="water_directional_ps" />
	<link from="waternormalmap1Ref" to="waterPS.waternormalmap1" />
	<link from="waternormalmap2Ref" to="waterPS.waternormalmap2" />
	<link from="cubeRef" to="waterPS.cube" />
	<link from="alphaParams" to="waterPS.AlphaParams" />
	<link from="textureParams" to="waterPS.TextureParams" />
	
	<link from="waterPS.Out" to="PSOutColor" />
</shader>