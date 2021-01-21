package de.vzg.koeln.search;

import org.jdom2.Element;
import org.mycore.ubo.picker.IdentityService;

import java.util.Map;

public class KoelnService implements IdentityService {
    @Override
    public Element getPersonDetails(Map<String, String> paramMap) {
        return null;
    }

    @Override
    public Element searchPerson(Map<String, String> paramMap) {
        final Element search = new KoelnRestSearcher().search(paramMap.get("firstName"), paramMap.get("lastName"));

        return search;
    }
}
