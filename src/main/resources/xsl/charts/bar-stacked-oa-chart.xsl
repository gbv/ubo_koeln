<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">
  <xsl:import href="chart-common.xsl"/>

  <!-- The name of the inner bucket, the outer bucket is the year of publication by default -->
  <xsl:param name="inner-bucket-name" select="'oa'"/>

  <!-- The name of the class to resolve the labels of the entries of the inner bucket -->
  <xsl:param name="inner-bucket-class" select="'oa'"/>

  <xsl:variable name="inner-bucket-values-categories" select="document(concat('notnull:classification:metadata:-1:children:', $inner-bucket-class))//mycoreclass/categories//category"/>

  <xsl:template match="/response">
    <xsl:apply-templates select="." mode="stacked-bar-oa-chart" />
  </xsl:template>

  <xsl:template match="response[result/@numFound &gt; 0]" mode="stacked-bar-oa-chart">
    <xsl:param name="chart-title" select="document('notnull:i18n:stats.oa.title')/i18n/text()"/>

    <div class="charts-common-container charts-common-stacked-column-chart charts-common-stacked-column-chart-oa bg-white">
      <xsl:variable name="labels">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="//lst[@name='facets']/lst[@name='year']/arr[@name='buckets']/lst/int[@name='val']">
          <xsl:value-of select="concat($quot, text(), $quot)"/>
          <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="colors">
        <xsl:variable name="classification" select="document(concat('notnull:classification:metadata:-1:children:', $inner-bucket-class))"/>
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$classification//category">
          <xsl:if test="label[@xml:lang = 'x-color-chart']">
            <xsl:value-of select="concat($apos, label[@xml:lang = 'x-color-chart']/@text, $apos)"/>
            <xsl:if test="not(position() = last())">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="concat(', ', $apos, '#5858FA', $apos)"/>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="r" select="."/>

      <xsl:variable name="series">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$inner-bucket-values-categories">
          <xsl:variable name="bucket-label">
            <xsl:choose>
              <xsl:when test="@ID = 'oa'">
                <xsl:value-of select="concat(document(concat('notnull:callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:', $inner-bucket-class, ':', @ID)), ' ', document('notnull:i18n:stats.oa.unspecified')/i18n/text())"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="document(concat('notnull:callJava:org.mycore.common.xml.MCRXMLFunctions:getDisplayName:', $inner-bucket-class, ':', @ID))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:call-template name="create-data-array">
            <xsl:with-param name="bucket-label" select="$bucket-label"/>
            <xsl:with-param name="bucket" select="@ID"/>
            <xsl:with-param name="r" select="$r"/>
          </xsl:call-template>
          <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>

        <xsl:text>, </xsl:text>

        <xsl:call-template name="create-no-oa-data-array">
          <xsl:with-param name="r" select="$r"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="source-series">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$inner-bucket-values-categories">
          <xsl:value-of select="concat($quot, @ID, $quot)"/>
          <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="concat($quot, 'no-data', $quot)"/>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="chart-id" select="concat('chart-stacked-bar-oa', translate($facet, '.', '-'))"/>

      <div id="{$chart-id}" style="height:500px;" class="w-100 {$ChartsCommon.border.class} rounded mb-3" data-labels="{$labels}" data-source-labels="{$labels}" data-series="{$series}" data-source-series="{$source-series}" data-colors="{$colors}"/>

      <script>
        {
          let chartDom = document.getElementById('<xsl:value-of select="$chart-id"/>');
          let chart = echarts.init(chartDom, null, { renderer: 'svg' });
          let option;

          let series = JSON.parse(chartDom.getAttribute('data-series'));

          var emphasisStyle = {
            itemStyle: {
              shadowBlur: 10,
              shadowColor: 'rgba(0,0,0,0.3)'
            }
          };

          option = {
            title: {
              text: <xsl:value-of select="concat($apos, $chart-title, $apos)"/>,
              textStyle: {
                fontFamily: <xsl:value-of select="concat($apos, $ChartsCommon.title.fontFamily, $apos)"/>,
                fontSize:   <xsl:value-of select="concat($apos, $ChartsCommon.title.fontSize, $apos)"/>,
                fontWeight: <xsl:value-of select="concat($apos, $ChartsCommon.title.fontWeight, $apos)"/>
              }
            },
            color: <xsl:value-of select="$colors"/>,
            legend: {
              data: series.map(function(s) { return s.name; })
            },
            label: {
              show: true,
              color: <xsl:value-of select="$ChartsCommon.dataLabels.style.colors"/>,
              formatter: function(value, index, extra) {
                if(value.data &lt; 100) {
                  return "";
                }
                return value.data;
              }
            },
            tooltip: {},
            xAxis: {
              data: <xsl:value-of select="$labels"/>
            },
            yAxis: {},
            series: series.map(function(s, idx) {
              var entry = {
                name: s.name,
                type: 'bar',
                stack: 'one',
                emphasis: emphasisStyle,
                data: s.data
              };
              if (idx === series.length - 1) {
                entry.label = { color: 'white' };
              }
              return entry;
            })
          };

          chart.setOption(option);

          chart.on('click', function(params) {
            console.debug(params);

            const element = document.getElementById("<xsl:value-of select="$chart-id"/>");
            const fqLabelsValues = JSON.parse(element.getAttribute("data-source-labels"));
            const fqSeriesValues = JSON.parse(element.getAttribute("data-source-series"));

            const q = <xsl:value-of select="concat($apos, lst/lst/str[@name=$ChartsCommon.Chart.solr.queryParamName], $apos)"/> ;
            const fq1 = <xsl:value-of select="concat($quot, 'year', ':' ,$quot, '+ params.name')"/> ;

            const oaValue = fqSeriesValues[params.seriesIndex];
            let fq2;
            if(oaValue === 'no-data') {
              fq2 = <xsl:value-of select="concat($quot, '-oa', ':*', $quot)"/> ;
            } else {
              fq2 = <xsl:value-of select="concat($quot, 'oa_exact', ':', $quot, '+ fqSeriesValues[params.seriesIndex]')"/> ;
            }
            location.assign(webApplicationBaseURL + "servlets/solr/<xsl:value-of select="concat($ChartsCommon.Chart.solr.requestHandler, '?', $ChartsCommon.Chart.solr.queryParamName, '=')"/>" + encodeURIComponent(q) + "&amp;fq=" + fq1 + "&amp;fq=" + fq2);
          });

          window.addEventListener('resize', function() {
            chart.resize();
          });
        }
      </script>
    </div>
  </xsl:template>

  <xsl:template name="create-data-array">
    <xsl:param name="bucket-label"/>
    <xsl:param name="bucket"/>
    <xsl:param name="r"/>

    <xsl:value-of select="concat('{', $quot,'name',$quot, ':', $quot, $bucket-label, $quot, ', ' )"/>
    <xsl:text>&quot;data&quot;: [</xsl:text>

    <!-- for every year-->
    <xsl:for-each select="$r//lst[@name='facets']/lst[@name='year']/arr[@name='buckets']/lst">
      <xsl:choose>
        <xsl:when test="lst[@name=$inner-bucket-name]/arr/lst[str[@name='val'][text()=$bucket]]">
          <xsl:value-of select="lst[@name=$inner-bucket-name]/arr/lst[str[@name='val'][text()=$bucket]]/long[@name='count']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number(0)"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="not(position()=last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]}</xsl:text>
  </xsl:template>

  <xsl:template name="create-no-oa-data-array">
    <xsl:param name="bucket-label" select="document('notnull:i18n:stats.oa.notOA')/i18n/text()"/>
    <xsl:param name="r"/>

    <xsl:variable name="oa-identifiers">
      <xsl:for-each select="$inner-bucket-values-categories/@ID">
        <xsl:value-of select="."/>
        <xsl:if test="not(position()=last())">
          <xsl:value-of select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="concat('{', $quot, 'name', $quot, ':', $quot, $bucket-label, $quot, ', ' )"/>
    <xsl:text>&quot;data&quot;: [</xsl:text>
    <!-- for every year-->
    <xsl:for-each select="$r//lst[@name='facets']/lst[@name='year']/arr[@name='buckets']/lst">
      <xsl:variable name="total" select="long[@name='count']"/>
      <xsl:variable name="with-oa" select="sum(lst[@name=$inner-bucket-name]/arr/lst[(contains($oa-identifiers, str[@name='val']))]/long[@name='count'])"/>
      <xsl:value-of select="$total - $with-oa"/>
      <xsl:if test="not(position()=last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]}</xsl:text>
  </xsl:template>
</xsl:stylesheet>
