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
    <xsl:param name="count-doc-unique" select="false()" as="xs:boolean"/>
    
    
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
    
    <xsl:variable name="csv-separator" select="','" as="xs:string"/>
    
    <xsl:variable name="NEWLINE"><xsl:text>
</xsl:text></xsl:variable>
    
    
    <!-- Templates -->
    
    <xsl:template match="/">
        
        <xsl:variable name="all-instances" as="xs:string*">
            <xsl:for-each select="$collection-dirs">                
                <xsl:for-each select="collection(concat(., '?select=*.xml;recurse=yes;on-error=warning'))">
                    <xsl:variable name="doc" select="/"/>
                    <xsl:choose>
                        <!-- collect named entities -->
                        <xsl:when test="$type='named-entity'">                            
                            <xsl:for-each select="//tc:entity">
                                <xsl:sequence select="concat(string-join(key('token-by-id', tokenize(@tokenIDs, ' ')), ' '), $csv-separator, @class)"/>                    
                            </xsl:for-each>
                        </xsl:when>
                        <!-- collect all tokens -->
                        <xsl:when test="$type='token'">
                            <xsl:for-each select="//tc:token">
                                <xsl:sequence select="."/>                             
                            </xsl:for-each>
                        </xsl:when>
                        <!-- collect all sentences -->
                        <xsl:when test="$type='sentence'">
                            <xsl:for-each select="//tc:sentence">
                                <xsl:sequence select="."/>                                
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$type='software-names'">
                            <xsl:variable name="software-names" select="tokenize(unparsed-text($path-to-software-list), '\n+')[not(matches(., '^[\s\n]*$'))]" as="xs:string+"/>
                            <xsl:variable name="software-names-in-doc" as="xs:string*">
                                <xsl:for-each select="$software-names">
                                    <xsl:variable name="software-name" select="." as="xs:string"/>
                                    <xsl:variable name="regex-instance" select="concat('[^\w]+', replace(., '[\s|\-\.]', '[\\s\\-\\.]*'), '[^\w]+')" as="xs:string"/>
                                    <xsl:for-each select="$doc//descendant::text()">                                    
                                        <xsl:analyze-string select="." regex="{$regex-instance}" flags="i">
                                            <xsl:matching-substring>
                                                <xsl:sequence select="$software-name"/>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$count-doc-unique">
                                    <xsl:sequence select="distinct-values($software-names-in-doc)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$software-names-in-doc"/>
                                </xsl:otherwise>
                            </xsl:choose>
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
        
        <xsl:for-each select="distinct-values($all-instances)">
            <xsl:sort select="count($all-instances[.=current()])" order="descending"/>
            <xsl:value-of select="concat('&quot;', ., '&quot;', $csv-separator)"/>"<xsl:value-of select="count($all-instances[.=current()])"/>"<xsl:value-of select="$NEWLINE"/>
        </xsl:for-each>
        
    </xsl:template>
    
</xsl:stylesheet>