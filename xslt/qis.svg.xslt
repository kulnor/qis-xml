<?xml version="1.0" encoding="UTF-8"?>
<!--
Overview: Templates to create SVG-XML representations of QIS-XML gates and circuits

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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:qis="qis:1_1" 
	xmlns="http://www.w3.org/2000/svg"
    >

	<xsl:variable name="svg-line-style">stroke:black;stroke-width:1;stroke-opacity:1;</xsl:variable>
	<xsl:variable name="svg-line-style-input">stroke:navy;</xsl:variable>
	<xsl:variable name="svg-line-style-output">stroke:navy;</xsl:variable>
	<xsl:variable name="svg-line-style-carry-over">stroke:navy;</xsl:variable>
	<xsl:variable name="svg-rect-style">opacity:1; fill:none; stroke:black; stroke-width:1; stroke-opacity:1;</xsl:variable>
	<xsl:variable name="svg-element-width"  select="50"/>
	<xsl:variable name="svg-element-height" select="50"/>
	<xsl:variable name="svg-element-sep-x"  select="20"/>
	<xsl:variable name="svg-element-sep-y"  select="10"/>
	<xsl:variable name="svg-cell-width"     select="$svg-element-width + $svg-element-sep-x"/>
	<xsl:variable name="svg-cell-height"    select="$svg-element-height + $svg-element-sep-y"/>

	<xsl:template name="svg-circuits">
		<h2>Quantum Circuits</h2>
		<xsl:for-each select="//qis:CircuitLibrary/qis:Circuit">
			<xsl:if test="qis:Name">
				<h4><xsl:value-of select="qis:Name"/></h4>
			</xsl:if>
			<xsl:if test="qis:Description">
				<div><xsl:value-of select="qis:Description"/></div>
			</xsl:if>
			<svg width="{ (count(qis:Step) * $svg-cell-width) + $svg-element-sep-y}" height="{ (@size * $svg-cell-height) }">
				<xsl:apply-templates select="." mode="svg"/>
			</svg>
		</xsl:for-each>
		
		<h2>Gate Equivalent Circuits</h2>
		<xsl:for-each select="//qis:GateLibrary/qis:Gate/qis:EquivalentCircuit/qis:Circuit">
			<xsl:if test="../../qis:Name">
				<h4><xsl:value-of select="../../qis:Name"/></h4>
			</xsl:if>
			<xsl:if test="qis:Description">
				<div><xsl:value-of select="qis:Description"/></div>
			</xsl:if>
			<svg width="{ (count(qis:Step) * $svg-cell-width) + $svg-element-sep-y}" height="{ (@size * $svg-cell-height) }">
				<xsl:apply-templates select="." mode="svg"/>
			</svg>
		</xsl:for-each>
	</xsl:template>

	<!-- CIRCUIT -->
	<xsl:template match="qis:Circuit" mode="svg">
		<!-- 
			The circuit goes from left to right, with each step
			The height of the circuit is the number of size
		 -->
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:apply-templates select="qis:Step" mode="svg"/>
	</xsl:template>

	<!-- Circuit Step -->
	<xsl:template match="qis:Step" mode="svg">
		<!-- 
			The circuit goes from left to right, with each step
			The height of the circuit is the number of size
		 -->
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:variable name="step-offset-x" select="(position()-1) * $svg-cell-width"/>
		<!-- draw all operation -->
		<xsl:apply-templates select="qis:Operation" mode="svg">
			<xsl:with-param name="x" select="$step-offset-x"/>
			<xsl:with-param name="y" select="$y"/>
		</xsl:apply-templates>
		<!-- carry over unmapped qubits -->
		<g transform="translate({$step-offset-x},{$y})">
			<xsl:call-template name="svg-circuit-step-carry-over">
				<xsl:with-param name="qubit-number" select="../@size"/>
				<xsl:with-param name="map" select=".//qis:Map"/>
			</xsl:call-template>
		</g>
	</xsl:template>

	<!-- Circuit Step Operation -->
	<xsl:template match="qis:Operation" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:choose>
			<xsl:when test="qis:GateRef">
				<!-- this is a standard gate -->
				<xsl:variable name="gate-id" select="qis:GateRef/qis:ID"/>
				<xsl:variable name="gate" select="//qis:Gate[qis:Identification/qis:ID = $gate-id]"/>
				<xsl:choose>
					<xsl:when test="$gate">
						<xsl:apply-templates select="$gate" mode="svg">
							<!--  Gate must be shifted right to the center of the cell and allow for connectors to be drawn on the left -->
							<xsl:with-param name="x" select="$x + ($svg-element-width div 2) + $svg-element-sep-x"/>
							<!--  Gate must be shifted down to the center of the cell -->
							<xsl:with-param name="y" select="$y + ($svg-element-height div 2)"/>
							<xsl:with-param name="map" select="./qis:Map"/>
							<xsl:with-param name="reverse" select="./@reverse"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:comment>GATE <xsl:value-of select="$gate-id"/> NOT FOUND!</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="qis:Measurement">
				<!-- make a measurement for each c:Map -->
				<xsl:for-each select="qis:Map">
					<xsl:apply-templates select="../qis:Measurement" mode="svg">
						<!--  Gate must be shifted right to the center of the cell and allow for connectros to be drawn on the left -->
						<xsl:with-param name="x" select="$x + ($svg-element-width div 2) + $svg-element-sep-x"/>
						<!--  Gate must be shifted down to the center of the cell -->
						<xsl:with-param name="y" select="$y + ($svg-element-height div 2)"/>
						<xsl:with-param name="map" select="."/>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<text x="{$x}" y="{$y + 12}" style="font-size:12px; font-weight:bold;">
					[*INLINE GATE TODO*]
				</text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		MEASURE 
	 -->
	<xsl:template match="qis:Measurement" name="svg-measurement" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
			<text x="" y="11" style="font-size:30px; font-weight:bold;">[M]</text>
		</g>
	</xsl:template>

	<!-- 
		GATES SVG
		- Gate templates contain SVG instructions to draw the specific gate
		- Each template can be called by name or match
		- The "x" and "y" parameter are used to translate the gate
		- The 0,0 coordinate is at the center of the gate element
		- The $map parameter is use to pass a Map sequence to the gate to indicate 
             that is is being dr	awn in the context of a Circuit Operation Step. 
          The information in the Map is used to further translate the gate to the proper
             position in the Circuit diagram and to create connectors to qubits
	-->

	<!-- C-NOT / Controlled-NOT -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-NOT']" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<!-- control connector -->
			<line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2}" style="{$svg-line-style}"/>
			<!-- control bit -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- controlled bit -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-gate-controlled">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>
	
	<!-- C-S / CONTROLLED-PHASE -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-S']" name="svg-C-S" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<!-- control connector -->
			<xsl:choose>
				<xsl:when test="$y2 > $y1"><line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 - 20}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 + 20}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<!-- control bit -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- controlled gate -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-S">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- C-T / Controlled PI/8 -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-T']" name="svg-C-T" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<!-- control connector -->
			<xsl:choose>
				<xsl:when test="$y2 > $y1">	<line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 - 20}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 + 20}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<!-- control bit -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- controlled gate -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-T">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- C-X / Controlled-X -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-X']" name="svg-C-X" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<!-- control connector -->
			<xsl:choose>
				<xsl:when test="$y2 > $y1">	<line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 - 20}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 + 20}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<!-- control bit -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- controlled gate -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-X">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>
	
	<!-- C-Z / Controlled-Z -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-Z']" name="svg-C-Z" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<!-- control connector -->
			<xsl:choose>
				<xsl:when test="$y2 > $y1">	<line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 - 20}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2 + 20}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<!-- control bit -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- controlled gate -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-Z">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- DEUSTCH(3) -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='DEUTSCH']" name="svg-DEUTSCH" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x3" select="0"/>
		<xsl:variable name="y3">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="3"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<xsl:choose>
				<xsl:when test="$y3 > $y1"><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$y3 > $y2"><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
			<g transform="translate({$x3},{$y3})">
				<xsl:call-template name="svg-SHIFT">
					<xsl:with-param name="map" select="$map[@input=3]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- FREDKIN(3) -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='FREDKIN']" name="svg-FREDKIN" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x3" select="0"/>
		<xsl:variable name="y3">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="3"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<xsl:choose>
				<xsl:when test="$y3 > $y1"><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$y3 > $y2"><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- swap connector -->
			<line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3}" style="{$svg-line-style}"/>
			<!-- qubit 2 -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-gate-swap-qubit">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
			<!-- qubit 3 -->
			<g transform="translate({$x3},{$y3})">
				<xsl:call-template name="svg-gate-swap-qubit">
					<xsl:with-param name="map" select="$map[@input=3]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- HADAMARD -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='H']" name="svg-H" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-11" y="10" style="font-size:30px; font-weight:bold;">H</text>
		</g>
	</xsl:template>

	<!-- I / IDENTITY-->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='I']" name="svg-I" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<line x1="-{$svg-element-width div 2}" y1="{0}" x2="{$svg-element-width div 2}" y2="{0}" style="{$svg-line-style}"/>
		</g>
	</xsl:template>

	<!-- S / PHASE -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='S']" name="svg-S" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-10" y="11" style="font-size:30px; font-weight:bold; ">S</text>
		</g>
	</xsl:template>

	<!-- SHIFT / PHASE SHIFT -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SHIFT']" name="svg-SHIFT" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-15" y="6" style="font-size:16px; font-weight:bold; ">R(&#952;)</text>
		</g>
	</xsl:template>

	<!-- SQUARE ROOT OF NOT -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SQRT-NOT']" name="svg-SQRT-NOT" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-12" y="11" style="font-size:20px;">&#8730;&#172;</text>
		</g>
	</xsl:template>

	<!-- SWAP -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SWAP']" name="svg-SWAP" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<xsl:if test="$map">
				<xsl:call-template name="svg-draw-io-connectors">
					<xsl:with-param name="map" select="$map"/>
				</xsl:call-template>
			</xsl:if>
			<!-- connector -->
			<line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2}" style="{$svg-line-style}"/>
			<!-- qubit 1 -->
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-swap-qubit">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<!-- qubit 2 -->
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-gate-swap-qubit">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- T / PI/8 -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='T']" name="svg-T" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<text x="-9" y="11" style="font-size:30px; font-weight:bold; ">T</text>
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
		</g>
	</xsl:template>

	<!-- TOFFOLI -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='TOFFOLI']" name="svg-TOFFOLI" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2" select="0"/>
		<xsl:variable name="y2">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="2"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x3" select="0"/>
		<xsl:variable name="y3">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="3"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x},{$y})">
			<xsl:choose>
				<xsl:when test="$y3 > $y1"><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x1}" y1="{$y1}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$y3 > $y2"><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 - 10}" style="{$svg-line-style}"/></xsl:when>
				<xsl:otherwise><line x1="{$x2}" y1="{$y2}" x2="{$x3}" y2="{$y3 + 10}" style="{$svg-line-style}"/></xsl:otherwise>
			</xsl:choose>
			<g transform="translate({$x1},{$y1})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=1]"/>
				</xsl:call-template>
			</g>
			<g transform="translate({$x2},{$y2})">
				<xsl:call-template name="svg-gate-control">
					<xsl:with-param name="map" select="$map[@input=2]"/>
				</xsl:call-template>
			</g>
			<g transform="translate({$x3},{$y3})">
				<xsl:call-template name="svg-gate-controlled">
					<xsl:with-param name="map" select="$map[@input=3]"/>
				</xsl:call-template>
			</g>
		</g>
	</xsl:template>

	<!-- X / PAULI-X -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='X']" name="svg-X" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-11" y="10" style="font-size:30px; font-weight:bold;">X</text>
		</g>
	</xsl:template>

	<!-- Y / PAULI-Y -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Y']" name="svg-Y" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-11" y="10" style="font-size:30px; font-weight:bold;">Y</text>
		</g>
	</xsl:template>

	<!-- Z / PAULI-Z -->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Z']" name="svg-Z" mode="svg">
		<xsl:param name="x" select="0"/>
		<xsl:param name="y" select="0"/>
		<xsl:param name="map" select="Dummy"/>
		<xsl:param name="reverse" select="0"/>
		<!-- Compute coordinates -->
		<xsl:variable name="x1" select="0"/>
		<xsl:variable name="y1">
			<xsl:call-template name="svg-compute-input-y">
				<xsl:with-param name="input-number" select="1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Draw -->
		<g transform="translate({$x + $x1},{$y + $y1})">
			<xsl:call-template name="svg-gate-box">
				<xsl:with-param name="map" select="$map"/>
				<xsl:with-param name="reverse" select="$reverse"/>
			</xsl:call-template>
			<text x="-9" y="11" style="font-size:30px; font-weight:bold;">Z</text>
		</g>
	</xsl:template>

	<!-- CATCH ALL -->
	<xsl:template match="qis:Gate" mode="svg"/>

	<!-- GATE BOX (40x40 with 10 px shift) (can float) 
		Draws a single qubit gate box 
		If a $map is specified, adds i/o connectors
		If a $reverse is tru, adds dagger sign in the top right corner
	-->
	<xsl:template name="svg-gate-box">
		<xsl:param name="map"/>
		<xsl:param name="reverse" select="0"/>
		<!-- i/o -->
		<xsl:if test="$map">
			<xsl:call-template name="svg-draw-io-connectors">
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:if>
		<!-- gate -->
		<line x1="-25" y1="0" x2="-20" y2="0" style="{$svg-line-style}"/>
		<rect x="-20" y="-20" width="40" height="40" style="{$svg-rect-style}"/>
		<line x1="20" y1="0" x2="25" y2="0" style="{$svg-line-style}"/>
		<xsl:if test="$reverse">
			<!-- this operation is reversed, add the dagger sign on the gate first input -->
			<text x="12" y="-8" style="font-size:12px; font-weight:bold;">&#8224;</text>
		</xsl:if>
	</xsl:template>

	<!-- CONTROL  (can float) 
		Draws a small filled circle to represent a control qubit
		If a $mmap is specified, adds i/o connectors
	-->
	<xsl:template name="svg-gate-control">
		<xsl:param name="map"/>
		<!-- i/o -->
		<xsl:if test="$map">
			<xsl:call-template name="svg-draw-io-connectors">
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:if>
		<!-- gate -->
		<line x1="-{$svg-element-width div 2}" y1="0" x2="{$svg-element-width div 2}" y2="0" style="{$svg-line-style}"/>
		<circle cx="0" cy="0" r="5" style="fill:black;"/>
	</xsl:template>

	<!-- 
		CONTROLLED CIRCLE (can float)
		Draws a circle with a plus sign to represent a controlled qubit
		If a $mmap is specified, adds i/o connectors
	-->
	<xsl:template name="svg-gate-controlled">
		<xsl:param name="map"/>
		<!-- i/o -->
		<xsl:if test="$map">
			<xsl:call-template name="svg-draw-io-connectors">
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:if>
		<!-- gate -->
		<line x1="-25" y1="0" x2="25" y2="0" style="{$svg-line-style}"/>
		<circle cx="0" cy="0" r="10" style="fill:none; stroke:black; stroke-width:1;"/>
		<line x1="0" y1="10" x2="0" y2="-10" style="{$svg-line-style}"/>
	</xsl:template>

	<!-- SWAP (can float) 
		Draws a cross to represent a swap qubit
		If a $mmap is specified, adds i/o connectors
	-->
	<xsl:template name="svg-gate-swap-qubit">
		<xsl:param name="map"/>
		<!-- i/o -->
		<xsl:if test="$map">
			<xsl:call-template name="svg-draw-io-connectors">
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:if>
		<!-- gate -->
		<line x1="-{$svg-element-width div 2}" y1="0" x2="{$svg-element-width div 2}" y2="0" style="{$svg-line-style}"/>
		<line x1="-5" y1="-5" x2="+5" y2="+5" style="{$svg-line-style}"/>
		<line x1="-5" y1="+5" x2="+5" y2="-5" style="{$svg-line-style}"/>
	</xsl:template>

	<!--
		COMPUTE INPUT Y
		Compute Y offset for floatable Gate and Circuit inputs
	-->
	<xsl:template name="svg-compute-input-y">
		<xsl:param name="input-number" select="1"/>
		<xsl:param name="map" select="Dummy"/>
		<!-- see if this input needs to be aligned on a specific qubit -->
		<xsl:choose>
			<xsl:when test="$map[@input=$input-number]">
				<!-- a map is specified for this input, shift to qubit level -->
				<xsl:value-of select=" ( ($map[@input=$input-number]/@qubit) - 1)* $svg-cell-height"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- use standard position -->
				<xsl:value-of select="($input-number - 1)* $svg-cell-height"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		DRAW INPUTS/OUTPUT CONNECTORS
		Draw inputs connectors for a gate or a circuit
	-->
	<xsl:template name="svg-draw-io-connectors">
		<xsl:param name="map"/>
		<xsl:choose>
			<xsl:when test="$map[@value]">
				<text x="-{($svg-element-sep-x div 2)+($svg-element-width div 2)}" y="4" style="font-size:8pt;">|<xsl:value-of select="$map/@value"/>&gt;</text>
			</xsl:when>
			<xsl:otherwise>
				<line x1="-{($svg-element-sep-x div 2)+($svg-element-width div 2)}" y1="0" x2="-{$svg-element-width div 2}" y2="0" style="{$svg-line-style-input}"/>
			</xsl:otherwise>
		</xsl:choose>
		<line x1="+{($svg-element-sep-x div 2)+($svg-element-width div 2)}" y1="0" x2="+{$svg-element-width div 2}" y2="0" style="{$svg-line-style-output}"/>
	</xsl:template>

	<xsl:template name="svg-circuit-step-carry-over">
		<xsl:param name="qubit-number" select="0"/>
		<xsl:param name="map"/>
		<!-- call this template recursively until we have processed all qubits -->
		<xsl:if test="$qubit-number > 1">
			<xsl:call-template name="svg-circuit-step-carry-over">
				<xsl:with-param name="qubit-number" select="$qubit-number -1"/>
				<xsl:with-param name="map" select="$map"/>
			</xsl:call-template>
		</xsl:if>
		<!-- if no map is found for this qubit, carry over -->
		<xsl:if test="not( $map[@qubit=$qubit-number] )">
			<xsl:variable name="offset-x" select=" $svg-element-sep-x div 2 "/>
			<xsl:variable name="offset-y" select=" ( ($qubit-number - 1) * $svg-cell-height) + ($svg-element-height div 2)"/>
			<line x1="{$offset-x}" y1="{$offset-y}" x2="{$svg-cell-width + ($svg-element-sep-x div 2)}" y2="{$offset-y}" style="{$svg-line-style-carry-over}"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
