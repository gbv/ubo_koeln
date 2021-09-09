<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="i18n xlink">
  <xsl:variable name="Type" select="'document'" />

  <xsl:variable name="PageTitle" select="i18n:translate('titles.pageTitle.error',concat(' ',/mcr_error/@HttpError))" />

  <xsl:template match="/mcr_error">
    <h1>
      <xsl:value-of select="i18n:translate('koeln.pageError.title')" />
    </h1>
    <div class="row">
      <div class="col" lang="{$CurrentLang}">
        <article class="card mb-3" xml:lang="{$CurrentLang}">
          <div class="card-body">
            <xsl:choose>
              <xsl:when test="/mcr_error/@HttpError = '500'">
                <h2><xsl:value-of select="i18n:translate('koeln.pageError.title.500')" /></h2>
                <xsl:value-of select="i18n:translate('koeln.pageError.text.404')" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:when test="/mcr_error/@HttpError = '404'">
                  <h2><xsl:value-of select="." /></h2>
                  <xsl:value-of select="i18n:translate('koeln.pageError.text.404')" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:when test="/mcr_error/@HttpError = '403'">
                  <h2><xsl:value-of select="i18n:translate('koeln.pageError.title.403')" /></h2>
                <xsl:value-of select="i18n:translate('koeln.pageError.text.403')" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:otherwise>
                  <h2><xsl:value-of select="."></xsl:value-of></h2>
                <xsl:value-of select="i18n:translate('koeln.pageError.text.otherwise')" disable-output-escaping="yes" />
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </article>
      </div>
      <xsl:if test="exception">
      <div class="d-none">
        <div class="panel panel-warning">
          <div class="panel-heading">
            <xsl:value-of select="concat(i18n:translate('error.stackTrace'),' :')" />
          </div>
          <div class="panel-body">
            <xsl:for-each select="exception/trace">
              <pre style="font-size:0.8em;">
                <xsl:value-of select="." />
              </pre>
            </xsl:for-each>
          </div>
        </div>
      </div>
      </xsl:if>
    </div>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
