<?xml version="1.0" encoding="UTF-8"?>
<!--
Takes a QIS instance as input and transforms the specified Circuit to SVG
If no parameters are provided, the first circuit that is found is used


Autho*: Pascal Heus (pascal.heus@gmail.com)
Version: 2016.08
Platform: XSL 2.0
License: BSD

Copyright © 2016 Pascal Heus (pascal.heus@gmail.com). All Rights Reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY [LICENSOR] "AS IS" AND ANY EXPRESS OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO 
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
-->
<xsl:stylesheet version="2.0"
	xmlns:i="qis:instance:1_1" 
	xmlns:g="qis:gate:1_1"
	xmlns:c="qis:circuit:1_1"
	xmlns:r="qis:reusable:1_1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	<xsl:import href="qis.svg.xslt"/>

	<xsl:param name="p_libraryID"></xsl:param> <!-- The library identifier -->
	<xsl:param name="p_circuitID"></xsl:param> <!-- The circuit identifier -->
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="/">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" baseProfile="full">
			<xsl:choose>
				<xsl:when test="normalize-space($p_libraryID)">
					<xsl:choose>
						<xsl:when test="normalize-space($p_circuitID)">
							<xsl:apply-templates select="/*:QIS/*:CircuitLibrary[*:Identification/*:ID=$p_libraryID]/*:Circuit[*:Identification/*:ID=$p_circuitID]" mode="svg"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/*:QIS/*:CircuitLibrary[*:Identification/*:ID=$p_libraryID]/*:Circuit[1]" mode="svg"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="normalize-space($p_circuitID)">
					<xsl:apply-templates select="/*:QIS/*:CircuitLibrary[1]/*:Circuit[*:Identification/*:ID=$p_circuitID]" mode="svg"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="/*:QIS/*:CircuitLibrary[1]/*:Circuit[1]" mode="svg"/>
				</xsl:otherwise>
			</xsl:choose>
		</svg>
	</xsl:template>
</xsl:stylesheet>
