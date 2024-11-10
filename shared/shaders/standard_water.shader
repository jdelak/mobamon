<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="diffuse" type="sampler_2d" param="diffuse" />
	<node name="normal1" type="sampler_normalmap_rxgb" param="normalmap1" />
	<node name="normal2" type="sampler_normalmap_rxgb" param="normalmap2" />
	<node name="cubeRef" type="sampler_cube_ref" param="cube" />
	
	<node name="speed" type="float_material_parameter" param="fSpeed" />
	<node name="diffuseOpacity" type="float_material_parameter" param="fDiffuseOpacity" />
	<node name="reflectOpacity" type="float_material_parameter" param="fReflectOpacity" />
	
	<node name="texcoordLayer0" type="panner" />
	<link from="speed.xx" to="texcoordLayer0.Speed" />
	
	<link from="texcoordLayer0" to="diffuse" />
	<link from="texcoordLayer0" to="normal1" />
	
	<node name="texcoordBase" type="texcoord" />
	<node name="texcoordBaseScale" type="float_constant" param="-1.5" />
	
	<node name="texcoordScale" type="multiply" />
	<link from="texcoordBase" to="texcoordScale.A" />
	<link from="texcoordBaseScale" to="texcoordScale.B" />
	
	<node name="texcoordLayer1" type="panner" />
	<link from="texcoordScale" to="texcoordLayer1.Speed" />
	<link from="speed.xx" to="texcoordLayer1.Speed" />
	
	<link from="texcoordLayer1" to="normal2" />
	
	<node name="normalAdd" type="add" />
	<link from="normal1" to="normalAdd.A" />
	<link from="normal2" to="normalAdd.B" />
	
	<node name="normal" type="normalize" />
	<link from="normalAdd" to="normal" />
	
	<node name="materialDiffuse" type="material_diffuse" />
	<node name="materialOpacity" type="material_opacity" />
	<node name="materialNormal" type="material_normal" />
	<node name="materialWorldBump" type="material_world_bump" />
	<node name="materialNormalizeNormal" type="material_normalize_normal" />
	<link from="diffuse.rgb" to="materialDiffuse" />
	<link from="diffuse.a" to="materialOpacity" />
	<link from="normal" to="materialNormal" />

	<node name="waterVS" type="standard_water_vs" />
	
	<node name="waterPS" type="standard_water_ps" />
	<link from="cubeRef" to="waterPS.cube" />
	<link from="diffuseOpacity" to="waterPS.DiffuseOpacity" />
	<link from="reflectOpacity" to="waterPS.ReflectOpacity" />
	
	<link from="waterPS.Out" to="PSOutColor" />
</shader>