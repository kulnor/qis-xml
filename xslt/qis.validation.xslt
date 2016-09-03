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
	xmlns:qis="qis:1_1" 
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	exclude-result-prefixes="qis svg math"
	>
	<xsl:import href="qis.exslt.xslt"/>

	<xsl:variable name="validation-indent">margin-left:10px;</xsl:variable>
	<xsl:variable name="validation-warning-style">color:orange;<xsl:value-of select="$validation-indent"/></xsl:variable>
	<xsl:variable name="validation-error-style">color:red;font-weight:bold;<xsl:value-of select="$validation-indent"/></xsl:variable>
	
	<xsl:template match="/" >
		<xsl:apply-templates select="//qis:Gate" mode="validation"/>
		<xsl:apply-templates select="//qis:Circuit" mode="validation"/>
		<xsl:apply-templates select="//qis:Program" mode="validation"/>
	</xsl:template>

	<!-- Gate -->
	<xsl:template match="qis:Gate" mode="validation">
		<!-- Gate - Initialization -->
		<xsl:variable name="gate-max-rowcol">
			<xsl:call-template name="math:power">
				<xsl:with-param name="base" select="2"/>
				<xsl:with-param name="power" select="qis:Transformation/@size"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- Gate - Information -->
		<hr/>
		<div>
			Gate <xsl:value-of select="qis:Identification/qis:ID"/>, Size <xsl:value-of select="qis:Transformation/@size"/>
		</div>
		<xsl:if test="qis:Name">
			<div><xsl:value-of select="qis:Name"/></div>
		</xsl:if>
		<xsl:if test="qis:Description">
			<div><xsl:value-of select="qis:Description"/></div>
		</xsl:if>

		<!-- Gate - Check Transformation row/col range -->
		<xsl:for-each select="qis:Transformation/qis:Cell[ (@row > $gate-max-rowcol) or @col > $gate-max-rowcol ]">
			<div style="{$validation-error-style}">ERROR: Transformation Cell <xsl:value-of select="position()"/> row=<xsl:value-of select="@row"/>/col=<xsl:value-of select="@col"/> out of Gate range.</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Circuit -->
	<xsl:template match="qis:Circuit" mode="validation">
		<hr/>
		<div>
			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="qis:Identification"><xsl:value-of select="qis:Identification/qis:ID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
				</xsl:choose>	
			</xsl:variable>
			Circuit <xsl:value-of select="$ID"/>, Size <xsl:value-of select="@size"/>, <xsl:value-of select="count(qis:Step)"/> step(s)
		</div>
		<xsl:if test="qis:Name">
			<div><xsl:value-of select="qis:Name"/></div>
		</xsl:if>
		<xsl:if test="qis:Description">
			<div><xsl:value-of select="qis:Description"/></div>
		</xsl:if>
		<div style="{$validation-indent}">
			<xsl:apply-templates select="qis:Step" mode="validation"/>
		</div>
	</xsl:template>

	<!-- Circuit Step -->
	<xsl:template match="qis:Step" mode="validation">
		<!-- Step - Initiliatzaion -->
		<xsl:variable name="circuit-size" select="../@size"/>

		<!-- Step - Information -->
		<div>Step <xsl:value-of select="position()"/>, <xsl:value-of select="count(qis:Operation)"/> operation(s)</div>
		<xsl:if test="Description">
			<div><xsl:value-of select="Description"/></div>
		</xsl:if>

		<!-- Operation - Check qubit range -->
		<xsl:for-each select="qis:Operation/qis:Map[@qubit > $circuit-size ]">
			<div style="{$validation-error-style}">ERROR: Map <xsl:value-of select="position()"/> qubit=<xsl:value-of select="@qubit"/> is out of Circuit range.</div>
		</xsl:for-each>

		<!-- Step - Check qubit count -->
		<xsl:if test="$circuit-size > count(qis:Operation/qis:Map)">
			<div style="{$validation-warning-style}">Warning: Not all qubits have been mapped.</div>
		</xsl:if>

		<!-- Step - Check duplicate qubit mapping -->
		<xsl:for-each select="qis:Operation/qis:Map">
			<xsl:variable name="qubit" select="@qubit"/>
			<xsl:variable name="qubit-count" select="count(../../qis:Operation/qis:Map[@qubit=$qubit])"/>
			<xsl:if test="$qubit-count>1">
				<div style="{$validation-error-style}">ERROR: Qubit <xsl:value-of select="$qubit"/> is ampped <xsl:value-of select="$qubit-count"/> times.</div>
			</xsl:if>
		</xsl:for-each>
		
		<!-- Validate Operation -->
		<div style="{$validation-indent}">
			<xsl:apply-templates select="qis:Operation" mode="validation"/>
		</div>
	</xsl:template>

	<!-- Circuit Step Operation -->
	<xsl:template match="qis:Operation" mode="validation">

		<!-- Operation - Check duplicate input mapping -->
		<xsl:for-each select="qis:Map">
			<xsl:variable name="input" select="@input"/>
			<xsl:variable name="input-count" select="count(../Map[@input=$input])"/>
			<xsl:if test="$input-count > 1">
				<div style="{$validation-error-style}">ERROR: Input <xsl:value-of select="$input"/> is mapped <xsl:value-of select="$input-count"/> times.</div>
			</xsl:if>
		</xsl:for-each>
	
		<xsl:choose>
			<!-- Gate based Operation -->
			<xsl:when test="qis:GateRef">
				<!-- Operation init -->
				<xsl:variable name="gate-id" select="qis:GateRef/qis:ID"/>
				<xsl:variable name="gate" select="//qis:GateLibrary/qis:Gate[qis:Identification/qis:ID = $gate-id]"/>
				<xsl:choose>
					<!-- check if Gate has been found -->
					<xsl:when test="$gate">
						<xsl:variable name="gate-size" select="$gate/qis:Transformation/@size"/>
						<!-- Display Gate Operation Info -->
						<div>
							<xsl:value-of select="position()"/>:
							<xsl:value-of select="$gate/qis:Name"/> (<xsl:value-of select="$gate-id"/>)
							<xsl:text>[</xsl:text>
							<xsl:for-each select="qis:Map">
								<xsl:if test="position()>1">,</xsl:if>
								<xsl:value-of select="@qubit"/>=<xsl:value-of select="@input"/>
							</xsl:for-each>
							<xsl:text>]</xsl:text>
						</div>
						<!-- Operation - Check Gate size and Map count -->
						<xsl:if test="not( $gate-size = count(qis:Map) )">
							<div style="{$validation-error-style}">ERROR: Gate size and mappings do not match. Gate has <xsl:value-of select="$gate-size"/> input(s), Operation specified <xsl:value-of select="count(qis:Map)"/> mapping(s).</div>
						</xsl:if>
						<!-- Operation - Check Map input range -->
						<xsl:for-each select="qis:Map[@input > $gate-size ]">
							<div style="{$validation-error-style}">ERROR: Map <xsl:value-of select="position()"/> input=<xsl:value-of select="@input"/> is out of Gate range.</div>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- Gate not found -->
						<div style="{$validation-error-style}">ERROR: Gate <xsl:value-of select="$gate-id"/> not found.</div>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="qis:CircuitRef">
				<div style="{$validation-warning-style}">Warning: Circuit based Operation validation not yet implemented.</div>
			</xsl:when>
			<xsl:when test="qis:Measurement">
				<div style="{$validation-warning-style}">Warning: Measurement based Operation validation not yet implemented.</div>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Program -->
	<xsl:template match="qis:Program" mode="validation">
		<hr/>
		<div>
			<xsl:variable name="ID">
				<xsl:choose>
					<xsl:when test="qis:Identification"><xsl:value-of select="qis:Identification/qis:ID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
				</xsl:choose>	
			</xsl:variable>
			Program <xsl:value-of select="$ID"/>, Size <xsl:value-of select="@size"/>, <xsl:value-of select="count(qis:Step)"/> step(s)
		</div>
		<xsl:if test="qis:Name">
			<div><xsl:value-of select="qis:Name"/></div>
		</xsl:if>
		<xsl:if test="qis:Description">
			<div><xsl:value-of select="qis:Description"/></div>
		</xsl:if>
		<div style="{$validation-warning-style}">Warning: Program validation not yet implemented.</div>
	</xsl:template>
</xsl:stylesheet>
