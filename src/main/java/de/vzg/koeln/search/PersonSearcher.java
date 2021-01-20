package de.vzg.koeln.search;

import org.jdom2.Element;

public interface PersonSearcher {
    /**
     * @return
     * <code>
     * &lt;results&gt;
     *   &lt;person&gt;
     *     &lt;id&gt;&lt;/id&gt;
     *     &lt;name&gt;&lt;/name&gt;
     *     &lt;institution&gt;&lt;/institution&gt;
     *     &lt;academicDegree&gt;&lt;/academicDegree&gt;
     *     &lt;faculty&gt;&lt;/faculty&gt;
     *     &lt;institute&gt;&lt;/institute&gt;
     *   &lt;/person&gt;
     *   &lt;person&gt;
     *     &lt;id&gt;&lt;/id&gt;
     *     &lt;name&gt;&lt;/name&gt;
     *     &lt;institution&gt;&lt;/institution&gt;
     *     &lt;academicDegree&gt;&lt;/academicDegree&gt;
     *     &lt;faculty&gt;&lt;/faculty&gt;
     *     &lt;institute&gt;&lt;/institute&gt;
     *   &lt;/person&gt;
     * &lt;/results&gt;
     * </code>
     */
    Element search(String forename, String surename);
}
