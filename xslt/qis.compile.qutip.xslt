<?xml version="1.0" encoding="UTF-8"?>
<!--
QIS-XML compilation templates for Python QuTiP 
Converts a QIS-XML 1.1 into QCL executable code

Author: Pascal Heus (pascal.heus@gmail.com)
Version: 2016.09
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
	exclude-result-prefixes="qis"
	> 
	<xsl:variable name="_qutip_compiler_version">2016.09</xsl:variable>

	<!-- Program -->
	<xsl:template match="qis:Program" mode="qutip">
		<xsl:text>// ============================= &#x0a;</xsl:text>
		<xsl:text>// QIS-XML QCL Compiler v2007.04 &#x0a;</xsl:text>
		<xsl:text>// ============================= &#x0a;&#x0a;</xsl:text>
		<!-- global variables -->
		<xsl:text>int i; &#x0a;</xsl:text>
		<xsl:text>int value; &#x0a;</xsl:text>
		<!-- TODO: generate all the circuits references by the program as new QCL functions -->
		<xsl:apply-templates select="qis:Memory" mode="qcl"/>
		<!-- p:Register not supported at this level -->
		<xsl:apply-templates select="qis:Execute" mode="qcl"/>
		<xsl:apply-templates select="qis:Measure" mode="qcl"/>
		<!-- measure the memory -->
		<xsl:text>// MEASUREMENT &#x0a;</xsl:text>
		<xsl:text>for i=0 to </xsl:text><xsl:value-of select="qis:Memory/@size - 1"/><xsl:text>{ &#x0a;</xsl:text>
		<xsl:text>   measure memory[i],value; &#x0a;</xsl:text>
		<xsl:text>   print i,"=",value; &#x0a;</xsl:text>
		<xsl:text>}  &#x0a;</xsl:text>
	</xsl:template>

	<!-- 
		p:Memory 
	-->
	<xsl:template match="qis:Memory" mode="qutip">
		<xsl:text>// Allocate program memory &#x0a;</xsl:text>
		<xsl:text>qureg memory[</xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text>]; &#x0a;</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>

	<!-- 
		p:Prepare
	-->
	<xsl:template match="qis:Prepare" mode="qutip">
		<xsl:param name="register"/>
		<xsl:text>// PREPARE &#x0a;</xsl:text>
		<xsl:for-each select="qis:QubitSet">
			<xsl:choose>
				<xsl:when test="qis:Value/@r=0 or qis:Value/@r=1 and not(qis:Value/@i)">
					<xsl:variable name="value" select="qis:Value/@r"/>
					<xsl:text>i = </xsl:text><xsl:value-of select="$value"/><xsl:text>; &#x0a;</xsl:text>
					<xsl:for-each select="qis:QubitIndex">
						<xsl:variable name="qubitRef" select="concat('register',$register,'[',(. - 1),']')"/>
						<!-- in QCL, we simply measure the qubit 9force into 0 or 1) and swap it is not the cortrect value -->
						<!-- the following line generates: measure register[0],value; -->
						<xsl:text>measure </xsl:text><xsl:value-of select="$qubitRef"/><xsl:text>,value; &#x0a;</xsl:text>
						<!-- the following line generates: if value != 0 { X(register[0]) } -->
						<xsl:text>if value != </xsl:text><xsl:value-of select="$value"/><xsl:text> { X(</xsl:text><xsl:value-of select="$qubitRef"/><xsl:text>); } &#x0a;</xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>// ERROR: Only real value 1 or 0 are supported in QubitSet &#x0a;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- 
		p:Execute
	-->
	<xsl:template match="qis:Execute" mode="qutip">
		<!-- Register -->
		<xsl:choose>
			<xsl:when test="qis:Register | qis:RegisterRef">
				<xsl:apply-templates select="qis:Register | qis:RegisterRef" mode="qcl"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- If no Register or RegisterRef is specified, use the whole memory -->
				<xsl:text>qureg register</xsl:text><xsl:value-of select="generate-id()"/><xsl:text> = memory; &#x0a;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Execution -->
		<xsl:apply-templates select="qis:Circuit|qis:CircuitRef" mode="qcl">
			<xsl:with-param name="register" select="concat('register',generate-id())"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- 
		p:Measure
	-->
	<xsl:template match="qis:Measure" mode="qutip">
		<xsl:text>&#x0a;</xsl:text>
		<xsl:text>// *** p:Measure not yet implemented *** &#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		p:Register
	-->
	<xsl:template match="qis:Register" mode="qutip">
		<xsl:text>// WARNING: p:Register not fully implemented *** &#x0a;</xsl:text>
		<!-- use id of parent element -->
		<xsl:text>qureg register</xsl:text><xsl:value-of select="generate-id(..)"/><xsl:text> = memory; &#x0a;</xsl:text>
		<xsl:apply-templates select="qis:Prepare" mode="qcl">
			<xsl:with-param name="register" select="generate-id(..)"/>
		</xsl:apply-templates>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		p:CircuitRef
	-->
	<xsl:template match="qis:CircuitRef" mode="qutip">
		<xsl:param name="register"/>
		<!-- Lookup the Circuit -->
		<xsl:variable name="ID" select="./qis:ID"/>
		<xsl:variable name="circuit" select="//qis:Circuit[qis:Identification/qis:ID=$ID][1]"/>
		<xsl:choose>
			<xsl:when test="$circuit">
				<xsl:apply-templates select="$circuit" mode="qcl">
					<xsl:with-param name="register" select="$register"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>// CIRCUIT </xsl:text>
				<xsl:value-of select="$ID"/>
				<xsl:text>NOT FOUND &#x0a;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		Circuit 
	-->
	<xsl:template match="qis:Circuit" mode="qutip">
		<xsl:param name="register"/>
		<!-- stepOffset: the index number of the first step (default 0) -->
		<xsl:param name="stepOffset">0</xsl:param>
		<!-- identify the circuit -->
		<xsl:text>// CIRCUIT </xsl:text>
		<xsl:choose>
			<xsl:when test="qis:Identification"><xsl:value-of select="qis:Identification/qis:ID"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#x0a;</xsl:text>
		<!-- process c:Steps -->
		<xsl:apply-templates select="qis:Step" mode="qcl">
			<xsl:with-param name="stepOffset" select="$stepOffset"/>
			<xsl:with-param name="register" select="$register"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- 
		Circuit Step
	-->
	<xsl:template match="qis:Step" mode="qutip">
		<xsl:param name="stepOffset">0</xsl:param>
		<xsl:param name="register"/>
		<!-- identify step number -->
		<xsl:text>// STEP </xsl:text>
		<xsl:value-of select="position()"/>
		<xsl:text>&#x0a;</xsl:text>
		<!-- Step operations -->
		<xsl:apply-templates select="qis:Operation" mode="qcl">
			<xsl:with-param name="register" select="$register"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- 
		Circuit Operation
	-->
	<xsl:template match="qis:Operation" mode="qutip">
		<xsl:param name="stepOffset">0</xsl:param>
		<xsl:param name="register"/>
		<!-- identify Operation -->
		<xsl:text>// OPERATION </xsl:text>
		<xsl:value-of select="position()"/>
		<xsl:text>&#x0a;</xsl:text>

		<!-- Initialize the operation vector -->
		<xsl:text>qureg register</xsl:text><xsl:value-of select="generate-id()"/><xsl:text> = </xsl:text>
		<xsl:for-each select="qis:Map">
			<xsl:sort select="@input"/>
			<xsl:if test="position()>1"><xsl:text disable-output-escaping="yes">&amp;</xsl:text></xsl:if>
			<!-- each input can come from a qubit in the register or have a fixed value -->
			<xsl:choose>
				<xsl:when test="@qubit">
					<!-- grab qubit value from the register -->
					<xsl:value-of select="$register"/><xsl:text>[</xsl:text><xsl:value-of select="@qubit - 1"/><xsl:text>]</xsl:text>
				</xsl:when>
				<xsl:when test="@value">
					<!-- set value -->
					<xsl:text>*** ERROR: Map @input fixed @value not supported  &#x0a;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>*** ERROR: Missing @qubit or @value in c:Map &#x0a;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:text>; &#x0a;</xsl:text>
		
		<!-- Process Gate/Circuit/Measurement -->
		<xsl:apply-templates select="qis:GateRef|qis:Measurement" mode="qcl"/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		GATE REFERENCE
	-->
	<xsl:template match="qis:GateRef" mode="qutip">
		<xsl:variable name="gate-id" select="qis:ID"/>
		<xsl:variable name="gate" select="//qis:Gate[qis:Identification/qis:ID = $gate-id]"/>
		<xsl:choose>
			<xsl:when test="$gate">
				<xsl:apply-templates select="$gate" mode="qcl">
					<xsl:with-param name="register" select="concat('register',generate-id(..))"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>GATE <xsl:value-of select="$gate-id"/> NOT FOUND!</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 
		Measurement 
	-->
	<xsl:template match="qis:Measurement" mode="qutip">
		<xsl:text>// ERROR: Measurement not implemented &#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		GATES
	-->
	<!-- 
		1-qubit gates 
	-->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='H']" mode="qcl">
		<xsl:text>H(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='I']" mode="qcl">
		<xsl:text>// IDENTITY gate &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='S']" mode="qcl">
		<xsl:text>S(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SQRT-NOT']" mode="qcl">
		<xsl:text>// ERROR: SQRT-NOT gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='T']" mode="qcl">
		<xsl:text>T(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='X']" mode="qcl">
		<xsl:text>X(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Y']" mode="qcl">
		<xsl:text>Y(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Z']" mode="qcl">
		<xsl:text>Z(subregister); &#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		2-qubit gates 
	-->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-NOT']" mode="qcl">
		<xsl:param name="register"/>
		<xsl:variable name="command" select="concat('CNot(',$register,'[1],',$register,'[0]);')"/>
		<xsl:value-of select="$command"/><xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-S']" mode="qcl">
		<xsl:text>// ERROR: C-S gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-T']" mode="qcl">
		<xsl:text>// ERROR: C-T gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-Z']" mode="qcl">
		<xsl:text>// ERROR: C-Z gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SWAP']" mode="qcl">
		<xsl:text>Swap(subregister[0],subregister[1]); &#x0a;</xsl:text>
	</xsl:template>
	<!-- 
		3-qubit gates 
	-->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='DEUTSCH']" mode="qcl">
		<xsl:text>// ERROR: DEUTSCH gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='FREDKIN']" mode="qcl">
		<xsl:text>// ERROR: FREDKIN gate not implemented &#x0a;</xsl:text>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='TOFFOLI']" mode="qcl">
		<xsl:param name="register"/>
		<xsl:text>CNot(</xsl:text>
		<xsl:value-of select="$register"/>
		<xsl:text>[2] , </xsl:text>
		<xsl:value-of select="$register"/>
		<xsl:text disable-output-escaping="yes">[0] &amp; </xsl:text>
		<xsl:value-of select="$register"/>
		<xsl:text>[1]);</xsl:text>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
	<!--
		catch all gate
	-->
	<xsl:template match="qis:Gate" mode="qutip">
		<xsl:comment>UNKOWN GATE</xsl:comment>
		<xsl:text>// WARNING: Unknown Gate </xsl:text>
		<xsl:value-of select="qis:Identification/qis:ID"/>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
