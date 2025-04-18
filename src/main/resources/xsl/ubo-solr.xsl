<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:str="http://exslt.org/strings"
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="mods xlink str xalan">

  <xsl:import href="xslImport:solr-document:ubo-solr.xsl" />
  <xsl:include href="coreFunctions.xsl"/>

  <xsl:key use="substring-after(@valueURI,'#')" name="destatisByCategory" match="//mods:mods/mods:classification[contains(@authorityURI,'destatis')]"></xsl:key>
  <xsl:variable name="origin"                   select="document('classification:metadata:-1:children:ORIGIN')/mycoreclass/categories" />

  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="." mode="baseFields" />
    <xsl:call-template   name="documentID" />
    <xsl:apply-templates select="structure/parents/parent[@xlink:href]" mode="solrField" />
    <xsl:apply-templates select="service/servflags/servflag[@type='status']" mode="solrField" />
    <xsl:apply-templates select="service/servflags/servflag[@type='importID']" mode="solrField" />
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="solrField" />

    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="mods:*[@authority or @authorityURI]|mods:typeOfResource|mods:accessCondition"  mode="category" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="structure/parents/parent" mode="solrField">
    <field name="parent">
      <xsl:value-of select="@xlink:href" />
    </field>
  </xsl:template>

  <xsl:template match="mods:mods" mode="solrField">
    <xsl:apply-templates select="mods:titleInfo" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:name[@type='personal']/mods:role/mods:roleTerm[@type='code']" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:name/mods:nameIdentifier" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:name[mods:nameIdentifier[@type='lsf']]" mode="solrField.lsf" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='lsf']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='orcid']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='dhsbid']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='researcherid']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='scopus']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]/mods:nameIdentifier[@type='gnd']" mode="solrField.ae" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[@type='code'][contains('aut cre tch pht prg edt ivr ive inv',text())]]" mode="solrField.ae_person" />
    <xsl:apply-templates select="mods:name[@type='personal'][mods:role/mods:roleTerm[contains(@authorityURI,'author_roles')]]" mode="solrField.ar" />
    <xsl:apply-templates select="descendant::mods:name[@type='personal']" mode="child" />
    <xsl:apply-templates select="mods:genre[@type='intern']" mode="solrField" />
    <xsl:apply-templates select="mods:accessCondition[@xlink:href]" mode="solrField" />
    <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:genre[@type='intern']" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'ORIGIN')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'fachreferate')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'project')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'fundingType')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'accessrights')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'peerreviewed')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'mediaType')]" mode="solrField" />
    <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:titleInfo[not(@type)]" mode="solrField.host" />
    <xsl:apply-templates select="mods:relatedItem[@type='host'][substring-after(mods:genre/@valueURI, '#') = 'journal']/mods:titleInfo" mode="solrField" />
    <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:part" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:originInfo" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:relatedItem[@type='series']/mods:titleInfo" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:name[@type='conference'][not(ancestor::mods:relatedItem[@type='references'])][1]" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:dateIssued[1]" mode="solrField" />
    <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:originInfo/mods:dateIssued[1]" mode="solrField.host" />
    <xsl:apply-templates select="descendant::mods:identifier[@type]" mode="solrField" />
    <xsl:apply-templates select="descendant::mods:shelfLocator" mode="solrField" />
    <xsl:apply-templates select="mods:subject" mode="solrField" />
    <xsl:apply-templates select="mods:note" mode="solrField" />
    <xsl:apply-templates select="mods:abstract" mode="solrField" />
    <xsl:apply-templates select="mods:language/mods:languageTerm[@type='code']" mode="solrField" />
    <xsl:apply-templates select="mods:extension/tag" mode="solrField" />
    <xsl:apply-templates select="mods:extension/dedup" mode="solrField" />
    <xsl:call-template name="sortby_person" />
    <xsl:call-template name="oa" />
    <xsl:call-template name="partOf" />
    <!-- xsl:call-template name="year" / -->
    <xsl:call-template name="destatis" />

    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'partner')]" mode="solrField" />
    <xsl:apply-templates select="mods:classification[contains(@authorityURI,'category')]" mode="solrField" />

  </xsl:template>

  <xsl:template name="sortby_person">
    <xsl:if test="mods:name[@type='personal']">
      <field name="sortby_person">
        <xsl:for-each select="mods:name[@type='personal']">
          <xsl:if test="position() &lt; 11">
            <xsl:value-of select="concat(mods:namePart[@type='family'],' ',mods:namePart[@type='given'],' ')" />
          </xsl:if>
        </xsl:for-each>
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template name="documentID" >
    <field name="ubo_documentID">
      <xsl:variable name="id_with_zeros" select="substring-after(@ID,'_mods_')" />
      <!-- output id without leading zeros -->
      <xsl:value-of select="number($id_with_zeros) * 1" />
    </field>
  </xsl:template>

  <xsl:template match="servflag[@type='status']" mode="solrField">
    <field name="status">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="servflag[@type='importID']" mode="solrField">
    <field name="importID">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:mods/mods:titleInfo" mode="solrField">
    <xsl:call-template name="buildTitleField">
      <xsl:with-param name="name">title</xsl:with-param>
    </xsl:call-template>
    <xsl:if test="position() = 1"> <!-- sort by first title only, not multivalued -->
      <field name="sortby_title">
        <xsl:apply-templates select="mods:title"    mode="solrField" />
        <xsl:apply-templates select="mods:subTitle" mode="solrField" />
      </field>
    </xsl:if>
    <xsl:if test="substring-after(../mods:genre/@valueURI, '#') = 'journal'">
      <xsl:call-template name="buildTitleField">
        <xsl:with-param name="name">journal</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']/mods:titleInfo[not(@type)]" mode="solrField.host">
    <xsl:call-template name="buildTitleField">
      <xsl:with-param name="name">host_title</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host'][substring-after(../mods:genre/@valueURI, '#') = 'journal']/mods:titleInfo" mode="solrField">
    <xsl:call-template name="buildTitleField">
      <xsl:with-param name="name">journal</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='series']/mods:titleInfo" mode="solrField">
    <xsl:call-template name="buildTitleField">
      <xsl:with-param name="name">series</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="buildTitleField">
    <xsl:param name="name" />

    <field name="{$name}">
      <xsl:apply-templates select="mods:nonSort"  mode="solrField" />
      <xsl:apply-templates select="mods:title"    mode="solrField" />
      <xsl:apply-templates select="mods:subTitle" mode="solrField" />
    </field>
  </xsl:template>

  <xsl:template match="mods:nonSort" mode="solrField">
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="mods:title" mode="solrField">
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:subTitle" mode="solrField">
    <xsl:variable name="lastCharOfTitle" select="substring(../mods:title,string-length(../mods:title))" />
    <xsl:if test="translate($lastCharOfTitle,'?!.:,-;','.......') != '.'">
      <xsl:text> :</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']/mods:role/mods:roleTerm[@type='code']" mode="solrField">
    <field name="person_{text()}">
      <xsl:apply-templates select="../.." mode="solrField" />
    </field>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal'][mods:role/mods:roleTerm[contains(@authorityURI,'author_roles')]]" mode="solrField.ar">
    <field name="corresponding_aut">
      <xsl:apply-templates select="." mode="solrField"/>
    </field>

    <xsl:for-each select="mods:nameIdentifier"><!-- TODO: besser nur connection-ID bzw. 2 Suchfelder? -->
      <field name="corresponding_aut_id">
        <xsl:value-of select="."/>
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']" mode="solrField">
    <xsl:value-of select="mods:namePart[@type='family']" />
    <xsl:for-each select="mods:namePart[@type='given'][1]">
      <xsl:value-of select="concat(', ',text())" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:name[@type='conference']" mode="solrField">
    <field name="conference">
      <xsl:value-of select="mods:namePart" />
    </field>
  </xsl:template>

  <xsl:template match="mods:name/mods:nameIdentifier" mode="solrField">
    <field name="nid_{@type}">
      <xsl:value-of select="text()" />
    </field>

    <field name="{@type}_nid_text">
      <xsl:value-of select="../mods:namePart[@type='family']" />
      <xsl:for-each select="../mods:namePart[@type='given'][1]">
        <xsl:value-of select="concat(', ',text())" />
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:name[mods:nameIdentifier[@type='lsf']]" mode="solrField.lsf">
    <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
      <field name="role_lsf">
        <xsl:value-of select="." />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="../../mods:nameIdentifier[@type='lsf']" />
      </field>
      <field name="role_lsf"> <!-- support for legacy role codes -->
        <xsl:choose>
          <xsl:when test=".='aut'">author</xsl:when>
          <xsl:when test=".='edt'">publisher</xsl:when>
          <xsl:when test=".='ths'">advisor</xsl:when>
          <xsl:when test=".='rev'">referee</xsl:when>
          <xsl:when test=".='trl'">translator</xsl:when>
          <xsl:when test=".='ctb'">contributor</xsl:when>
          <xsl:otherwise>contributor</xsl:otherwise>
        </xsl:choose>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="../../mods:nameIdentifier[@type='lsf']" />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']" mode="solrField.ae_person">
    <field name="ae_person">
      <xsl:value-of select="mods:namePart[@type='family']" />
      <xsl:for-each select="mods:namePart[@type='given'][1]">
        <xsl:value-of select="concat(', ',text())" />
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type='orcid']" mode="solrField.ae">
    <field name="ae_orcid">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type='lsf']" mode="solrField.ae">
    <field name="ae_lsf">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[@type='dhsbid']" mode="solrField.ae">
    <field name="ae_dhsbid">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[@type='researcherid']" mode="solrField.ae">
    <field name="ae_researcherid">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[@type='scopus']" mode="solrField.ae">
    <field name="ae_scopus">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[@type='gnd']" mode="solrField.ae">
    <field name="ae_gnd">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:mods/mods:genre[@type='intern']" mode="solrField">
    <field name="genre">
      <xsl:value-of select="substring-after(@valueURI, '#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@xlink:href]" mode="solrField">
    <field name="license">
      <xsl:value-of select="substring-after(@xlink:href, '#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']/mods:genre[@type='intern']" mode="solrField">
    <field name="host_genre">
      <xsl:value-of select="substring-after(@valueURI, '#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'ORIGIN')]" mode="solrField">
    <xsl:variable name="category" select="substring-after(@valueURI,'#')" />
    <xsl:for-each select="document(concat('classification:editor:0:parents:ORIGIN:',$category))/descendant::item">
      <field name="origin">
        <xsl:value-of select="@value" />
      </field>
      <xsl:if test="position()=1">
        <field name="origin_toplevel">
          <xsl:value-of select="@value" />
        </field>
      </xsl:if>
    </xsl:for-each>
    <field name="origin_exact">
      <xsl:value-of select="$category" />
    </field>
    <field name="origin_text">
       <xsl:value-of select="$origin//category[@ID=$category]/label[lang($DefaultLang)]/@text"/>
    </field>
  </xsl:template>

  <xsl:template name="oa">
    <xsl:choose>
      <xsl:when test="mods:classification[contains(@authorityURI,'oa')]">
        <xsl:apply-templates select="mods:classification[contains(@authorityURI,'oa')][1]" mode="solrField" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:classification[contains(@authorityURI,'oa')][1]" mode="solrField" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'oa')]" mode="solrField">
    <xsl:variable name="category" select="substring-after(@valueURI,'#')" />
    <field name="oa_exact">
      <xsl:value-of select="$category" />
    </field>
    <xsl:for-each select="document(concat('classification:editor:0:parents:oa:',$category))/descendant::item">
      <field name="oa">
        <xsl:value-of select="@value" />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'fachreferate')]" mode="solrField">
    <field name="subject">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'project')]" mode="solrField">
    <field name="project">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'fundingType')]" mode="solrField">
    <field name="fundingType">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'accessrights')]" mode="solrField">
    <field name="koeln_accessrights">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'peerreviewed')]" mode="solrField">
    <field name="koeln_peerreviewed">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
    <xsl:if test="substring-after(@valueURI,'#') = 'true'">
      <field name="peerreviewed">
        <xsl:value-of select="substring-after(@valueURI,'#')" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'mediaType')]" mode="solrField">
    <field name="mediaType">
      <xsl:value-of select="substring-after(@valueURI,'#')"/>
    </field>
  </xsl:template>

  <xsl:template name="destatis">
    <!-- to avoid duplicates, only use first occurence of each destatis category -->
     <xsl:for-each select="mods:classification[contains(@authorityURI,'destatis')][generate-id() = generate-id(key('destatisByCategory',substring-after(@valueURI,'#'))[1])]">
       <field name="destatis">
         <xsl:value-of select="substring-after(@valueURI,'#')"/>
       </field>
     </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'partner')]" mode="solrField">
    <field name="koeln_partner">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'category')]" mode="solrField">
    <field name="koeln_category">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template name="partOf">
    <xsl:choose>
      <xsl:when test="mods:classification[contains(@authorityURI,'partOf')]">
        <xsl:apply-templates select="mods:classification[contains(@authorityURI,'partOf')]" mode="solrField" />
      </xsl:when>
      <xsl:otherwise>
        <field name="partOf">
          <xsl:value-of select="'false'" />
        </field>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:classification[contains(@authorityURI,'partOf')]" mode="solrField">
    <field name="partOf">
      <xsl:value-of select="substring-after(@valueURI,'#')" />
    </field>
  </xsl:template>

  <xsl:template match="mods:dateIssued" mode="solrField">
    <xsl:variable name="yearIssued">
      <xsl:choose>
        <xsl:when test="contains(.,'-')">
          <xsl:value-of select="substring-before(.,'-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="translate($yearIssued,'1234567890','YYYYYYYYYY')='YYYY'">
      <field name="year">
        <xsl:value-of select="$yearIssued" />
      </field>
    </xsl:if>
    <xsl:if test="contains(.,'-')">
      <field name="koeln_dateIssued">
        <xsl:value-of select="text()" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']/mods:originInfo/mods:dateIssued" mode="solrField.host">
    <xsl:variable name="yearIssued">
      <xsl:choose>
        <xsl:when test="contains(.,'-')">
          <xsl:value-of select="substring-before(.,'-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="translate($yearIssued,'1234567890','YYYYYYYYYY')='YYYY'">
      <field name="host_year">
        <xsl:value-of select="$yearIssued" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods/mods:identifier[@type]" mode="solrField">
    <field name="id_{@type}">
      <xsl:value-of select="text()" />
    </field>
    <field name="pub_id_{@type}">
      <xsl:value-of select="text()" />
    </field>
    <xsl:if test="@type='uri' and contains(text(), 'uri.gbv.de/document') and contains(text(), ':ppn:')">
      <field name="id_ppn">
        <xsl:value-of select="substring-after(text(), ':ppn:')" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:relatedItem[(@type='host') or (@type='series')]/mods:identifier[@type]" mode="solrField">
    <field name="id_{@type}">
      <xsl:value-of select="text()" />
    </field>
    <field name="host_id_{@type}">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:shelfLocator" mode="solrField">
    <field name="shelfmark">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@type='code']" mode="solrField">
    <field name="lang">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:subject" mode="solrField">
    <xsl:for-each select="mods:topic">
      <xsl:for-each select="str:tokenize(text(),',;')">
    <field name="topic">
          <xsl:value-of select="." />
    </field>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:note" mode="solrField">
    <xsl:if test="@type = 'intern'">
      <field name="note.intern">
        <xsl:value-of select="text()" />
      </field>
    </xsl:if>

    <field name="note">
      <xsl:value-of select="text()" />
    </field>
    <xsl:if test="contains(.,'Univ') and contains(.,'Diss') and ( contains(.,'Essen') or contains(.,'Duisburg') ) and contains( translate(.,'0123456789','JJJJJJJJJJ'),'JJJJ')">
      <xsl:variable name="jjjj" select="translate(.,'0123456789','JJJJJJJJJJ')" />
      <xsl:variable name="before" select="substring-before($jjjj,'JJJJ')" />
      <field name="year_diss">
        <xsl:value-of select="substring(substring-after(.,$before),1,4)" />
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:abstract" mode="solrField">
    <field name="abstract">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:extension/tag" mode="solrField">
    <field name="tag">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:extension/dedup" mode="solrField">
    <field name="dedup">
      <xsl:value-of select="@key" />
    </field>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']" mode="child">
    <doc>
      <field name="objectKind">name</field>
      <field name="id">
        <xsl:value-of select="concat(ancestor::mycoreobject/@ID,'_',generate-id(.))" />
      </field>
      <field name="name">
        <xsl:apply-templates select="." mode="solrField" />
      </field>
      <xsl:apply-templates select="mods:nameIdentifier" mode="child" />
      <xsl:for-each select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']">
        <xsl:if test="not(ancestor::mods:relatedItem)">
          <field name="role">
            <xsl:value-of select="concat(text(),'.top')"/>
          </field>
        </xsl:if>
        <field name="role">
          <xsl:value-of select="text()"/>
        </field>
      </xsl:for-each>
    </doc>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier" mode="child">
    <field name="name_id_type">
      <xsl:value-of select="@type" />
    </field>
    <field name="name_id_{@type}">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <xsl:template match="mods:part" mode="solrField">
    <xsl:for-each select="mods:detail[@type='volume']">
      <field name="volume">
        <xsl:value-of select="mods:number" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:detail[@type='issue']">
      <field name="issue">
        <xsl:value-of select="mods:number" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:detail[@type='page']">
      <field name="pages">
        <xsl:value-of select="mods:number" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:extent[@unit='pages']">
      <field name="pages">
        <xsl:value-of select="mods:list" />
        <xsl:value-of select="mods:start" />
        <xsl:for-each select="mods:end">
          <xsl:text> - </xsl:text>
          <xsl:value-of select="." />
        </xsl:for-each>
        <xsl:for-each select="mods:total[../mods:start]">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="." />
          <xsl:text>)</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="mods:total[not(../mods:start)]">
          <xsl:value-of select="." />
        </xsl:for-each>
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:detail[@type='article_number']">
      <field name="article_number">
        <xsl:value-of select="mods:number" />
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:*[@authority or @authorityURI]|mods:typeOfResource|mods:accessCondition" mode="category">
    <xsl:variable name="uri" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" select="mcrmods:getClassCategParentLink(.)" />
    <xsl:if test="string-length($uri) &gt; 0">
      <xsl:variable name="topField" select="not(ancestor::mods:relatedItem)" />
      <xsl:variable name="classdoc" select="document($uri)" />
      <xsl:variable name="classid" select="$classdoc/mycoreclass/@ID" />
      <xsl:apply-templates select="$classdoc//category" mode="category">
        <xsl:with-param name="classid" select="$classid" />
        <xsl:with-param name="withTopField" select="$topField" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:originInfo" mode="solrField">
    <xsl:for-each select="mods:place">
      <field name="place">
        <xsl:value-of select="mods:placeTerm" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:publisher">
      <field name="publisher">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
