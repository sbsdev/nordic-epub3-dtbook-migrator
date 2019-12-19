<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:opf="http://www.idpf.org/2007/opf" xmlns="http://www.idpf.org/2007/opf"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="/*">
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/" prefix="nordic: http://www.mtm.se/epub/ prod: http://www.sbs.ch/prod/ schema: http://www.schema.org/">

            <xsl:variable name="identifier" select="//html:head/html:meta[lower-case(@name)=('dc:identifier','dct:identifier','dcterms:identifier','dtb:uid')][1]"/>
            <dc:identifier id="pub-id">
                <xsl:copy-of select="$identifier/@scheme" exclude-result-prefixes="#all"/>
                <xsl:value-of select="($identifier/@content,replace(replace(string(current-dateTime()),'\+.*',''),'[^\d]',''))[1]"/>
            </dc:identifier>

            <dc:format id="format">EPUB3</dc:format>

            <xsl:if test="not(/html:html/html:head/html:meta[lower-case(@name)='dc:language'])">
                <dc:language>
                    <xsl:value-of select="(/*/@xml:lang,'und')[1]"/>
                </dc:language>
            </xsl:if>

            <xsl:if test="not(/html:html/html:head/html:meta[lower-case(@name)='dc:title'])">
                <dc:title>
                    <xsl:value-of select="/html:html/html:head/html:title/text()"/>
                </dc:title>
            </xsl:if>

            <xsl:for-each select="/html:html/html:head/html:meta">
                <xsl:variable name="lcname" select="lower-case(@name)"/>
                <xsl:variable name="id"
                    select="if (matches($lcname,'^dc:\w+$')) then concat(replace($lcname,'^dc:',''),'_',count(preceding-sibling::html:meta[lower-case(@name)=$lcname])+1) else if (matches($lcname,'^dtb:\w+$')) then concat(replace($lcname,'dtb:','dtb-'),'_',count(preceding-sibling::html:meta[lower-case(@name)=$lcname])) else concat('meta_',count(preceding-sibling::html:meta)+1)"/>
                <xsl:choose>
                    <xsl:when test="@http-equiv">
                        <xsl:message select="'Dropping empty meta element with http-equiv'"/>
                    </xsl:when>
		    <xsl:when test="matches(@property,'^schema:')">
                      <xsl:message select="concat('Accessibility meta data found (',@property,')')"/>
                      <meta property="{@property}" id="{$id}">
                        <xsl:value-of select="."/>
                      </meta>
		    </xsl:when>
                    <xsl:when test="string-length(normalize-space(@content)) = 0">
                        <xsl:message select="concat('Dropping empty meta element: ',@name)"/>
                    </xsl:when>
                    <xsl:when test="$lcname=('dc:identifier','dct:identifier','dcterms:identifier','dtb:uid')"/>
                    <xsl:when test="$lcname=('dcterms:modified','dc:format')">
                        <xsl:message select="concat('Discarding pre-existing meta element (it will be replaced with a new one): ',@name)"/>
                    </xsl:when>
                    <xsl:when test="matches($lcname,'^dc:')">
                        <xsl:element name="{$lcname}">
                            <xsl:attribute name="id" select="$id"/>
                            <xsl:copy-of select="@scheme" exclude-result-prefixes="#all"/>
                            <xsl:value-of select="@content"/>
                        </xsl:element>
                        <xsl:if test="@role">
                            <meta refines="#{$id}" property="role" scheme="marc:relators">
                                <xsl:value-of select="@role"/>
                            </meta>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="matches($lcname,'^dct:') or matches($lcname,'^dcterms:')">
                        <meta property="{replace($lcname,'^dct:','dcterms:')}">
                            <xsl:attribute name="id" select="$id"/>
                            <xsl:copy-of select="@scheme" exclude-result-prefixes="#all"/>
                            <xsl:value-of select="@content"/>
                        </meta>
                    </xsl:when>
                    <xsl:when test="@name='dtb:narrator'">
                        <dc:contributor id="{$id}">
                            <xsl:attribute name="id" select="$id"/>
                            <xsl:copy-of select="@scheme" exclude-result-prefixes="#all"/>
                            <xsl:value-of select="@content"/>
                        </dc:contributor>
                        <meta refines="#{$id}" property="role" scheme="marc:relators">nrt</meta>
                    </xsl:when>
                    <xsl:when test="@name='dtb:producer'">
                        <dc:contributor id="{$id}">
                            <xsl:attribute name="id" select="$id"/>
                            <xsl:copy-of select="@scheme" exclude-result-prefixes="#all"/>
                            <xsl:value-of select="@content"/>
                        </dc:contributor>
                        <meta refines="#{$id}" property="role" scheme="marc:relators">pro</meta>
                    </xsl:when>
                    <xsl:when test="@name='track:Guidelines'">
                        <meta property="nordic:guidelines">2015-1</meta>
                    </xsl:when>
                    <xsl:when test="@name='track:Supplier'">
                        <meta property="nordic:supplier">
                            <xsl:value-of select="@content"/>
                        </meta>
                    </xsl:when>
                    <xsl:otherwise>
                        <meta property="{@name}">
                            <xsl:attribute name="id" select="$id"/>
                            <xsl:copy-of select="@scheme" exclude-result-prefixes="#all"/>
                            <xsl:value-of select="@content"/>
                        </meta>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <meta property="dcterms:modified">
                <xsl:value-of
                    select="format-dateTime(
                    adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H')),
                    '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')"
                />
            </meta>
            <meta name="dcterms:modified"
                content="{format-dateTime(
                    adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H')),
                    '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]')}"
            />
        </metadata>
    </xsl:template>

</xsl:stylesheet>
