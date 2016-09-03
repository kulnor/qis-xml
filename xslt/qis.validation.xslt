<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml ../xml/qis.instance1.xml?>
<!--
Overview: Templates that provide consistency validation for QIS-XML documents

Author: Pascal Heus (pascal.heus@gmail.com)
Version: 2006.12
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
	xmlns:i="qis:instance:1_1" 
	xmlns:g="qis:gate:1_1" 
	xmlns:c="qis:circuit:1_1" 
	xmlns:p="qis:program:1_1" 
	xmlns:r="qis:reusable:1_1" 
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	exclude-result-prefixes="i g c p r svg math"
	>
	<xsl:import href="qis.exslt.xslt"/>

	<xsl:variable name="validation-indent">margin-left:10px;</xsl:variable>
	<xsl:variable name="validation-warning-style">color:orange;<xsl:value-of select="$validation-indent"/></xsl:variable>
	<xsl:variable name="validation-error-style">color:red;font-weight:bold;<xsl:value-of select="$validation-indent"/></xsl:variable>
	
	<xsl:template match="/" >
		<xsl:apply-templates select="//g:Gate" mode="validation"/>
		<xsl:apply-templates select="//c:Circuit" mode="validation"/>
		<xsl:apply-templates select="//p:Program" mode="validation"/>
	</xsl:template>

	<!-- Gate -->
	<xsl:template match="g:Gate" mode="validation">
		<!-- Gate - Initialization -->
		<xsl:variable name="gate-max-rowcol">
			<xsl:call-template name="math:power">
				<xsl:with-param name="base" select="2"/>
				<xsl:with-param name="power" select="r:Transformation/@size"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- Gate - Information -->
		<hr/>
		<div>
			Gate <xsl:value-of select="r:Identification/r:ID"/>, Size <xsl:value-of select="r:Transformation/@size"/>
		</div>
		<xsl:if test="g:Name">
			<div><xsl:value-of select="g:Name"/></div>
		</xsl:if>
		<xsl:if test="g:Description">
			<div><xsl:value-of select="g:Description"/></div>
		</xsl:if>

		<!-- Gate - Check Transformation row/col range -->
		<xsl:for-each select="r:Transformation/r:Cell[ (@row > $gate-max-rowcol) or @col > $gate-max-rowcol ]">
			<div style="{$validation-error-style}">ERROR: Transformation Cell <xsl:value-of select="position()"/> row=<xsl:value-of select="@row"/>/col=<xsl:value-of select="@col"/> out of Gate range.</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Circuit -->
	<xsl:template match="c:Circuit" mode="validation">
		<hr/>
		<div>
			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="r:Identification"><xsl:value-of select="r:Identification/r:ID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
				</xsl:choose>	
			</xsl:variable>
			Circuit <xsl:value-of select="$ID"/>, Size <xsl:value-of select="@size"/>, <xsl:value-of select="count(c:Step)"/> step(s)
		</div>
		<xsl:if test="c:Name">
			<div><xsl:value-of select="c:Name"/></div>
		</xsl:if>
		<xsl:if test="c:Description">
			<div><xsl:value-of select="c:Description"/></div>
		</xsl:if>
		<div style="{$validation-indent}">
			<xsl:apply-templates select="c:Step" mode="validation"/>
		</div>
	</xsl:template>

	<!-- Circuit Step -->
	<xsl:template match="c:Step" mode="validation">
		<!-- Step - Initiliatzaion -->
		<xsl:variable name="circuit-size" select="../@size"/>

		<!-- Step - Information -->
		<div>Step <xsl:value-of select="position()"/>, <xsl:value-of select="count(c:Operation)"/> operation(s)</div>
		<xsl:if test="Description">
			<div><xsl:value-of select="Description"/></div>
		</xsl:if>

		<!-- Operation - Check qubit range -->
		<xsl:for-each select="c:Operation/c:Map[@qubit > $circuit-size ]">
			<div style="{$validation-error-style}">ERROR: Map <xsl:value-of select="position()"/> qubit=<xsl:value-of select="@qubit"/> is out of Circuit range.</div>
		</xsl:for-each>

		<!-- Step - Check qubit count -->
		<xsl:if test="$circuit-size > count(c:Operation/c:Map)">
			<div style="{$validation-warning-style}">Warning: Not all qubits have been mapped.</div>
		</xsl:if>

		<!-- Step - Check duplicate qubit mapping -->
		<xsl:for-each select="c:Operation/c:Map">
			<xsl:variable name="qubit" select="@qubit"/>
			<xsl:variable name="qubit-count" select="count(../../c:Operation/c:Map[@qubit=$qubit])"/>
			<xsl:if test="$qubit-count>1">
				<div style="{$validation-error-style}">ERROR: Qubit <xsl:value-of select="$qubit"/> is ampped <xsl:value-of select="$qubit-count"/> times.</div>
			</xsl:if>
		</xsl:for-each>
		
		<!-- Validate Operation -->
		<div style="{$validation-indent}">
			<xsl:apply-templates select="c:Operation" mode="validation"/>
		</div>
	</xsl:template>

	<!-- Circuit Step Operation -->
	<xsl:template match="c:Operation" mode="validation">

		<!-- Operation - Check duplicate input mapping -->
		<xsl:for-each select="c:Map">
			<xsl:variable name="input" select="@input"/>
			<xsl:variable name="input-count" select="count(../Map[@input=$input])"/>
			<xsl:if test="$input-count > 1">
				<div style="{$validation-error-style}">ERROR: Input <xsl:value-of select="$input"/> is mapped <xsl:value-of select="$input-count"/> times.</div>
			</xsl:if>
		</xsl:for-each>
	
		<xsl:choose>
			<!-- Gate based Operation -->
			<xsl:when test="c:GateRef">
				<!-- Operation init -->
				<xsl:variable name="gate-id" select="c:GateRef/r:ID"/>
				<xsl:variable name="gate" select="//g:GateLibrary/g:Gate[r:Identification/r:ID = $gate-id]"/>
				<xsl:choose>
					<!-- check if Gate has been found -->
					<xsl:when test="$gate">
						<xsl:variable name="gate-size" select="$gate/r:Transformation/@size"/>
						<!-- Display Gate Operation Info -->
						<div>
							<xsl:value-of select="position()"/>:
							<xsl:value-of select="$gate/g:Name"/> (<xsl:value-of select="$gate-id"/>)
							<xsl:text>[</xsl:text>
							<xsl:for-each select="c:Map">
								<xsl:if test="position()>1">,</xsl:if>
								<xsl:value-of select="@qubit"/>=<xsl:value-of select="@input"/>
							</xsl:for-each>
							<xsl:text>]</xsl:text>
						</div>
						<!-- Operation - Check Gate size and Map count -->
						<xsl:if test="not( $gate-size = count(c:Map) )">
							<div style="{$validation-error-style}">ERROR: Gate size and mappings do not match. Gate has <xsl:value-of select="$gate-size"/> input(s), Operation specified <xsl:value-of select="count(c:Map)"/> mapping(s).</div>
						</xsl:if>
						<!-- Operation - Check Map input range -->
						<xsl:for-each select="c:Map[@input > $gate-size ]">
							<div style="{$validation-error-style}">ERROR: Map <xsl:value-of select="position()"/> input=<xsl:value-of select="@input"/> is out of Gate range.</div>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- Gate not found -->
						<div style="{$validation-error-style}">ERROR: Gate <xsl:value-of select="$gate-id"/> not found.</div>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="c:CircuitRef">
				<div style="{$validation-warning-style}">Warning: Circuit based Operation validation not yet implemented.</div>
			</xsl:when>
			<xsl:when test="c:Measurement">
				<div style="{$validation-warning-style}">Warning: Measurement based Operation validation not yet implemented.</div>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Program -->
	<xsl:template match="p:Program" mode="validation">
		<hr/>
		<div>
			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="r:Identification"><xsl:value-of select="r:Identification/r:ID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
				</xsl:choose>	
			</xsl:variable>
			Program <xsl:value-of select="$ID"/>, Size <xsl:value-of select="@size"/>, <xsl:value-of select="count(c:Step)"/> step(s)
		</div>
		<xsl:if test="c:Name">
			<div><xsl:value-of select="c:Name"/></div>
		</xsl:if>
		<xsl:if test="c:Description">
			<div><xsl:value-of select="c:Description"/></div>
		</xsl:if>
		<div style="{$validation-warning-style}">Warning: Program validation not yet implemented.</div>
	</xsl:template>
</xsl:stylesheet>
