package de.vzg.koeln.search;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.ubo.matcher.MCRUserMatcher;
import org.mycore.ubo.matcher.MCRUserMatcherDTO;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserAttribute;
import org.mycore.user2.MCRUserManager;

import java.util.Optional;
import java.util.SortedSet;
import java.util.function.Predicate;
import java.util.stream.Collectors;

public class KoelnUserMatcher implements MCRUserMatcher {

    private final static Logger LOGGER = LogManager.getLogger();

    private static final String LEAD_ID = MCRConfiguration2.getStringOrThrow("MCR.user2.matching.lead_id");

    private static final String LEAD_ID_ATTRIBUTE = "id_" + LEAD_ID;

    private static final String KOELN_REALM = MCRConfiguration2.getStringOrThrow("MCR.user2.matching.KoelnRealm");

    @Override
    public MCRUserMatcherDTO matchUser(MCRUserMatcherDTO mcrUserMatcherDTO) {

        final SortedSet<MCRUserAttribute> attributes = mcrUserMatcherDTO.getMCRUser().getAttributes();
        final Optional<MCRUserAttribute> idAttribute = attributes.stream()
                .filter(id -> LEAD_ID_ATTRIBUTE.equals(id.getName())).findFirst();

        if (idAttribute.isEmpty()) {
            LOGGER.info("Attribute " + LEAD_ID_ATTRIBUTE + " not found.");
            return mcrUserMatcherDTO;
        }

        final String id = idAttribute.get().getValue();
        final PersonResult person = new KoelnRestSearcher().get(id);

        if (person == null) {
            LOGGER.info("No results for person with ID " + id);
            return mcrUserMatcherDTO;
        }

        final String displayName = person.getPse_givenname() + " " + person.getPse_surname();

        MCRUser user = MCRUserManager.getUser(id, KOELN_REALM);
        if (user == null) { // testing create every user
            user = new MCRUser(id, KOELN_REALM);
            user.setRealName(displayName);
            user.getAttributes().add(new MCRUserAttribute(LEAD_ID_ATTRIBUTE, id));
            MCRUserManager.createUser(user);
        }

        // only add not attributes which are not present
        user.getAttributes()
                .addAll(mcrUserMatcherDTO.getMCRUser().getAttributes().stream()
                        .filter(Predicate.not(user.getAttributes()::contains))
                        .collect(Collectors.toUnmodifiableList()));

        mcrUserMatcherDTO.setMCRUser(user);
        mcrUserMatcherDTO.setMatchedOrEnriched(true);

        return mcrUserMatcherDTO;
    }
}
