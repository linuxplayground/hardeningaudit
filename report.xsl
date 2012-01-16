<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by David Latham -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:variable name="empty_string"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>Hardening Audit Results</title>
				<style><![CDATA[
	body {font-family:Arial;font-size:10pt;}
	pre { font-size:10pt;}
	h3 img {margin-right:5px;}
	ul {list-style-type: none;padding: 0;margin-left: 1em;}
	li.list-pass {margin:0; padding: 2px 0 2px 16px; list-style: none; background:url('images/icons/tick_small.jpg') no-repeat top left;}
	li.list-high {margin:0; padding: 2px 0 2px 16px; list-style: none; background:url('images/icons/cross_small.jpg') no-repeat top left;}
	li.list-med  {margin:0; padding: 2px 0 2px 16px; list-style: none; background:url('images/icons/warn_small.jpg')  no-repeat top left;}
	li.list-low  {margin:0; padding: 2px 0 2px 16px; list-style: none; background:url('images/icons/excl_blue_small.jpg')  no-repeat top left;}
	li.list-text {margin:0; padding: 2px 0 2px 16px; list-style: none; background:url('images/icons/info_small.jpg')  no-repeat top left;}
					]]>
				</style>
				<script type="text/javascript">
				<![CDATA[
function toggle(e) {
	// assumes all elements with class='ON'are <div>
	var aD=document.getElementsByTagName('div');
	var aLi = document.getElementsByTagName('li');
	for(var i=0; i<aD.length; i++) {
		if(aD[i].id == e) {
			if(aD[i].style.display == "block") {
				aD[i].style.display = "none";
			} else {
				aD[i].style.display = 'block';
			}
		}
	}
	for(var i=0; i<aLi.length; i++) {
		if(aLi[i].id == e) {
			if(aLi[i].style.display == 'block') {
				aLi[i].style.display = 'none';
			} else {
				aLi[i].style.display = 'block';
			}
		}
	}
}
				]]>
				</script>
			</head>
			<body>
				<h1>Linux Hardening Review - Detailed</h1>
				<a><xsl:attribute name="name">top</xsl:attribute></a>
				<b><u>Legend:</u></b> Click to toggle visibility<br/>
				<img src="images/icons/tick_small.jpg"/> <a href="#"><xsl:attribute name="onclick"><![CDATA[toggle('PASS');]]></xsl:attribute>OK</a>
				<img src="images/icons/excl_blue_small.jpg"/> <a href="#"><xsl:attribute name="onclick"><![CDATA[toggle('LOW');]]></xsl:attribute>Low Risk</a>
				<img src="images/icons/warn_small.jpg"/> <a href="#"><xsl:attribute name="onclick"><![CDATA[toggle('MED');]]></xsl:attribute>Medium Risk</a>
				<img src="images/icons/cross_small.jpg"/> <a href="#"><xsl:attribute name="onclick"><![CDATA[toggle('HIGH');]]></xsl:attribute>High Risk</a>
				<img src="images/icons/info_small.jpg"/><a href="#"><xsl:attribute name="onclick"><![CDATA[toggle('TEXT');]]></xsl:attribute>Information</a>
				<h2>Table Of Contents</h2>
				<ul>
					<xsl:for-each select="items/item">
						<li><xsl:choose>
							<xsl:when test="type = 'PASS'"><xsl:attribute name="class">list-pass</xsl:attribute></xsl:when>
							<xsl:when test="type = 'MED'"><xsl:attribute name="class">list-med</xsl:attribute></xsl:when>
							<xsl:when test="type = 'HIGH'"><xsl:attribute name="class">list-high</xsl:attribute></xsl:when>
							<xsl:when test="type = 'LOW'"><xsl:attribute name="class">list-low</xsl:attribute></xsl:when>
							<xsl:when test="type = 'TEXT'"><xsl:attribute name="class">list-text</xsl:attribute></xsl:when>
						</xsl:choose>
						<xsl:attribute name="id"><xsl:value-of select="type"/></xsl:attribute>
						<xsl:attribute name="style"><![CDATA[display:block;]]></xsl:attribute>
						<a><xsl:attribute name="href"><![CDATA[#]]><xsl:value-of select="name"/></xsl:attribute><xsl:value-of select="title"/></a>
						</li>
					</xsl:for-each>
				</ul>
				<h2>Details</h2>
				<xsl:for-each select="items/item">
					<div>
						<xsl:attribute name="id"><xsl:value-of select="type"/></xsl:attribute>
						<xsl:attribute name="style"><![CDATA[display:block;]]></xsl:attribute>
						<h3><img border="0">
								<xsl:choose>
									<xsl:when test="type = 'PASS'"><xsl:attribute name="src">images/icons/tick.jpg</xsl:attribute></xsl:when>
									<xsl:when test="type = 'MED'"><xsl:attribute name="src">images/icons/warn.jpg</xsl:attribute></xsl:when>
									<xsl:when test="type = 'HIGH'"><xsl:attribute name="src">images/icons/cross.jpg</xsl:attribute></xsl:when>
									<xsl:when test="type = 'LOW'"><xsl:attribute name="src">images/icons/excl_blue.jpg</xsl:attribute></xsl:when>
									<xsl:when test="type = 'TEXT'"><xsl:attribute name="src">images/icons/info.jpg</xsl:attribute></xsl:when>
								</xsl:choose>
								<xsl:attribute name="style"><![CDATA[vertical-align: middle;]]></xsl:attribute>
							</img>
							<a><xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute><xsl:attribute name="href"><![CDATA[#top]]></xsl:attribute><xsl:value-of select="title"/></a>
						</h3>
						<xsl:if test="normalize-space(msg) != $empty_string">
							<p>Message:<br/><pre><xsl:value-of select="msg"/></pre></p>
						</xsl:if>
						<xsl:if test="normalize-space(rec) != $empty_string">
							<p>Recommendation:<br/><pre><xsl:value-of select="rec"/></pre></p>
						</xsl:if>
					</div>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
