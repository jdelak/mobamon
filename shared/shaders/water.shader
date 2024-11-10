<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="waterdiffuseRef" type="sampler_2d_ref" param="waterdiffuse" />
	<node name="waternormalmap1Ref" type="sampler_2d_ref" param="waternormalmap1" />
	<node name="waternormalmap2Ref" type="sampler_2d_ref" param="waternormalmap2" />
	<node name="cubeRef" type="sampler_cube_ref" param="cube" />
	
	<node name="alphaParams" type="float3_material_parameter" param="vAlphaParams" />
	<node name="textureParams" type="float3_material_parameter" param="vTextureParams" />
	<node name="rotation" type="float2_material_parameter" param="vRotation" />

	<node name="waterVS" type="water_vs" />
	<link from="textureParams" to="waterVS.TextureParams" />
	<link from="rotation" to="waterVS.Rotation" />
	
	<node name="waterPS" type="water_ps" />
	<link from="waterdiffuseRef" to="waterPS.waterdiffuse" />
	<link from="waternormalmap1Ref" to="waterPS.waternormalmap1" />
	<link from="waternormalmap2Ref" to="waterPS.waternormalmap2" />
	<link from="cubeRef" to="waterPS.cube" />
	<link from="alphaParams" to="waterPS.AlphaParams" />
	
	<link from="waterPS.Out" to="PSOutColor" />
</shader>