<?xml version="1.0" encoding="UTF-8"?>
<!-- Transforms MyCoRe object with MODS to ORCID works XML schema -->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:work="http://www.orcid.org/ns/work"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="fn mods xsl">

  <xsl:import href="resource:xslt/orcid2/v3/mcr2work_generic.xsl"/>

  <xsl:param name="MCR.ORCID2.Genre.Mapping.Default.Genre" select="'other'"/>

  <xsl:template name="workType">
    <xsl:choose>
      <xsl:when test="mods:classification[@generator = 'xpathmapping2orcidWorkType-mycore'][@valueURI][@authorityURI]">
        <work:type>
          <xsl:value-of
            select="fn:substring-after(mods:classification[@generator = 'xpathmapping2orcidWorkType-mycore']/@valueURI, '#')"/>
        </work:type>
      </xsl:when>
      <xsl:otherwise>
        <work:type>
          <xsl:value-of select="$MCR.ORCID2.Genre.Mapping.Default.Genre"/>
        </work:type>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="journal-title">
    <xsl:variable name="host-title-info"
                  select="(mods:relatedItem[@type='host'])[1]/(mods:titleInfo[not(@type)], mods:titleInfo)[1]" />
    <xsl:if test="$host-title-info/mods:title">
      <work:journal-title>
        <xsl:value-of select="fn:string-join(($host-title-info/mods:nonSort, $host-title-info/mods:title), ' ')" />
        <xsl:if test="$host-title-info/mods:subTitle">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$host-title-info/mods:subTitle" />
        </xsl:if>
      </work:journal-title>
    </xsl:if>
  </xsl:template>
  <xsl:template name="workCitation"/>
</xsl:stylesheet>
