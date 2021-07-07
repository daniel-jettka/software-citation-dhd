<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tc="http://www.dspin.de/data/textcorpus"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="text" omit-xml-declaration="1"/>
    
    <xsl:key name="token-by-id" match="tc:token" use="@ID"/>
    
    <xsl:param name="type" select="'named-entity'" as="xs:string"/><!-- possible types to count: named-entity, tokens -->
    
    <xsl:variable name="collection-dirs" select="(
        '../data/DHd-Abstracts-2016/TCF-files',
        '../data/DHd-Abstracts-2017/TCF-files',
        '../data/DHd-Abstracts-2018/TCF-files',
        '../data/DHd-Abstracts-2019/TCF-files',
        '../data/DHd-Abstracts-2020/TCF-files'
        )" as="xs:string+"/>
    <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
    
    <xsl:template match="/">
        
        <xsl:variable name="all-instances" as="element(i)+">
            <xsl:for-each select="$collection-dirs">                
                <xsl:for-each select="collection(concat(., '?select=*.xml;recurse=yes;on-error=warning'))">
                    <xsl:choose>
                        <!-- collect named entities -->
                        <xsl:when test="$type='named-entity'">                            
                            <xsl:for-each select="//tc:entity">
                                <i><xsl:value-of select="concat(string-join(key('token-by-id', tokenize(@tokenIDs, ' ')), ' '), ';', @class)"/></i>                    
                            </xsl:for-each>
                        </xsl:when>
                        <!-- collect all tokens -->
                        <xsl:when test="$type='token'">
                            <xsl:for-each select="//*:text/*:body/descendant::text()">
                                <xsl:for-each select="tokenize(., '[\s\.,:;!\?\)\(\[\]„“;]+')">
                                    <i><xsl:value-of select="."/></i>
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
        
        <xsl:for-each-group select="$all-instances" group-by="text()">
            <xsl:sort select="count(current-group())" order="descending"/>
            <xsl:value-of select="current-grouping-key()"/>;<xsl:value-of select="count(current-group())"/><xsl:value-of select="$NEWLINE"/>
        </xsl:for-each-group>
        
    </xsl:template>
    
</xsl:stylesheet>