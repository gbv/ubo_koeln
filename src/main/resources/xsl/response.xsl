<?xml version="1.0" encoding="UTF-8"?>

<!-- Displays a navigable result list of a SOLR search for bibliography entries -->

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:str="xalan://java.lang.String"
  xmlns:basket="xalan://org.mycore.ubo.basket.BasketUtils"
  exclude-result-prefixes="xsl xalan i18n mods mcr mcrxml encoder str basket">

<xsl:include href="mods-display.xsl" />
<xsl:include href="resource:xsl/response-get-handler.xsl"/>
<xsl:include href="response-facets.xsl" />
<xsl:include href="ubo-dialog.xsl" />
<xsl:include href="coreFunctions.xsl" />
<xsl:include href="csl-export-gui.xsl" />

<xsl:param name="RequestURL" />
<xsl:param name="MCR.ORCID2.OAuth.ClientSecret" select="''" />
<xsl:param name="MCR.ORCID2.OAuth.Scope" select="''" />

<xsl:decimal-format name="WesternEurope" decimal-separator="," grouping-separator="."/>

<!-- ==================== Trefferliste Metadaten ==================== -->

<xsl:variable name="numFound" select="/response/result[@name='response']/@numFound" />
<xsl:variable name="numDocs" select="count(/response/result[@name='response']/doc)" />
<xsl:variable name="mask" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='mask']" />
<xsl:variable name="start">
  <xsl:choose>
    <xsl:when test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='start']">
      <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='start']" />
    </xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="rows">
  <xsl:choose>
    <xsl:when test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='rows']">
      <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='rows']" />
    </xsl:when>
    <xsl:when test="$start + $numDocs &lt; $numFound">
      <xsl:value-of select="$numDocs" /> <!-- rows parameter missing, use count docs returned -->
    </xsl:when>
    <xsl:otherwise>10</xsl:otherwise> <!-- guess, no way to find out -->
  </xsl:choose>
</xsl:variable>
<xsl:variable name="requestHandler" select="substring-before(substring-after($RequestURL, '/servlets/solr/'), '?')"/>

<!-- ==================== Anzeige Seitentitel ==================== -->

<xsl:template name="page.title">
 <title>
  <xsl:value-of select="i18n:translate('result.dozbib.results')" />
  <xsl:text>: </xsl:text>
  <xsl:choose>
    <xsl:when test="$numFound > 1">
      <xsl:value-of select="format-number($numFound, '##.###', 'WesternEurope')" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="i18n:translate('result.dozbib.publicationMany')"/>
    </xsl:when>
    <xsl:when test="$numFound = 1">
      <xsl:value-of select="i18n:translate('result.dozbib.publicationOne')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="i18n:translate('result.dozbib.publicationNo')"/>
    </xsl:otherwise>
  </xsl:choose>
 </title>
</xsl:template>

<!-- ==================== Export-Buttons ==================== -->

<xsl:variable name="exportParams">
  <xsl:for-each select="/response/lst[@name='responseHeader']/lst[@name='params']/*[(@name='q') or (@name='fq') or (@name='sort') or (@name='qq')]">
    <xsl:variable name="name" select="@name" />
    <xsl:for-each select="descendant-or-self::str"> <!-- may be an array: arr/str or ./str -->
      <xsl:value-of select="$name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="encoder:encode(text(),'UTF-8')" />
      <xsl:text>&amp;</xsl:text>
    </xsl:for-each>
  </xsl:for-each>
  <xsl:value-of select="concat('rows=',$numFound)" />
</xsl:variable>

<xsl:template name="exportLinks">
  <xsl:if test="$numFound &gt; 0">
    <xsl:call-template name="exportGUI">
      <xsl:with-param name="type" select="'response'" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- ==================== Anzeige Trefferliste ==================== -->

<xsl:template name="breadcrumb">
  <ul id="breadcrumb">
    <li>
      <xsl:value-of select="i18n:translate('result.dozbib.results')" />
    </li>
  </ul>
</xsl:template>

<xsl:template match="/">
  <html id="dozbib.search">
    <head>
      <xsl:call-template name="page.title" />
      <xsl:if test="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0 and contains($MCR.ORCID2.OAuth.Scope,'update')">

        <xsl:if test="not(mcrxml:isCurrentUserGuestUser())">
          <script src="{$WebApplicationBaseURL}modules/orcid2/js/orcid-auth.js"/>
          <script src="{$WebApplicationBaseURL}js/mycore2orcid.js" />

          <xsl:call-template name="notification-dialog">
            <xsl:with-param name="id" select="'success'"/>
            <xsl:with-param name="title" select="'⚠'"/>
            <xsl:with-param name="message" select="i18n:translate('orcid.publication.action.confirmation')"/>
          </xsl:call-template>
          <xsl:call-template name="notification-dialog">
            <xsl:with-param name="id" select="'fail'"/>
            <xsl:with-param name="title" select="'⚠'"/>
            <xsl:with-param name="message" select="i18n:translate('upload.failed')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </head>
    <body>
      <xsl:call-template name="breadcrumb" />
      <xsl:call-template name="exportLinks" />
      <xsl:apply-templates select="response" />
      <aside id="sidebar">
        <xsl:apply-templates select="/response/lst[@name='facet_counts'][lst[@name='facet_fields']/lst[int]]" />
      </aside>
    </body>
  </html>
</xsl:template>

<xsl:template match="response">
  <xsl:apply-templates select="result[@name='response']" />
</xsl:template>

<xsl:template match="result[@name='response']">

  <!-- Seitennavigation oben -->
  <xsl:call-template name="navigation">
    <xsl:with-param name="position" select="'top'"/>
  </xsl:call-template>

  <!-- Trefferliste -->
  <div>
    <xsl:if test="$numFound = 0">
      <p>
        <xsl:value-of select="i18n:translate('result.dozbib.publicationNo')" />
      </p>
    </xsl:if>
    <xsl:if test="$numFound &gt; 0">
      <div class="results">
        <xsl:apply-templates select="doc">
          <xsl:with-param name="start" select="@start"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </div>
  <div class="clear"></div>

  <!-- Seitennavigation unten -->
  <xsl:call-template name="navigation">
    <xsl:with-param name="position" select="'bottom'"/>
  </xsl:call-template>

</xsl:template>

<!-- ==================== Anzeige Navigation in Trefferliste ==================== -->

<xsl:variable name="resultsPageURL">
  <xsl:value-of select="$solrRequestHandler"/>
  <xsl:for-each select="/response/lst[@name='responseHeader']/lst[@name='params']/*[not(@name='start')]">
    <xsl:variable name="name" select="@name" />
    <xsl:for-each select="descendant-or-self::str"> <!-- may be an array: arr/str or ./str -->
      <xsl:value-of select="$name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="encoder:encode(text(),'UTF-8')" />
      <xsl:text>&amp;</xsl:text>
    </xsl:for-each>
  </xsl:for-each>
  <xsl:text>start=</xsl:text>
</xsl:variable>

<xsl:template name="navigation">
 <xsl:param name="position"/>
 <xsl:if test="$numFound &gt; 1">
  <div class="resultsNavigation row">

    <div class="col">
      <xsl:if test="basket:hasSpace()">
        <span class="pageLink">
          <a class="btn btn-sm btn-secondary" href="{$ServletsBaseURL}Results2Basket?rh={$requestHandler}&amp;solr={encoder:encode($exportParams,'UTF-8')}">
            <xsl:value-of select="i18n:translate('button.basketAdd')" />
          </a>
        </span>
        <span class="pageLink pl-1 d-inline">
          <xsl:variable name="result-copy-to-clipboard-id" select="concat('result-copy-to-clipboard-', $position)"/>
          <button id="{$result-copy-to-clipboard-id}" class="btn btn-sm btn-secondary"
                  title="{i18n:translate('result.copy.link.to.clipboard')}"
                  onclick="navigator.clipboard.writeText(window.location.href);$('#{$result-copy-to-clipboard-id}').fadeOut(500);$('#{$result-copy-to-clipboard-id}').fadeIn(500);">
            <i class="far fa-copy"/>
          </button>
        </span>
      </xsl:if>
    </div>

    <div class="col text-center align-self-center">
      <nav>
        <ul class="pagination justify-content-center pagination-sm mb-0">
          <xsl:if test="$numFound &gt; $rows">
            <xsl:call-template name="link2resultsPage">
              <xsl:with-param name="condition" select="$start &gt; 0" />
              <xsl:with-param name="start"     select="0" />
              <xsl:with-param name="icon"      select="'fast-backward'" />
            </xsl:call-template>
            <xsl:call-template name="link2resultsPage">
              <xsl:with-param name="condition" select="$start &gt; 0" />
              <xsl:with-param name="start"     select="number($start)-number($rows)" />
              <xsl:with-param name="icon"      select="'backward'" />
            </xsl:call-template>
            <xsl:call-template name="link2resultsPage">
              <xsl:with-param name="text"      select="floor(number($start) div number($rows))+1" />
            </xsl:call-template>
            <xsl:call-template name="link2resultsPage">
              <xsl:with-param name="condition" select="number($start)+number($rows) &lt; $numFound" />
              <xsl:with-param name="start"     select="number($start)+number($rows)" />
              <xsl:with-param name="icon"      select="'forward'" />
            </xsl:call-template>
            <xsl:call-template name="link2resultsPage">
              <xsl:with-param name="condition" select="number($start)+number($rows) &lt; $numFound" />
              <xsl:with-param name="start"     select="floor(number($numFound) div number($rows))*number($rows)" />
              <xsl:with-param name="icon"      select="'fast-forward'" />
            </xsl:call-template>
          </xsl:if>
        </ul>
      </nav>
    </div>

    <xsl:if test="not(mcrxml:isCurrentUserGuestUser())">
      <div class="col text-right">
        <span class="pageLink">
          <a class="btn btn-sm btn-secondary" href="{$solrStatisticRequestHandler}{$exportParams}&amp;XSL.Style=statistics" title="{i18n:translate('button.statistics.tooltip')}">
            <xsl:value-of select="i18n:translate('button.statistics')"/>
          </a>
        </span>
      </div>
    </xsl:if>

  </div>
 </xsl:if>
</xsl:template>

<xsl:template name="link2resultsPage">
  <xsl:param name="condition" />
  <xsl:param name="start" />
  <xsl:param name="icon" />
  <xsl:param name="text" />
  <xsl:param name="title" select="i18n:translate(concat('result.results.pagination.', $icon))"/>

  <xsl:choose>
    <xsl:when test="string-length($text) &gt; 0">
      <li class="page-item disabled">
        <a class="page-link" href="#" title="{$title}">
          <xsl:value-of select="concat('&#160;',$text,'&#160;')" />
        </a>
      </li>
    </xsl:when>
    <xsl:when test="$condition">
      <li class="page-item">
        <a class="page-link" href="{$resultsPageURL}{$start}" title="{$title}">
          <span class="fas fa-{$icon}" aria-hidden="true"/>
        </a>
      </li>
    </xsl:when>
    <xsl:otherwise>
      <li class="page-item disabled" aria-hidden="true">
        <a class="page-link" href="#">
          <span class="fas fa-{$icon}"/>
        </a>
      </li>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- ==================== Anzeige Treffer ==================== -->

<xsl:template match="doc">
  <xsl:param name="start" />
  <xsl:variable name="hitNo" select="$start + position()" />

  <div class="result mt-2 mb-2">
    <div class="hit card">
      <xsl:variable name="id" select="str[@name='id']" />
      <xsl:variable name="mycoreobject" select="document(concat('mcrobject:',$id))/mycoreobject" />
      <xsl:for-each select="$mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods">
        <div class="labels card-header ">
          <xsl:call-template name="label-year" />
          <xsl:call-template name="pubtype" />
          <xsl:call-template name="label-oa" />
          <xsl:if test="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0 and contains($MCR.ORCID2.OAuth.Scope,'update')">
            <xsl:call-template name="orcid-status" />
          </xsl:if>
        </div>
        <div class="content bibentry card-body">
          <xsl:apply-templates select="." mode="cite">
            <xsl:with-param name="mode">divs</xsl:with-param>
          </xsl:apply-templates>
        </div>
        <div class="footer card-footer">
          <xsl:call-template name="bibentry.show.details" />
          <xsl:if test="basket:hasSpace() and not(basket:contains(string(ancestor::mycoreobject/@ID)))">
            <xsl:call-template name="bibentry.add.to.basket" />
          </xsl:if>
          <xsl:call-template name="bibentry.subselect.return" />
          <xsl:if test="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0 and contains($MCR.ORCID2.OAuth.Scope,'update')">
            <xsl:call-template name="orcid-publish" />
          </xsl:if>
          <span class="float-right"># <xsl:value-of select="$hitNo"/></span>
        </div>
      </xsl:for-each>
    </div>
  </div>
</xsl:template>

<xsl:template name="bibentry.add.to.basket">
  <form action="{$ServletsBaseURL}MCRBasketServlet" method="get" class="d-inline">
    <input type="hidden" name="action" value="add"/>
    <input type="hidden" name="type" value="objects"/>
    <input type="hidden" name="resolve" value="true"/>
    <input type="hidden" name="id" value="{ancestor::mycoreobject/@ID}"/>
    <input type="hidden" name="uri" value="mcrobject:{ancestor::mycoreobject/@ID}"/>
    <input type="submit" class="btn btn-sm btn-outline-primary" value="{i18n:translate('button.basketAdd')}" />
  </form>
</xsl:template>

<xsl:template name="bibentry.show.details">
   <a class="btn btn-sm btn-outline-primary" href="{$ServletsBaseURL}DozBibEntryServlet?mode=show&amp;id={ancestor::mycoreobject/@ID}" target="_self">
      <xsl:value-of select="i18n:translate('result.dozbib.info')"/>
   </a>
</xsl:template>

<!-- Return from subselect to choose related item (host) in editor form -->
<xsl:template name="bibentry.subselect.return">
  <xsl:if test="starts-with($mask,'_xed_subselect_session')">
    <form action="{$ServletsBaseURL}XEditor" method="get">
      <input type="hidden" name="_xed_submit_return" value=""/>
      <input type="hidden" name="_xed_session" value="{substring-after($mask,'=')}"/>
      <input type="hidden" name="." value="{ancestor::mycoreobject/@ID}"/>
      <input type="submit" class="btn btn-sm btn-primary" value="{i18n:translate('ubo.relatedItem.host.selectAs')}" />
    </form>
    <form action="{$ServletsBaseURL}XEditor" method="get">
      <input type="hidden" name="_xed_submit_return_cancel" value=""/>
      <input type="hidden" name="_xed_session" value="{substring-after($mask,'=')}"/>
      <input type="submit" class="btn btn-sm btn-primary" value="{i18n:translate('button.cancel')}" />
    </form>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
