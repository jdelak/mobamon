<?xml version="1.0" encoding="UTF-8"?>
<shader>
	<node name="postVS" type="post_outline_d_h_vs" />
	<node name="postPS" type="post_outline_d_ps" />
	
	<link from="postPS.Out" to="PSOutColor" />
</shader>