<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="//servflag[@type='status'] = 'confirmed'">
        <mycoreobject>
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates select="structure" />
          <!-- create empty mods container -->
          <metadata>
            <def.modsContainer class="MCRMetaXML" heritable="false" notinherit="true">
              <modsContainer inherited="0">
                <mods:mods />
              </modsContainer>
            </def.modsContainer>
          </metadata>
          <xsl:apply-templates select="service" />
        </mycoreobject>
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>