<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- Serialization details -->
    <xsl:output method="text" omit-xml-declaration="yes"/>
    
    
    <!-- Keys -->    
    <xsl:key name="rs-by-key" match="*:rs" use="@key"/>
    
    <!-- Global variables -->
    
    <xsl:variable name="collection-dirs" select="(
        (: directories with TEI files:)
        '../data/DHd-Abstracts-2016/XML-files',
        '../data/DHd-Abstracts-2017/XML-files',
        '../data/DHd-Abstracts-2018/XML-files',
        '../data/DHd-Abstracts-2019/XML-files',
        '../data/DHd-Abstracts-2020/XML-files'
        )" as="xs:string+"/>
    
    <xsl:variable name="path-to-software-list" select="'../conf/software-names.txt'" as="xs:string"/>
    
    <xsl:variable name="categories" select="('SoftwareID','Dateipfad','Name','Bib.Ref','Bib.Soft','Agent','URL','PID','Ver','Noname')" as="xs:string+"/>
    
    <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
    
    
    <!-- Templates -->
    
    <xsl:template match="/">
        
        <!-- header row -->
        <xsl:value-of select="concat($categories[1], ';', $categories[2])"/>
        <xsl:for-each select="subsequence($categories, 3)">
            <xsl:value-of select="concat(';', ., ';', ., ' (bool)')"/>
        </xsl:for-each>
        <xsl:value-of select="$NEWLINE"/>
        
        <!-- following rows -->
        <xsl:for-each select="$collection-dirs">
            <xsl:variable name="current-directory" select="substring(., 4)" as="xs:string"/>
            
            <xsl:for-each select="collection(concat(., '?select=*.xml;recurse=yes;on-error=warning'))">
                <xsl:variable name="doc" select="/"/>
                
                <xsl:for-each select="distinct-values($doc//*:rs/@key)">
                    <xsl:sort select="." order="ascending"/>
                    <xsl:variable name="current-key" select="." as="xs:string"/>
                    <xsl:variable name="rs-with-this-key" select="key('rs-by-key', $current-key, $doc)"/>
                    
                    <!-- SoftwareID and file path -->
                    <xsl:value-of select="concat($current-key, ';', $current-directory, substring-after(base-uri($doc), $current-directory))"/>
                    
                    <!-- Name instances -->
                    <xsl:variable name="count" select="count($rs-with-this-key[contains(lower-case(@ana), lower-case('#Name')) or not(contains(lower-case(@ana), lower-case('#Noname')))])" as="xs:integer"/>
                    <xsl:value-of select="concat(';', $count)"/>
                    <xsl:value-of select="concat(';', ('1'[$count &gt; 0],'0')[1])"/>
                    
                    
                    <!-- other annotations -->
                    <xsl:for-each select="subsequence($categories, 4)">
                        <xsl:variable name="count" select="count($rs-with-this-key[contains(lower-case(@ana), lower-case(concat('#',current())))])" as="xs:integer"/>
                        <xsl:value-of select="concat(';', $count)"/>
                        <xsl:value-of select="concat(';', ('1'[$count &gt; 0],'0')[1])"/>
                    </xsl:for-each>
                    
                    <xsl:value-of select="$NEWLINE"/>
                </xsl:for-each>
                
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>