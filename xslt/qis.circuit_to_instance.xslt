<?xml version="1.0" encoding="UTF-8"?>
<!--
Converts a c:CircuitLibray document into a i:QIS instance by merging 
with the specified gate library.


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
	xmlns:i="qis:instance:1_1" 
	xmlns:g="qis:gate:1_1"
	xmlns:c="qis:circuit:1_1"
	xmlns:r="qis:reusable:1_1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	<xsl:import href="qis.svg.xslt"/>

	<xsl:param name="p_gateLibraryDocument">../xml/qis.gate.core.xml</xsl:param>
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="/">
		<xsl:apply-templates select="/c:CircuitLibrary"/>
	</xsl:template>
	
	<xsl:template match="/c:CircuitLibrary">
		<i:QIS>
			<r:Identification>
				<r:ID>instance_of_<xsl:value-of select="/c:CircuitLibrary/r:Identification/r:ID"/></r:ID>
			</r:Identification>
			<xsl:variable name="gateLibrary" select="document($p_gateLibraryDocument)"/>
			<g:GateLibrary>
				<xsl:copy-of select="$gateLibrary/g:GateLibrary/*"/>
			</g:GateLibrary>
			<c:CircuitLibrary>
				<xsl:copy-of select="/c:CircuitLibrary/*"/>
			</c:CircuitLibrary>
		</i:QIS>
	</xsl:template>
	
</xsl:stylesheet>
