<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tc="http://www.dspin.de/data/textcorpus"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="text" omit-xml-declaration="1"/>
    
    <xsl:key name="token-by-id" match="tc:token" use="@ID"/>
    
    <xsl:param name="type" select="'software-names'" as="xs:string"/><!-- possible types to count: named-entity, token, sentence, software-names -->
    <xsl:param name="file-type" select="'XML'" as="xs:string"/><!-- possible file types to analyze: XML (for TEI), TCF -->
    
    
    <!-- Global variables -->
    
    <xsl:variable name="collection-dirs" select="(
        (: directories with PDF types:)
        '../data/DHd-Abstracts-2016/TCF-files',
        '../data/DHd-Abstracts-2017/TCF-files',
        '../data/DHd-Abstracts-2018/TCF-files',
        '../data/DHd-Abstracts-2019/TCF-files',
        '../data/DHd-Abstracts-2020/TCF-files',
        (: directroies with TEI files:)
        '../data/DHd-Abstracts-2016/XML-files',
        '../data/DHd-Abstracts-2017/XML-files',
        '../data/DHd-Abstracts-2018/XML-files',
        '../data/DHd-Abstracts-2019/XML-files',
        '../data/DHd-Abstracts-2020/XML-files'
        )[contains(., $file-type)]" as="xs:string+"/>
    
    <xsl:variable name="path-to-software-list" select="'../conf/software-names.txt'" as="xs:string"/>
    
    <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
    
    
    <!-- Templates -->
    
    <xsl:template match="/">
        
        <xsl:variable name="all-instances" as="element(i)+">
            <xsl:for-each select="$collection-dirs">                
                <xsl:for-each select="collection(concat(., '?select=*.xml;recurse=yes;on-error=warning'))">
                    <xsl:variable name="doc" select="/"/>
                    <xsl:choose>
                        <!-- collect named entities -->
                        <xsl:when test="$type='named-entity'">                            
                            <xsl:for-each select="//tc:entity">
                                <i><xsl:value-of select="concat(string-join(key('token-by-id', tokenize(@tokenIDs, ' ')), ' '), ';', @class)"/></i>                    
                            </xsl:for-each>
                        </xsl:when>
                        <!-- collect all tokens -->
                        <xsl:when test="$type='token'">
                            <xsl:for-each select="//tc:token">
                                <i><xsl:value-of select="."/></i>                                
                            </xsl:for-each>
                        </xsl:when>
                        <!-- collect all sentences -->
                        <xsl:when test="$type='sentence'">
                            <xsl:for-each select="//tc:sentence">
                                <i><xsl:value-of select="."/></i>                                
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$type='software-names'">
                            <xsl:variable name="software-names" select="tokenize(unparsed-text($path-to-software-list), '\n+')[not(matches(., '[\s\n]+'))]" as="xs:string+"/>
                            <xsl:for-each select="$software-names">
                                <xsl:variable name="software-name" select="." as="xs:string"/>
                                <xsl:variable name="regex-instance" select="replace(., '[\s|\-\.]', '[\\s\\-\\.]*')" as="xs:string"/>
                                <xsl:for-each select="$doc//*:body/descendant::text()">                                    
                                    <xsl:analyze-string select="." regex="{$regex-instance}" flags="i">
                                        <xsl:matching-substring>
                                            <i><xsl:value-of select="$software-name"/></i>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- error for invalid type value -->
                        <xsl:otherwise>
                            <xsl:message select="'***ERROR: value of parameter type invalid.'" terminate="yes"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:message select="concat('Total of ', $type, ' instances: ', count($all-instances))"/>
        
        <xsl:for-each-group select="$all-instances" group-by="text()">
            <xsl:sort select="count(current-group())" order="descending"/>
            <xsl:value-of select="concat('&quot;', current-grouping-key(), '&quot;')"/>;"<xsl:value-of select="concat('&quot;', count(current-group()), '&quot;')"/>"<xsl:value-of select="$NEWLINE"/>
        </xsl:for-each-group>
        
    </xsl:template>
    
</xsl:stylesheet>