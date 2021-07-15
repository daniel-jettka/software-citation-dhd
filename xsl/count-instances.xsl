<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tc="http://www.dspin.de/data/textcorpus"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- counting instances of different elements or string in a list of XML files -->
    
    
    <!-- Serialization details -->
    <xsl:output method="text" omit-xml-declaration="1"/>
    
    <!-- Keys -->
    <xsl:key name="token-by-id" match="tc:token" use="@ID"/>
    
    <!-- Global parameters -->
    <xsl:param name="type" select="'external'" as="xs:string"/><!-- possible types to count: named-entity, token, sentence, external -->
    <xsl:param name="file-type" select="'XML'" as="xs:string"/><!-- possible file types to analyze: XML (for TEI), TCF -->
    <xsl:param name="count-doc-unique" select="true()" as="xs:boolean"/><!-- count all instances (false) or only one per XML document (true) -->
    <xsl:param name="list" select="'../conf/software-names.txt'" as="xs:string"/><!-- path to line-separated list of values to count -->
    
    
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
    
    <xsl:variable name="list-values" select="tokenize(unparsed-text($list), '\n+')[not(matches(., '^[\s\n]*$'))]" as="xs:string+"/>
    
    
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
                        <!-- collect software names -->
                        <xsl:when test="$type='external'">
                            <xsl:variable name="list-values-in-doc" as="xs:string*">
                                <xsl:for-each select="$list-values">
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
                                    <xsl:sequence select="distinct-values($list-values-in-doc)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$list-values-in-doc"/>
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
        
        <xsl:choose>
            <!-- if an external list of values was provided, then also 0 counts are listed -->
            <xsl:when test="$type='external'">
                <xsl:for-each select="$list-values">
                    <xsl:sort select="count($all-instances[.=current()])" order="descending" data-type="number"/>
                    <xsl:sort select="." order="ascending" data-type="text"/>
                    <xsl:value-of select="concat('&quot;', ., '&quot;', $csv-separator)"/>
                    <xsl:value-of select="count($all-instances[.=current()])"/>
                    <xsl:if test="position()!=last()"><xsl:value-of select="$NEWLINE"/></xsl:if>
                </xsl:for-each>
            </xsl:when>
            <!-- if count is not based on a list, then 0 counts are not provided -->
            <xsl:otherwise>
                <xsl:for-each select="distinct-values($all-instances)">
                    <xsl:sort select="count($all-instances[.=current()])" order="descending"/>
                    <xsl:value-of select="concat('&quot;', ., '&quot;', $csv-separator)"/>
                    <xsl:value-of select="count($all-instances[.=current()])"/>
                    <xsl:if test="position()!=last()"><xsl:value-of select="$NEWLINE"/></xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
               
        
    </xsl:template>
    
</xsl:stylesheet>