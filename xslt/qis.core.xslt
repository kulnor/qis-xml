<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml qis.xml?>
<!--
Overview: Core tranformations / tenplates for QIS-XML

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
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:qis="qis:1_1" 
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	>
	<xsl:import href="qis.exslt.xslt"/>
	<xsl:import href="qis.svg.xslt"/>
	
	<xsl:template name="core-html-overview">
		<h3>1 qubit gates</h3>
		<div>
			<table>
				<xsl:apply-templates select="//qis:GateLibrary/qis:Gate[qis:Transformation/@size=1]" mode="table_row">
					<xsl:sort select="qis:Name"/>
				</xsl:apply-templates>
			</table>
		</div>
		<h3>2 qubit gates</h3>
		<div>
			<table>
				<xsl:apply-templates select="//qis:GateLibrary/qis:Gate[qis:Transformation/@size=2]" mode="table_row">
					<xsl:sort select="qis:Name"/>
				</xsl:apply-templates>
			</table>
		</div>
		<h3>3+ qubit gates</h3>
		<div>
			<table>
				<xsl:apply-templates select="//qis:GateLibrary/qis:Gate[qis:Transformation/@size>2]" mode="table_row">
					<xsl:sort select="qis:Name"/>
				</xsl:apply-templates>
			</table>
		</div>
	</xsl:template>

	<xsl:template name="xml2html">
		<xsl:param name="node"/>
		<xsl:param name="level" select="0"/>
		
		<xsl:variable name="indent" select="$level * 15"/>
		<xsl:variable name="sLabelDefaultStyle">color:blue;</xsl:variable>
		<xsl:variable name="sLabelElementNameStyle">color:#400;</xsl:variable>
		<xsl:variable name="sLabelAttributeNameStyle">color:red;</xsl:variable>
		<xsl:variable name="sLabelAttributeValueStyle">color:black;</xsl:variable>
		<xsl:variable name="sLabelTextStyle">color:black;</xsl:variable>
		<xsl:variable name="nLabelTextMaxLength">100</xsl:variable>

		<xsl:for-each select="$node">
			<xsl:if test="(name()='Gate' or name()='Circuit') and name(..)='QIS'"><hr/></xsl:if>
			<xsl:choose>
				<xsl:when test="./* or normalize-space($node/text())">
					<!-- node with children or text -->
					<div style="{$sLabelDefaultStyle};margin-left:{$indent}px;">
						<xsl:text>&lt;</xsl:text>
						<span style="{$sLabelElementNameStyle}"><xsl:value-of select="name()"/></span>
						<!-- node attributes -->
						<xsl:for-each select="@*">
							<xsl:text> </xsl:text>
							<span style="{$sLabelAttributeNameStyle}"><xsl:value-of select="name()"/></span>
							<xsl:text>="</xsl:text>
							<span style="{$sLabelAttributeValueStyle}"><xsl:value-of select="."/></span>
							<xsl:text>"</xsl:text>
						</xsl:for-each>
						<!-- node text -->
						<xsl:text>&gt;</xsl:text>
						<xsl:value-of select="normalize-space($node/text())"/>
					</div>
					<!-- children -->
					<xsl:for-each select="./*">
						<xsl:call-template name="xml2html">
							<xsl:with-param name="node" select="."/>
							<xsl:with-param name="level" select="$level + 1"/>
						</xsl:call-template>
					</xsl:for-each>
					<!-- close node -->
					<div style="{$sLabelDefaultStyle};margin-left:{$indent}px;">
						<xsl:text>&lt;/</xsl:text>
						<span style="{$sLabelElementNameStyle}"><xsl:value-of select="name($node)"/></span>
						<xsl:text>&gt;</xsl:text>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<!-- node has no children or text -->
					<div style="{$sLabelDefaultStyle};margin-left:{$indent}px;">
						<xsl:text>&lt;</xsl:text>
						<span style="{$sLabelElementNameStyle}"><xsl:value-of select="name()"/></span>
						<!-- node attributes -->
						<xsl:for-each select="@*">
							<xsl:text> </xsl:text>
							<span style="{$sLabelAttributeNameStyle}"><xsl:value-of select="name()"/></span>
							<xsl:text>="</xsl:text>
							<span style="{$sLabelAttributeValueStyle}"><xsl:value-of select="."/></span>
							<xsl:text>"</xsl:text>
						</xsl:for-each>
						<xsl:text> /&gt;</xsl:text>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- 
		Gate
	-->
	<xsl:template match="qis:Gate" mode="table_row">
		<tr style="background-color:#f0f0f0;">
			<td valign="top" width="200">
				<div style="font-weight:bold;">
					<xsl:value-of select="qis:Name"/>
				</div>
				<xsl:if test="Description">
					<div style="font-size:8pt;">
						<xsl:value-of select="qis:Description"/>
					</div>
				</xsl:if>
			</td>
			<td style="font-size:8pt;text-align:right;">
				<xsl:value-of select="qis:Identification/@id"/>
				<xsl:if test="qis:Parameter">
					<xsl:text>(</xsl:text>
					<xsl:for-each select="qis:Parameter">
						<xsl:if test="position()>1">,</xsl:if>
						<xsl:value-of select="qis:Name"/>
					</xsl:for-each>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<xsl:text>=</xsl:text>
			</td>
			<td>
				<xsl:apply-templates select="qis:Transformation" mode="toMatrix"/>
			</td>
			<!--
			<td valign="middle">
				<xsl:choose>
					<xsl:when test="Image">
						<xsl:apply-templates select="Image"/>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
			-->
			<td valign="middle">
				<svg width="50" height="{(qis:Transformation/@size)*$svg-cell-height}">				
				  <xsl:apply-templates select="." mode="svg">
					  <xsl:with-param name="x" select="25"/>
					  <xsl:with-param name="y" select="25"/>
					  <xsl:with-param name="map" select="Map"/>
				  </xsl:apply-templates>
				</svg>
			</td>
		</tr>
	</xsl:template>
	
	<!--
		Tranformation
	-->
	<xsl:template match="qis:Transformation" mode="toMatrix">
		<table>
			<tr>
				<xsl:if test="qis:Multiplier">
					<td style="font-size:8pt; text-align:right;">
						<xsl:apply-templates select="qis:Multiplier"/>
					</td>
				</xsl:if>
				<td style="border:1px solid black; border-right:none; font-size:0px;">&#160;</td>
				<td>
					<xsl:apply-templates select="." mode="_toMatrix"/>
				</td>
				<td style="border:1px solid black; border-left:none; font-size:0px;">&#160;</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template match="qis:Transformation" mode="_toMatrix">
		<xsl:param name="startRow">1</xsl:param>
		<xsl:param name="startCol">1</xsl:param>
		<xsl:param name="size">
			<xsl:value-of select="@size"/>
		</xsl:param>
		<xsl:choose>
			<xsl:when test="$size=1">
				<!-- This is a 2x2 matrix, render it -->
				<table cellspacing="2" cellpadding="2" border="0">
					<tr style="background-color:#d0d0d0;">
						<!-- top left cell -->
						<td style="font-size:8pt; size=50%;" align="center">
							<xsl:choose>
								<xsl:when test="./qis:Cell[@row=$startRow and @col=$startCol]">
									<xsl:apply-templates select="./qis:Cell[@row=$startRow and @col=$startCol]"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</td>
						<!-- top right cell -->
						<td style="font-size:8pt; size=50%;" align="center">
							<xsl:choose>
								<xsl:when test="./qis:Cell[@row=$startRow and @col=$startCol+1]">
									<xsl:apply-templates select="./qis:Cell[@row=$startRow and @col=$startCol+1]"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr style="background-color:#d0d0d0;">
						<!-- bottom left cell -->
						<td style="font-size:8pt;" align="center">
							<xsl:choose>
								<xsl:when test="./qis:Cell[@row=$startRow+1 and @col=$startCol]">
									<xsl:apply-templates select="./qis:Cell[@row=$startRow+1 and @col=$startCol]"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</td>
						<!-- bottom right cell -->
						<td style="font-size:8pt;" align="center">
							<xsl:choose>
								<xsl:when test="./qis:Cell[@row=$startRow+1 and @col=$startCol+1]">
									<xsl:apply-templates select="./qis:Cell[@row=$startRow+1 and @col=$startCol+1]"/>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<!-- This is large than a 2x2 matrix. Split it in 4 sub-matrices and make recursive calls to this template -->
				<xsl:variable name="offset">
					<!-- compute the row and colum offset. This uses EXSLT. -->
					<xsl:call-template name="math:power">
						<xsl:with-param name="base" select="2"/>
						<xsl:with-param name="power" select="($size)-1"/>
					</xsl:call-template>
				</xsl:variable>
				<table cellspacing="0" cellpadding="0" border="0">
					<tr>
						<td>
							<!-- top-left submatrix -->
							<xsl:apply-templates select="." mode="_toMatrix">
								<xsl:with-param name="startRow" select="$startRow"/>
								<xsl:with-param name="startCol" select="$startCol"/>
								<xsl:with-param name="size" select="($size)-1"/>
							</xsl:apply-templates>
						</td>
						<td>
							<!-- top-right submatrix -->
							<xsl:apply-templates select="." mode="_toMatrix">
								<xsl:with-param name="startRow" select="$startRow"/>
								<xsl:with-param name="startCol" select="$startCol+$offset"/>
								<xsl:with-param name="size" select="($size)-1"/>
							</xsl:apply-templates>
						</td>
					</tr>
					<tr>
						<td>
							<!-- bottom-left submatrix -->
							<xsl:apply-templates select="." mode="_toMatrix">
								<xsl:with-param name="startRow" select="$startRow+$offset"/>
								<xsl:with-param name="startCol" select="$startCol"/>
								<xsl:with-param name="size" select="($size)-1"/>
							</xsl:apply-templates>
						</td>
						<td>
							<!-- bottom-right submatrix -->
							<xsl:apply-templates select="." mode="_toMatrix">
								<xsl:with-param name="startRow" select="$startRow+$offset"/>
								<xsl:with-param name="startCol" select="$startCol+$offset"/>
								<xsl:with-param name="size" select="($size)-1"/>
							</xsl:apply-templates>
						</td>
					</tr>
				</table>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- 
		Cell
	-->
	<xsl:template match="qis:Cell">
		<div style="font-weight:bold;">
			<xsl:call-template name="qis:ComplexNumberType">
				<xsl:with-param name="value" select="."/>
			</xsl:call-template>
		</div>
	</xsl:template>
	<!-- 
		Multiplier
	-->
	<xsl:template match="qis:Multiplier">
		<xsl:call-template name="qis:ComplexNumberType">
			<xsl:with-param name="value" select="."/>
		</xsl:call-template>
	</xsl:template>
	<!-- 
		ComplexNumberType
	-->
	<xsl:template name="qis:ComplexNumberType">
		<xsl:param name="value"/>
		<!-- real -->
		<xsl:if test="$value/@r">
			<xsl:value-of select="format-number($value/@r,'0.###')"/>
		</xsl:if>
		<!-- imaginary -->
		<xsl:if test="$value/@i">
			<xsl:if test="$value/@r">
				<xsl:if test="not($value/@i &gt; 0)"/>
			</xsl:if>
			<xsl:if test="$value/@i = -1.0">-</xsl:if>
			<xsl:if test="not($value/@i=1.0 or $value/@i=-1.0)">
				<xsl:value-of select="format-number($value/@i,'0.###')"/>
			</xsl:if>
			<xsl:text>i</xsl:text>
		</xsl:if>
		<!-- symbolic in html -->
		<xsl:if test="qis:Symbolic[@syntax='html']">
			<div><xsl:value-of select="qis:Symbolic[@syntax='html']"/></div>
		</xsl:if>
	</xsl:template>
	
	<!-- Image -->
	<xsl:template match="qis:Image">
		<xsl:choose>
			<xsl:when test="@format='svg'">
				<object data="{.}" width="{@width}" height="{@height}" type="image/svg+xml"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
