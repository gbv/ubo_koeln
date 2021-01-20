package de.vzg.koeln.search;

import com.google.common.base.Charsets;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.jdom2.Element;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;


import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class KoelnRestSearcher implements PersonSearcher {

    public KoelnRestSearcher(){
    }

    private static final String PERSON_REST_PROPERTY_PREFIX = "MCR.IdentityPicker.PersonRest.";

    private static final String API_URL_PROPERTY = PERSON_REST_PROPERTY_PREFIX + "API_URL";

    private static final String API_USER = PERSON_REST_PROPERTY_PREFIX + "User";

    private static final String API_PASSWORD = PERSON_REST_PROPERTY_PREFIX + "Password";

    private static final String ACCEPT = "application/json";

    private static final String CONTENT_TYPE = "application/json";

    private static final int ROW_COUNT = 20;

    public PersonResult get(String id){
        final HttpGet get = new HttpGet(getRestURI()+"persons/"+id);
        get.setHeader("Content-Type", CONTENT_TYPE);
        get.setHeader(HttpHeaders.AUTHORIZATION,"Basic "+ getEncodedAuth());

        try (CloseableHttpClient client = HttpClientBuilder.create().build()) {
            try (CloseableHttpResponse response = client.execute(get)) {
                if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                    try (final InputStream content = response.getEntity().getContent()) {
                        try (final InputStreamReader isr = new InputStreamReader(content, Charsets.UTF_8)) {
                            final Gson gson = getGson();
                            return gson.fromJson(isr, PersonResult.class);
                        }
                    }
                } else {
                    return null;
                }
            }
        } catch (IOException e) {
            throw new MCRException("Error while building HTTPClient!");
        }
    }

    public Element search(String term) {
        final HttpPost httpPost = new HttpPost(getRestURI()+"personsearch");
        httpPost.setHeader("accept", ACCEPT);
        httpPost.setHeader("Content-Type", CONTENT_TYPE);
        httpPost.setHeader(HttpHeaders.AUTHORIZATION,"Basic "+ getEncodedAuth());

        final String requestBody = buildRequestBody(term);
        httpPost.setEntity(new StringEntity(requestBody, ContentType.APPLICATION_JSON));

        try (CloseableHttpClient client = HttpClientBuilder.create().build()) {
            try (CloseableHttpResponse response = client.execute(httpPost)) {
                if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                    try (final InputStream content = response.getEntity().getContent()) {
                        try (final InputStreamReader isr = new InputStreamReader(content, Charsets.UTF_8)) {
                            final Gson gson = getGson();
                            final PersonListResult listResult = gson.fromJson(isr, PersonListResult.class);
                            return buildResultDocument(listResult);
                        }
                    }
                } else {
                    return buildResultDocument(new PersonListResult());
                }
            }
        } catch (IOException e) {
            throw new MCRException("Error while building HTTPClient!");
        }
    }

    @Override
    public Element search(String forename, String surename) {
        return search(forename + " " + surename);
    }

    private Gson getGson() {
        return new GsonBuilder().serializeNulls().create();
    }

    private Element buildResultDocument(PersonListResult listResult) {
        final Element results = new Element("results");
        Optional.ofNullable(listResult.getPersons()).ifPresent((list) -> {
            list.stream().map(personJson -> {
                final Element personElement = new Element("person");

                elementWithContent("id", personJson.getId(), personElement);
                elementWithContent("firstName", personJson.getPse_givenname(), personElement);
                elementWithContent("lastName", personJson.getPse_surname(), personElement);
                elementWithContent("academicDegree", personJson.getAcademic_degree(), personElement);
                elementWithContent("faculty", displayList(personJson.getFaculty_de()),
                        personElement);
                elementWithContent("institute", displayList(personJson.getInstitute_de()),
                        personElement);
                elementWithContent("institution", displayList(personJson.getOther_institution_de()), personElement);


                return personElement;
            }).forEach(results::addContent);
        });
        return results;
    }

    private String displayList(List<String> other_institution_de) {
        if(other_institution_de==null){
            return  "";
        }
        return other_institution_de.stream().collect(Collectors.joining(", "));
    }

    private void elementWithContent(String name, String content, Element parent) {
        if (content != null && !content.isEmpty()) {
            final Element element = new Element(name);
            element.addContent(content);
            parent.addContent(element);
        }
    }

    private String buildRequestBody(String userInput) {
        final Gson gson = getGson();
        final JsonObject search = new JsonObject();

        search.addProperty("rows", ROW_COUNT);
        search.addProperty("term", userInput);

        return gson.toJson(search);
    }

    private URI getRestURI() {
        try {
            return new URI(MCRConfiguration2.getStringOrThrow(API_URL_PROPERTY));
        } catch (URISyntaxException e) {
            throw new MCRConfigurationException("Error while reading " + API_URL_PROPERTY, e);
        }
    }

    private String getEncodedAuth() {
        final byte[] encoded = Base64.getEncoder().encode((getUsername() + ":" + getPassword()).getBytes(Charsets.UTF_8));
        return new String(encoded);
    }

    private String getPassword() {
        return MCRConfiguration2.getStringOrThrow(API_PASSWORD);
    }

    private String getUsername() {
        return MCRConfiguration2.getStringOrThrow(API_USER);
    }

}
