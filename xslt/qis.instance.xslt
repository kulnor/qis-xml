<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml ../xml/qis.instance1.xml?>
<!--
Overview: Tranform to create an overview of a QIS-XML instance in HTML format.

Author: Pascal Heus (pascal.heus@gmail.com)
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
	xmlns:qis="qis:1_1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	>
	<xsl:import href="qis.svg.xslt"/>
	<xsl:import href="qis.core.xslt"/>
	
	<xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>
	
	<!--
		MAIN
	-->
	<xsl:template match="/">
		<html>
			<head>
				
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="*:QIS">
		<h1>QIS INSTANCE</h1>
		<h3><xsl:apply-templates select="*:Identification"/></h3>
		<xsl:apply-templates select="*:Name|*:Description"></xsl:apply-templates>
		<div>
			<xsl:apply-templates select="/*:QIS/*:CircuitLibrary | /*:CircuitLibrary"/>
		</div>
		<h2>Gates</h2>
		<div>
			<xsl:call-template name="core-html-overview"/>
		</div>
	</xsl:template>
		
	<xsl:template match="*:CircuitLibrary">
		<h2>Circuit Library</h2>
		<h3><xsl:apply-templates select="*:Identification"/></h3>
		<xsl:apply-templates select="*:Name|*:Description"></xsl:apply-templates>
		<div>This library contains <xsl:value-of select="count(qis:Circuit)"/> circuit(s).</div>
		<xsl:apply-templates select="qis:Circuit"/>
	</xsl:template>
	
	<xsl:template match="*:Circuit">
		<h3><xsl:apply-templates select="*:Identification"/></h3>
		<xsl:apply-templates select="*:Name|*:Description"></xsl:apply-templates>
		<div style="margin-top:20px;">
			<svg width="{ (count(qis:Step) * $svg-cell-width) + $svg-element-sep-y}" height="{ (@size * $svg-cell-height) }">
				<xsl:apply-templates select="." mode="svg"/>
			</svg>
		</div>
	</xsl:template>

	<xsl:template match="*:GateLibrary">
		<h2><xsl:apply-templates select="*:Identification"/></h2>
		<div>This library contains <xsl:value-of select="count(*:Gate)"/> gate(s).</div>
		<xsl:apply-templates select="*:Gate"/>
	</xsl:template>

	<xsl:template match="*:Gate">
		<h5><xsl:apply-templates select="*:Identification"/></h5>
		<div><xsl:value-of select="*:Name"/></div>
	</xsl:template>
	
	<xsl:template match="*:Identification">
		<div>
			<xsl:value-of select="*:ID"/>
			<xsl:if test="*:Agency"> [<xsl:value-of select="*:Agency"/>]</xsl:if>
			<xsl:if test="*:Version"> (<xsl:value-of select="*:Version"/>)</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="*:Name">
		<div><xsl:value-of select="."/></div>
	</xsl:template>
	
	<xsl:template match="*:Description">
		<div><xsl:value-of select="."/></div>
	</xsl:template>
	
</xsl:stylesheet>
