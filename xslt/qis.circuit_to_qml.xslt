<?xml version="1.0" encoding="UTF-8"?>
<!--
Takes an QIS instance as input and transforms the specified Circuit to QML
If no parameters are provided, the first circuit that is found is used


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
	xmlns:qis="qis:1_1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="qis"> 
	<xsl:import href="qis.svg.xslt"/>
	<xsl:param name="p_libraryID"></xsl:param>
	<!-- The library identifier -->
	<xsl:param name="p_circuitID"></xsl:param>
	<!-- The circuit identifier -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="normalize-space($p_libraryID)">
				<xsl:choose>
					<xsl:when test="normalize-space($p_circuitID)">
						<xsl:apply-templates select="/qis:QIS/qis:CircuitLibrary[qis:Identification/qis:ID=$p_libraryID]/qis:Circuit[qis:Identification/qis:ID=$p_circuitID]" mode="qml"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="/qis:QIS/qis:CircuitLibrary[qis:Identification/qis:ID=$p_libraryID]/qis:Circuit[1]" mode="qml"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="normalize-space($p_circuitID)">
				<xsl:apply-templates select="/qis:QIS/qis:CircuitLibrary[1]/qis:Circuit[qis:Identification/qis:ID=$p_circuitID]" mode="qml"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="/qis:QIS/qis:CircuitLibrary[1]/qis:Circuit[1]" mode="qml"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- 
		CIRCUIT 
	-->
	<xsl:template match="qis:Circuit" mode="qml">
		<QML>
			<!--
			<Job Id="http://www.qc.fraunhofer.de/Members/kulnor/qcjobs/kulnor.2007-03-18-1854.qml">
				<Date Performed="0" Requested="1174256361143"/>
				<Status Info="1174256361143CREATED" Current="CREATED" Error="NONE"/>
				<Method Threshold="0.0050" Performed="NONE" Requested="AUTO"/>
				<Computation RunTime="0" QueueTime="NONE" Cpus="0" Accuracy="1.0" MBytes="0" EstimatedTime="0"/>
			</Job>
			-->
			<Circuit Name="default" Size="{@size}" Id="default.qml" Description="{qis:Description}">
				<!-- for some reason, always leave operation 0 empty -->
				<Operation Step="0">
				</Operation>
				<xsl:apply-templates select="qis:Step" mode="qml"/>
			</Circuit>
			<!--
			<CircuitLib>
			</CircuitLib>
			<GateLib>
				<Gate Type="IDENT"/>
				<Gate Type="PAULI_X"/>
				<Gate Type="PAULI_Y"/>
				<Gate Type="PAULI_Z"/>
				<Gate Type="HADAMARD"/>
				<Gate Type="RX"/>
				<Gate Type="RY"/>
				<Gate Type="_RX"/>
				<Gate Type="_RY"/>
				<Gate Type="T_GATE"/>
				<Gate Type="S_GATE"/>
				<Gate Type="PHASE" Divisions="1"/>
				<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0" Type="UNITARY_1"/>
				<Gate Type="CNOT"/>
				<Gate Type="SWAP"/>
				<Gate Type="CPHASE" Divisions="1"/>
				<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0" Type="UNITARY_2"/>
				<Gate Type="TOFFOLI"/>
				<Gate Type="FREDKIN"/>
				<Gate Size="2" Type="ORACLE" BasisState="0x255"/>
				<Gate Size="2" Type="GROVER" Steps="1" BasisState="0x1"/>
				<Gate Size="2" Type="GROVER_STEP" BasisState="0x255"/>
				<Gate Modulus="1" Size="3" Type="MODULO" Base="1" Index="1"/>
				<Gate Size="2" Type="EXP" Duration="0.25">
					<HTerm Matrix="0.0,0.0,1.0" Index="0"/>
					<HTerm Matrix="0.0,0.0,1.0" Index="1"/>
					<HTerm Matrix="0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0" Index="0,1"/>
				</Gate>
				<Gate Size="2" Type="REVERSE"/>
				<Gate Size="2" Type="QFT"/>
				<Gate Type="PREPARATION" Probability="1.0"/>
				<Gate Type="MEASUREMENT_Z"/>
				<Gate Size="2" Type="CIRCUIT"/>
				<Gate P1="0.5" Size="2" P0="0.5" Type="RANDOM" CaseSize="1"/>
			</GateLib>
			-->
		</QML>
	</xsl:template>
	
	<!-- 
		Circuit Step = Operation
	-->
	<xsl:template match="qis:Step" mode="qml">
		<!-- in QML a Step is an Operation with a zero-based @Step number as attribute -->
		<Operation Step="{position()}">
			<xsl:apply-templates select="qis:Operation" mode="qml"/>
		</Operation>
	</xsl:template>

	<!-- 
		Circuit Operation = Application
	-->
	<xsl:template match="qis:Operation" mode="qml">
		<!-- In QML a Operation is an Application with a @Name, @Id and @Bits attrbutes -->
		<!-- The @Name seem to always be "G" 
			 The @Id is a zero based counter for the whole circuit (setting to 0 would work as well)
			The Bits correspond to the c:Map in @input order.
		-->
		<Application Name="G" Id="0">
			<xsl:attribute name="Bits">
				<xsl:for-each select="qis:Map">
					<xsl:sort select="@input"/>
					<xsl:if test="position()>1">,</xsl:if>
					<xsl:value-of select="@qubit - 1"/> <!-- QML is zero-based , QIS is one-based -->
				</xsl:for-each>
			</xsl:attribute>
			<xsl:apply-templates select="qis:GateRef|qis:Measurement" mode="qml"/>
		</Application>
	</xsl:template>
	<!-- 
		OPERATIONS
	-->
	<xsl:template match="qis:GateRef" mode="qml">
		<xsl:variable name="gate-id" select="qis:ID"/>
		<xsl:variable name="gate" select="//qis:Gate[qis:Identification/qis:ID = $gate-id]"/>
		<xsl:choose>
			<xsl:when test="$gate">
				<xsl:apply-templates select="$gate" mode="qml"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>GATE <xsl:value-of select="$gate-id"/> NOT FOUND!</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="qis:Measurement" mode="qml">
		<Gate Type="MEASUREMENT_Z"/>
	</xsl:template>
	<!-- 
		GATES
	-->
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-NOT']" mode="qml">
		<Gate Type="CNOT"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-S']" mode="qml">
		<xsl:comment>*** C_S GATE NOT DIRECTLY SUPPORTED ***</xsl:comment>
		<xsl:comment>*** QML CPHASE DIFFESR IN IMPLEMENTATION  ***</xsl:comment>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-T']" mode="qml">
		<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.707106781,i0.707106781" Type="UNITARY_2"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='C-Z']" mode="qml">
		<Gate Matrix="1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,1.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,0.0,i0.0,-1.0,i0.0" Type="UNITARY_2"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='DEUTSCH']" mode="qml">
		<xsl:comment>*** DEUTSCH GATE NOT SUPPORTED ***</xsl:comment>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='FREDKIN']" mode="qml">
		<Gate Type="FREDKIN"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='H']" mode="qml">
		<Gate Type="HADAMARD"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='I']" mode="qml">
		<Gate Type="IDENT"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='S']" mode="qml">
		<Gate Type="S_GATE"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SHIFT']" mode="qml">
		<xsl:comment>*** SHIFT GATE NOT DIRECTLY SUPPORTED ***</xsl:comment>
		<xsl:comment>*** QML PHASE DIFFERS IN IMPLEMENTATION  ***</xsl:comment>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SQRT-NOT']" mode="qml">
		<Gate Matrix="0.0,i0.0,0.707106781,i0.0,0.707106781,i0.0,0.0,i0.0" Type="UNITARY_1"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='SWAP']" mode="qml">
		<Gate Type="SWAP"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='T']" mode="qml">
		<Gate Type="T_GATE"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='TOFFOLI']" mode="qml">
		<Gate Type="TOFFOLI"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='X']" mode="qml">
		<Gate Type="PAULI_X"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Y']" mode="qml">
		<Gate Type="PAULI_Y"/>
	</xsl:template>
	<xsl:template match="qis:Gate[qis:Identification/qis:ID='Z']" mode="qml">
		<Gate Type="PAULI_Z"/>
	</xsl:template>
	<xsl:template match="qis:Gate" mode="qml">
		<xsl:comment>UNKOWN GATE</xsl:comment>
	</xsl:template>
</xsl:stylesheet>
