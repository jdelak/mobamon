<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="imageY" type="sampler_2d_alpha" param="imageY" />
	<node name="imagecR" type="sampler_2d_alpha" param="imagecR" />
	<node name="imagecB" type="sampler_2d_alpha" param="imagecB" />
	
	<node name="texcoord0" type="texcoord" param="0" />
	<link from="texcoord0" to="imageY.Texcoord" />
	
	<node name="texcoord1" type="texcoord" param="1" />
	<link from="texcoord1" to="imagecR.Texcoord" />
	<link from="texcoord1" to="imagecB.Texcoord" />

	<node name="movie" type="bink" />
	<link from="imageY" to="movie.Y" />
	<link from="imagecR" to="movie.cR" />
	<link from="imagecB" to="movie.cB" />

	<node name="color" type="vertex_color" />
	<node name="blend" type="multiply" />
	<link from="movie" to="blend.A" />
	<link from="color" to="blend.B" />
	<link from="blend" to="PSOutColor" />
</shader>
