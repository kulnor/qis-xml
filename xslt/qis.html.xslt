<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml ../xml/qis.instance1.xml?>
<!--
Overview: Transform to create project page for qis.xml file.

Author: Pascal Heus (pascal.heus@gmail.com)
Version: 2007.03
Platform: XSL 1.0

License: 
	Copyright 2006-2007 Pascal Heus (pascal.heus@gmail.com)

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
  
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
  
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:svg="http://www.w3.org/2000/svg" 
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	>
	<xsl:import href="qis.core.xslt"/>
	<!-- <xsl:import href="qis.validation.xslt"/> -->
	<xsl:import href="qis.svg.xslt"/>
	
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:param name="page">core-html-overview</xsl:param>
	
	<!--
		MAIN
	-->
	<xsl:template match="/">
		<div>
			<xsl:value-of select="$page"/>
			<xsl:choose>
				<xsl:when test="$page='svg-circuits'">
					<xsl:call-template name="svg-circuits"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="core-html-overview"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
