package de.vzg.koeln.search;

import org.jdom2.Element;
import org.mycore.ubo.picker.IdentityService;
import org.mycore.ubo.picker.PersonSearchResult;

import javax.naming.OperationNotSupportedException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

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

    @Override
    public PersonSearchResult searchPerson(String query) throws OperationNotSupportedException {
        KoelnRestSearcher searcher = new KoelnRestSearcher();

        PersonListResult search = searcher.search(query);
        List<PersonResult> persons = search.getPersons();
        List<PersonSearchResult.PersonResult> personResults = persons.stream().map(person -> {
            PersonSearchResult.PersonResult personResult = new PersonSearchResult.PersonResult();
            personResult.pid = person.getId();

            personResult.displayName = Stream.of(person.getPse_givenname(), person.getPse_surname())
                    .filter(Objects::nonNull)
                    .collect(Collectors.joining());
            personResult.firstName = person.getPse_givenname();
            personResult.lastName = person.getPse_surname();

            personResult.affiliation = new ArrayList<>();
            Stream.of(person.getInstitute_de(),
                    person.getFaculty_de(),
                    person.getOther_institution_de())
                    .forEach(personResult.affiliation::addAll);

            personResult.information = new ArrayList<>();
            personResult.information.add(person.getAcademic_degree());


            return personResult;
        }).collect(Collectors.toList());

        PersonSearchResult searchResult = new PersonSearchResult();

        searchResult.personList = personResults;
        searchResult.count = personResults.size();

        return searchResult;
    }

}
