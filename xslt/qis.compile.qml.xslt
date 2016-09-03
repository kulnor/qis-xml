<?xml version="1.0" encoding="UTF-8"?>
<!--
Compilation templates for the Fraunhofer Quantum Computing Simulator QML-XML

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
	xmlns:p="qis:program:1_1" 
	xmlns:r="qis:reusable:1_1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="i g c p r"
	> 
	<xsl:variable name="_qml_version">2007.03</xsl:variable>

	<!-- Program -->
	<xsl:template match="p:Program" mode="qml">
		<xsl:comment> ============================= </xsl:comment>
		<xsl:comment> QIS-XML QML Compiler v2007.04 </xsl:comment>
		<xsl:comment> ============================= </xsl:comment>
		<QML>
			<Circuit Name="default" Size="{p:Memory/@size}" Id="default.qml" Description="{p:Description}">
				<!-- for some reason, always leave operation 0 empty -->
				<Operation Step="0">
				</Operation>
				<!-- p:Register not supported at this level -->
				<xsl:apply-templates select="p:Execute" mode="qml"/>
				<!-- p:Measure not supported -->
			</Circuit>
		</QML>
	</xsl:template>

	<!-- Execute -->
	<xsl:template match="p:Execute" mode="qml">
		<xsl:param name="stepOffset">1</xsl:param>
		<xsl:choose>
			<xsl:when test="p:Register/p:Prepare/p:QubitSet[p:Value/@r=1]">
				<!-- initialize qubits to |1> (only operation supported) -->
				<xsl:for-each select="p:Register/p:Prepare/p:QubitSet[p:Value/@r=1]">
					<Operation Step="{$stepOffset}">
						<xsl:for-each select="p:QubitIndex">
							<Application Name="G" Id="0" Bits="{. - 1}">
								<Gate Type="PAULI_X"/>
							</Application>
						</xsl:for-each>
					</Operation>
				</xsl:for-each>
				<!-- generate circuit with stepOffset+1 -->
				<xsl:apply-templates select="p:Circuit|p:CircuitRef" mode="qml">
					<xsl:with-param name="stepOffset" select="$stepOffset + 1"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<!-- generate circuit -->
				<xsl:apply-templates select="p:Circuit|p:CircuitRef" mode="qml">
					<xsl:with-param name="stepOffset" select="$stepOffset"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		p:CircuitRef
	-->
	<xsl:template match="p:CircuitRef" mode="qml">
		<xsl:param name="stepOffset">0</xsl:param>
		<!-- Lookup the Circuit -->
		<xsl:variable name="ID" select="./r:ID"/>
		<xsl:variable name="circuit" select="//c:Circuit[r:Identification/r:ID=$ID][1]"/>
		<xsl:choose>
			<xsl:when test="$circuit">
				<xsl:apply-templates select="$circuit" mode="qml">
					<xsl:with-param name="stepOffset" select="$stepOffset"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>CIRCUIT <xsl:value-of select="$ID"/> NOT FOUND</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		c:Circuit 
	-->
	<xsl:template match="c:Circuit" mode="qml">
		<!-- stepOffset: the index number of the first step (default 0) -->
		<xsl:param name="stepOffset">0</xsl:param>
		<xsl:apply-templates select="c:Step" mode="qml">
			<xsl:with-param name="stepOffset" select="$stepOffset"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- 
		Circuit Step = Operation
	-->
	<xsl:template match="c:Step" mode="qml">
		<xsl:param name="stepOffset">0</xsl:param>
		<!-- in QML a Step is an Operation with a zero-based @Step number as attribute -->
		<Operation Step="{position()-1+$stepOffset}">
			<xsl:apply-templates select="c:Operation" mode="qml"/>
		</Operation>
	</xsl:template>

	<!-- 
		Circuit Operation = Application
	-->
	<xsl:template match="c:Operation" mode="qml">
		<!-- In QML a Operation is an Application with a @Name, @Id and @Bits attrbutes -->
		<!-- The @Name seem to always be "G" 
			 The @Id is a zero based counter for the whole circuit (setting to 0 would work as well)
			The Bits correspond to the c:Map in @input order.
		-->
		<Application Name="G" Id="0">
			<xsl:attribute name="Bits">
				<xsl:for-each select="c:Map">
					<xsl:sort select="@input"/>
					<xsl:if test="position()>1">,</xsl:if>
					<xsl:value-of select="@qubit - 1"/> <!-- QML is zero-based , QIS is one-based -->
				</xsl:for-each>
			</xsl:attribute>
			<xsl:apply-templates select="c:GateRef|c:Measurement" mode="qml"/>
		</Application>
	</xsl:template>
	<!-- 
		OPERATIONS
	-->
	<xsl:template match="c:GateRef" mode="qml">
		<xsl:variable name="gate-id" select="r:ID"/>
		<xsl:variable name="gate" select="//g:Gate[r:Identification/r:ID = $gate-id]"/>
		<xsl:choose>
			<xsl:when test="$gate">
				<xsl:apply-templates select="$gate" mode="qml"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>GATE <xsl:value-of select="$gate-id"/> NOT FOUND!</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="c:Measurement" mode="qml">
		<Gate Type="MEASUREMENT_Z"/>
	</xsl:template>
	<!-- 
		GATES
	-->
	<xsl:template match="g:Gate[r:Identification/r:ID='C-NOT']" mode="qml">
		<Gate Type="CNOT"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-S']" mode="qml">
		<xsl:comment>*** C_S GATE NOT DIRECTLY SUPPORTED ***</xsl:comment>
		<xsl:comment>*** QML CPHASE DIFFERS IN IMPLEMENTATION  ***</xsl:comment>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-T']" mode="qml">
		<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0 , 0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0 , 0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0 , 0.0,i0.0,0.0,i0.0,0.0,i0.0,0.707106781,i0.707106781" Type="UNITARY_2"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-Z']" mode="qml">
		<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0 , 0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0 , 0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0 , 0.0,i0.0,0.0,i0.0,0.0,i0.0,-1.0,i0.0" Type="UNITARY_2"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='DEUTSCH']" mode="qml">
		<xsl:comment>*** DEUTSCH GATE NOT SUPPORTED ***</xsl:comment>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='FREDKIN']" mode="qml">
		<Gate Type="FREDKIN"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='H']" mode="qml">
		<Gate Type="HADAMARD"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='I']" mode="qml">
		<Gate Type="IDENT"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='S']" mode="qml">
		<Gate Type="S_GATE"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SHIFT']" mode="qml">
		<xsl:comment>*** SHIFT GATE NOT DIRECTLY SUPPORTED ***</xsl:comment>
		<xsl:comment>*** QML PHASE DIFFERS IN IMPLEMENTATION  ***</xsl:comment>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SQRT-NOT']" mode="qml">
		<Gate Matrix="0.0,i0.0,0.707106781,i0.0 , 0.707106781,i0.0,0.0,i0.0" Type="UNITARY_1"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SWAP']" mode="qml">
		<Gate Type="SWAP"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='T']" mode="qml">
		<Gate Type="T_GATE"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='TOFFOLI']" mode="qml">
		<Gate Type="TOFFOLI"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='X']" mode="qml">
		<Gate Type="PAULI_X"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='Y']" mode="qml">
		<Gate Type="PAULI_Y"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='Z']" mode="qml">
		<Gate Type="PAULI_Z"/>
	</xsl:template>
	<xsl:template match="g:Gate" mode="qml">
		<xsl:comment>UNKOWN GATE</xsl:comment>
	</xsl:template>
</xsl:stylesheet>
