<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="xsl xalan i18n encoder mcrxsl">

  <xsl:param name="CurrentLang"/>
  <xsl:param name="WebApplicationBaseURL"/>
  <xsl:param name="ChartsCommon.border.class"/>
  <xsl:param name="ChartsCommon.Default.Statistics.Bar.Color"/>

  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quot">"</xsl:variable>

  <xsl:template match="/response[result/@numFound &gt; 0]">
    <xsl:apply-templates select="lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='nid_dhsbid'][int]"/>
    <xsl:apply-templates select="lst[@name='facet_counts']/lst[@name='facet_pivot']/arr[@name='name_id_type,name_id_type']"/>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst[@name='nid_dhsbid']">
    <xsl:if test="mcrxsl:isCurrentUserInRole('admin')">

      <xsl:variable name="uri">
        <xsl:text>solr:q=objectKind%3Aname+AND+(</xsl:text>
        <xsl:for-each select="int">
          <xsl:text>name_id_dhsbid%3A</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:if test="position() != last()">+OR+</xsl:if>
        </xsl:for-each>
        <xsl:text>)&amp;rows=0&amp;facet.pivot=name_id_dhsbid,name&amp;facet.limit=</xsl:text>
        <xsl:value-of select="count(int)"/>
      </xsl:variable>
      <xsl:variable name="response" select="document($uri)/response"/>
      <xsl:variable name="koeln2name" select="$response/lst[@name='facet_counts']/lst[@name='facet_pivot']/arr[@name='name_id_dhsbid,name']"/>

      <xsl:variable name="title" select="i18n:translate('thk.statistics.bydhsbid.title')"/>

      <xsl:variable name="labels">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="int">
          <xsl:sort select="text()" data-type="number" order="descending"/>
          <xsl:variable name="koeln_id" select="@name"/>
          <xsl:variable name="name" select="$koeln2name/lst[str[@name='value']=$koeln_id]/arr/lst[1]/str[@name='value']"/>
          <xsl:value-of select="concat($quot, $name, $quot)"/>
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="values">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="int">
          <xsl:sort select="text()" data-type="number" order="descending"/>
          <xsl:value-of select="text()"/>
          <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="height" select="50 + count(int) * 36"/>

      <article class="card mb-3" xml:lang="de">
        <div class="card-body">
          <h3><xsl:value-of select="$title"/></h3>
          <div id="chart-bar-nid-dhsbid" style="width:100%;height:{$height}px" class="bg-white {$ChartsCommon.border.class} mb-3"/>
          <script>
            {
              let chartDom = document.getElementById('chart-bar-nid-dhsbid');
              let chart = echarts.init(chartDom, null, { renderer: 'svg' });
              chart.setOption({
                tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
                yAxis: {
                  type: 'category',
                  data: <xsl:value-of select="$labels"/>,
                  inverse: true,
                  axisLabel: {
                    align: 'start',
                    margin: 225,
                    formatter: function(value) {
                      return value.length &lt; 32 ? value : (value.substring(0, 32) + '...');
                    }
                  }
                },
                xAxis: { type: 'value' },
                series: [{
                  data: <xsl:value-of select="$values"/>,
                  type: 'bar',
                  color: '<xsl:value-of select="$ChartsCommon.Default.Statistics.Bar.Color"/>',
                  label: { show: true, position: 'inside' }
                }]
              });
              window.addEventListener('resize', function() { chart.resize(); });
            }
          </script>
        </div>
      </article>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst/arr[@name='name_id_type,name_id_type']">
    <xsl:if test="mcrxsl:isCurrentUserInRole('admin')">
      <xsl:variable name="base" select="."/>

      <article class="card mb-3" xml:lang="de">
        <div class="card-body">
          <h3><xsl:value-of select="i18n:translate('thk.statistics.nameidtype.title')"/></h3>

          <table class="table table-bordered">
            <tr class="text-center">
              <th scope="col">/</th>
              <xsl:for-each select="$base/lst">
                <th scope="col">
                  <xsl:choose>
                    <xsl:when test="not(starts-with(i18n:translate(concat('user.profile.id.', str[@name='value'])),'???'))">
                      <xsl:value-of select="i18n:translate(concat('user.profile.id.', str[@name='value']))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="translate(str[@name='value'],'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
              </xsl:for-each>
            </tr>
            <xsl:for-each select="$base/lst">
              <xsl:variable name="a" select="str[@name='value']"/>
              <tr class="text-right">
                <th class="identifier" scope="col">
                  <xsl:choose>
                    <xsl:when test="not(starts-with(i18n:translate(concat('user.profile.id.', str[@name='value'])),'???'))">
                      <xsl:value-of select="i18n:translate(concat('user.profile.id.', str[@name='value']))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="translate(str[@name='value'],'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </th>
                <xsl:for-each select="$base/lst">
                  <xsl:variable name="b" select="str[@name='value']"/>
                  <td class="identifier">
                    <xsl:value-of select="$base/lst[str[@name='value']=$a]/arr/lst[str[@name='value']=$b]/int[@name='count']"/>
                  </td>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
          </table>
        </div>
      </article>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
