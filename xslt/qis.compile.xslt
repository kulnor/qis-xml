<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml ../xml/qis.instance1.xml?>
<!--
Overview: Basic tranform to test the Program compilers.

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
<xsl:stylesheet version="1.0"
	xmlns:qis="qis:1_1" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:math="http://exslt.org/math" 
	extension-element-prefixes="math"
	>
	<xsl:import href="qis.compile.qcl.xslt"/>
	<xsl:import href="qis.compile.qml.xslt"/>
	<xsl:import href="qis.exslt.xslt"/>

	<xsl:output omit-xml-declaration="yes" encoding="utf-8"/>

	<!-- TESTS -->
	<xsl:template match="/">
		<xsl:apply-templates select="/qis:QIS/qis:ProgramLibrary[1]/qis:Program[qis:Identification/qis:ID='two_plus_one']" mode="qml"/>
	</xsl:template>
	
</xsl:stylesheet>
