<?xml version="1.0" encoding="UTF-8"?>
<!--
Overview: EXSLT templates used by QIS-XML transforms
See http://www.exslt.org/

Author: Pascal Heus (pascal.heus@gmail.com)
Version: 2007.02
Platform: XSL 1.0

License: 
	Copyright 2006 Pascal Heus (pascal.heus@gmail.com)

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
  
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
  
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	>

	<!-- 
		math:power
	-->
	<xsl:template name="math:power">
		<xsl:param name="base" select="0"/>
		<xsl:param name="power" select="1"/>
		<xsl:choose>
			<xsl:when test="$power &lt; 0 or contains(string($power), '.')">
				<xsl:message terminate="yes">
        The XSLT template math:power doesn't support negative or
        fractional arguments.
      </xsl:message>
				<xsl:text>NaN</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="math:_power">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="power" select="$power"/>
					<xsl:with-param name="result" select="1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="math:_power">
		<xsl:param name="base" select="0"/>
		<xsl:param name="power" select="1"/>
		<xsl:param name="result" select="1"/>
		<xsl:choose>
			<xsl:when test="$power = 0">
				<xsl:value-of select="$result"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="math:_power">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="power" select="$power - 1"/>
					<xsl:with-param name="result" select="$result * $base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
