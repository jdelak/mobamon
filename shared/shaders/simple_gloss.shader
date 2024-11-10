<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="color" type="float3_constant" param="1.0 1.0 1.0" />
	
	<node name="Material" type="material" />
	<link from="color.rgb" to="Material.Diffuse" />
	<link from="color.rgb" to="Material.Specular" />
</shader>