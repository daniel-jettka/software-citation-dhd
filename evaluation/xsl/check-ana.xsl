<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- check if the values of @ana are correct -->
    <!-- result is empty if values of //rs/@ana only contain defined values from $categories -->
    
    <!-- Serialization details -->
    <xsl:output method="text" omit-xml-declaration="yes"/>
    
    <xsl:variable name="collection-dirs" select="(
        (: directories with TEI files:)
        '../../data/DHd-Abstracts-2016/XML-files',
        '../../data/DHd-Abstracts-2017/XML-files',
        '../../data/DHd-Abstracts-2018/XML-files',
        '../../data/DHd-Abstracts-2019/XML-files',
        '../../data/DHd-Abstracts-2020/XML-files'
        )" as="xs:string+"/>
    
    <xsl:variable name="categories" select="('Bib.Ref','Bib.Soft','Agent','Ver','URL','PID')" as="xs:string+"/>
    
    <xsl:variable name="csv-separator" select="','" as="xs:string"/>
    
    <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
    
    <xsl:template match="/">
        <xsl:for-each select="$collection-dirs">
            <xsl:variable name="current-directory" select="substring(., 4)" as="xs:string"/>
            
            <xsl:for-each select="collection(concat(., '?select=*.xml;recurse=yes;on-error=warning'))">
                <xsl:variable name="doc" select="/"/>
                
                <xsl:for-each select=".//rs/@ana">
                    <xsl:variable name="ana-vals" select="tokenize(.,'\s')"/>
                    <xsl:for-each select="$ana-vals">
                        <xsl:if test="not(substring-after(.,'#') = $categories)">
                            <!-- file path -->
                            <xsl:value-of select="concat($current-directory, substring-after(base-uri($doc), $current-directory))"/>
                            <xsl:value-of select="$csv-separator"/>
                            <xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
                            <xsl:value-of select="$NEWLINE"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>