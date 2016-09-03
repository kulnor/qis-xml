<?xml version="1.0" encoding="UTF-8"?>
<!--
QIS-XML compilation templates for the J programming Language (http://www.jsoftware.com)
Converts a QIS-XMl <p:Program> into J executable code

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
<xsl:stylesheet version="1.0" xmlns:i="qis:instance:1_1" xmlns:g="qis:gate:1_1" xmlns:c="qis:circuit:1_1" xmlns:p="qis:program:1_1" xmlns:r="qis:reusable:1_1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="i g c r"> 
	<xsl:variable name="_qml_version">2007.03</xsl:variable>

	<!-- Program -->
	<xsl:template match="p:Program" mode="J">
		<xsl:text>NB. =========================== &#x0a;</xsl:text>
		<xsl:text>NB. QIS-XML J Compiler v2007.04 &#x0a;</xsl:text>
		<xsl:text>NB. =========================== &#x0a;&#x0a;</xsl:text>
		<xsl:call-template name="QIS_J_Compiler_Init"/>
		<xsl:apply-templates select="p:Memory" mode="J"/>
		<xsl:apply-templates select="p:Prepare" mode="J"/>
		<xsl:apply-templates select="p:Execute" mode="J"/>
		<xsl:apply-templates select="p:Measure" mode="J"/>
	</xsl:template>

	<xsl:template name="QIS_J_Compiler_Init">
		<!-- J QIS-XML library -->
<xsl:text>
NB. one-qubit gates
hadamard_gate =: 3 : '(2 2 $ (1 % %:2) * (1 1 1 _1)) (+/ . *) (y)'
sqrtNot_gate  =: 3 : '(2 2 $ (1 % %:2) * (1 _1 1 1)) (+/ . *) (y)'
identity_gate =: 3 : '(2 2 $ (1 0 0 1)) (+/ . *) (y)'
pauliX_gate   =: 3 : '(2 2 $ (0 1 1 0)) (+/ . *) (y)'
pauliY_gate   =: 3 : '(2 2 $ (0 0j_1 0j1 0)) (+/ . *) (y)'
pauliZ_gate   =: 3 : '(2 2 $ (1 0 0 _1)) (+/ . *) (y)'
phase_gate    =: 3 : '(2 2 $ (1 0 0 0j1)) (+/ . *) (y)'
piOver8_gate  =: 3 : '(2 2 $ 1 0 0, (^o.0j0.25)) (+/ . *) (y)'
NB. two-qubit gates
cnot_gate =: 3 : '(4 4 $ 1 0 0 0  0 1 0 0  0 0 0 1  0 0 1 0) (+/ . *) (y)'
swap_gate =: 3 : '(4 4 $ 1 0 0 0  0 0 1 0  0 1 0 0  0 0 0 1) (+/ . *) (y)'
ctrlZ_gate =: 3 : '(4 4 $ 1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 -1) (+/ . *) (y)'
ctrlPhase_gate =: 3 : '(4 4 $ 1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 0j1) (+/ . *) (y)'
</xsl:text>
	</xsl:template>

	<!-- 
		p:Memory 
	-->
	<xsl:template match="p:Memory" mode="J">
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>NB. Initialize "memory" as a 2 by N matrix of 0 &#x0a;</xsl:text>
		<!-- ex: memory =: 2 3 $ (3 $ 1),(3 $ 0) -->
		<xsl:text>]shape =: 2 </xsl:text><xsl:value-of select="@size"/>
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>]memory=: shape $ ( (1{shape) $ 1),( (1{shape) $ 0)</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>

	<!-- 
		p:Prepare
	-->
	<xsl:template match="p:Prepare" mode="J">
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>NB. *** p:Prepare not yet implemented *** &#x0a;</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>

	<!-- 
		p:Execute
	-->
	<xsl:template match="p:Execute" mode="J">
		<!-- Register -->
		<xsl:choose>
			<xsl:when test="p:Register | p:RegisterRef">
				<xsl:apply-templates select="p:Register | p:RegisterRef" mode="J"/>
				<xsl:text>]register =: memory &#x0a;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- If no Register or RegisterRef is specified, use the whole memory -->
				<xsl:text>]register =: memory &#x0a;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Execution -->
		<xsl:apply-templates select="p:Circuit|p:CircuitRef" mode="J"/>
	</xsl:template>
	<!-- 
		p:Measure
	-->
	<xsl:template match="p:Measure" mode="J">
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>NB. *** p:Measure not yet implemented *** &#x0a;</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		p:Register
	-->
	<xsl:template match="p:Register" mode="J">
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>NB. *** p:Register not yet implemented *** &#x0a;</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		p:CircuitRef
	-->
	<xsl:template match="p:CircuitRef" mode="J">
		<!-- Lookup the Circuit -->
		<xsl:variable name="ID" select="./r:ID"/>
		<xsl:variable name="circuit" select="//c:Circuit[r:Identification/r:ID=$ID][1]"/>
		<xsl:choose>
			<xsl:when test="$circuit">
				<xsl:apply-templates select="$circuit" mode="J"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NB. CIRCUIT </xsl:text>
				<xsl:value-of select="$ID"/>
				<xsl:text>NOT FOUND &#x0a;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		Circuit 
	-->
	<xsl:template match="c:Circuit" mode="J">
		<!-- stepOffset: the index number of the first step (default 0) -->
		<xsl:param name="stepOffset">0</xsl:param>
		<xsl:text>NB. CIRCUIT </xsl:text>
		<xsl:choose>
			<xsl:when test="r:Idenfication"><xsl:value-of select="r:Identification/r:ID"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x0a;</xsl:text>
		<xsl:apply-templates select="c:Step" mode="J">
			<xsl:with-param name="stepOffset" select="$stepOffset"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- 
		Circuit Step
	-->
	<xsl:template match="c:Step" mode="J">
		<xsl:param name="stepOffset">0</xsl:param>
		<!-- identify step number -->
		<xsl:text>NB. STEP </xsl:text>
		<xsl:value-of select="position()"/>
		<xsl:text>&#x0a;</xsl:text>
		<!-- Step operations -->
		<xsl:apply-templates select="c:Operation" mode="J"/>
	</xsl:template>

	<!-- 
		Circuit Operation
	-->
	<xsl:template match="c:Operation" mode="J">
		<xsl:param name="stepOffset">0</xsl:param>
		<!-- identify Operation -->
		<xsl:text>NB. OPERATION </xsl:text>
		<xsl:value-of select="position()"/>
		<xsl:text>&#x0a;</xsl:text>

		<!-- Initialize the operation vector -->
		<xsl:text>]vector =: ,. </xsl:text>
		<xsl:for-each select="c:Map">
			<xsl:sort select="@input"/>
			<xsl:if test="position()>1">,</xsl:if>
			<!-- each input can come from a qubit in the register or have a fixed value -->
			<xsl:choose>
				<xsl:when test="@qubit">
					<!-- grab qubit value from register -->
					<xsl:text>(</xsl:text><xsl:value-of select="@qubit - 1"/><xsl:text> { |: register )</xsl:text>
				</xsl:when>
				<xsl:when test="@value">
					<!-- set value -->
					<xsl:choose>
						<xsl:when test="@value=1">
							<xsl:text>(0 1)</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>(1 0)</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>*** ERROR: Missing @qubitor @value in c:Map &#x0a;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:text>&#x0a;</xsl:text>
		
		<!-- <xsl:apply-templates select="c:GateRef|c:Measurement" mode="J"/> -->
		<xsl:text>&#x0a;</xsl:text>

		<!-- Copy values back to register -->

	</xsl:template>
	<!-- 
		GATE REFERENCE
	-->
	<xsl:template match="c:GateRef" mode="J">
		<xsl:variable name="gate-id" select="r:ID"/>
		<xsl:variable name="gate" select="//g:Gate[r:Identification/r:ID = $gate-id]"/>
		<xsl:choose>
			<xsl:when test="$gate">
				<xsl:apply-templates select="$gate" mode="J"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>GATE <xsl:value-of select="$gate-id"/> NOT FOUND!</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="c:Measurement" mode="J">
		<Gate Type="MEASUREMENT_Z"/>
	</xsl:template>
	<!-- 
		GATES
	-->
	<xsl:template match="g:Gate[r:Identification/r:ID='C-NOT']" mode="J">
		<xsl:text>vector =: cnot_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-S']" mode="J">
		<xsl:text>vector =: ctrlS_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-T']" mode="J">
		<xsl:text>vector =: ctrlT_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='C-Z']" mode="J">
		<xsl:text>vector =: ctrlZ_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='DEUTSCH']" mode="J">
		<xsl:comment>vector =: deutsch_gate </xsl:comment>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='FREDKIN']" mode="J">
		<xsl:text>vector =: fredkin vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='H']" mode="J">
		<xsl:text>vector =: hadamard_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='I']" mode="J">
		<xsl:text>vector =: identity_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='S']" mode="J">
		<xsl:text>vector =: S_gate vector &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SHIFT']" mode="J">
		<xsl:comment>*** SHIFT GATE NOT DIRECTLY SUPPORTED ***</xsl:comment>
		<xsl:comment>*** QML PHASE DIFFERS IN IMPLEMENTATION  ***</xsl:comment>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SQRT-NOT']" mode="J">
		<Gate Matrix="0.0,i0.0,0.707106781,i0.0 , 0.707106781,i0.0,0.0,i0.0" Type="UNITARY_1"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='SWAP']" mode="J">
		<Gate Type="SWAP"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='T']" mode="J">
		<Gate Type="T_GATE"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='TOFFOLI']" mode="J">
		<Gate Type="TOFFOLI"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='X']" mode="J">
		<Gate Type="PAULI_X"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='Y']" mode="J">
		<Gate Type="PAULI_Y"/>
	</xsl:template>
	<xsl:template match="g:Gate[r:Identification/r:ID='Z']" mode="J">
		<Gate Type="PAULI_Z"/>
	</xsl:template>
	<xsl:template match="g:Gate" mode="J">
		<xsl:comment>UNKOWN GATE</xsl:comment>
	</xsl:template>
</xsl:stylesheet>
