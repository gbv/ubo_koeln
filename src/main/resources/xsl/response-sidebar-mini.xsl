<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl mods xalan i18n">

  <xsl:include href="mods-display.xsl" />

  <xsl:param name="ServletsBaseURL" />

  <xsl:template match="/response">
  
    <xsl:variable name="solr_query" select="'q=status:confirmed'" />
    <xsl:variable name="numTotal" select="document(concat('solr:',$solr_query,'&amp;rows=0'))/response/result/@numFound" />

    <article class="card mb-2">
      <div class="card-body">
        <hgroup>
          <h3 style="line-height: 1.5rem;">
            <xsl:value-of select="i18n:translate('ubo.numPublicationsTotal', $numTotal)" />
            <br />
            <xsl:value-of select="i18n:translate('ubo.numPublicationsPartOf', result[@name='response']/@numFound)" />
          </h3>
        </hgroup>
        <p>
          <xsl:for-each select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='year']/int">
            <xsl:sort select="@name" data-type="number" order="descending" />
            <xsl:if test="position() &lt; 4">
              <xsl:value-of select="@name"/>
              <xsl:text> : </xsl:text>
              <a href="{$ServletsBaseURL}solr/select?q=koeln_partOf:true+AND+status:confirmed+AND+year:{@name}">
                <xsl:value-of select="text()"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="i18n:translate('ubo.publications')" />
              </a>
              <br/>
            </xsl:if>
          </xsl:for-each>
        </p>
      </div>
    </article>
  </xsl:template>

</xsl:stylesheet>