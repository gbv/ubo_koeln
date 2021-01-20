package de.vzg.koeln.login;

/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.MCRSession;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRUserInformation;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.jersey.MCRJWTUtil;
import org.mycore.frontend.servlets.MCRServlet;
import org.mycore.frontend.servlets.MCRServletJob;
import org.mycore.user2.MCRRealm;
import org.mycore.user2.MCRRealmFactory;
import org.mycore.user2.MCRTransientUser;
import org.mycore.user2.MCRUser;
import org.mycore.user2.MCRUserAttribute;
import org.mycore.user2.MCRUserAttributeMapper;
import org.mycore.user2.MCRUserManager;
import org.mycore.user2.annotation.MCRUserAttributeJavaConverter;
import org.mycore.user2.utils.MCRRolesConverter;

/**
 *
 * @author Sebastian Hofmann
 */
public class MCRShibbolethLoginServlet2 extends MCRServlet {

    private static final long serialVersionUID = 1L;

    private static final Logger LOGGER = LogManager.getLogger(MCRShibbolethLoginServlet2.class);
    private static final String ATTRIBUTES_TO_COPY = "UBO.Shibboleth.CopyAttributes";

    public void doGetPost(MCRServletJob job) throws Exception {
        HttpServletRequest req = job.getRequest();
        HttpServletResponse res = job.getResponse();

        String msg = null;

        String uid = (String) req.getAttribute("uid");
        String userId = uid != null ? uid : req.getRemoteUser();

        if (userId != null) {
            final String realmId = userId.contains("@") ? userId.substring(userId.indexOf("@") + 1) : null;
            if (realmId != null && MCRRealmFactory.getRealm(realmId) != null) {
                userId = (String) req.getAttribute("idmEduDhsbPersonId");

                final Map<String, Object> attributes = new HashMap<>();

                final MCRUserAttributeMapper attributeMapper = MCRRealmFactory.getAttributeMapper(realmId);
                for (final String key : attributeMapper.getAttributeNames()) {
                    final Object value = req.getAttribute(key);
                    if (value != null) {
                        LOGGER.info("received {}:{}", key, value);
                        attributes.put(key, value);
                    }
                }

                MCRUserInformation userinfo;
                MCRUser user = MCRUserManager.getUser(userId, realmId);
                if (user == null) {
                    LOGGER.info("The User  " + userId + " does not exist. Create it!");
                    userinfo = new MCRTransientUserInformation(userId, realmId, attributes);
                    final MCRTransientUser shibUser = new MCRTransientUser(userinfo);
                    copyAttributes(req, shibUser);
                    addRoles(shibUser);
                    shibUser.setLastLogin();
                    MCRUserManager.createUser(shibUser);
                } else {
                    attributeMapper.mapAttributes(user, attributes);
                    copyAttributes(req, user);
                    user.setLastLogin();
                    addRoles(user);
                    MCRUserManager.updateUser(user);
                    userinfo = user;
                }

                MCRSessionMgr.getCurrentSession().setUserInformation(userinfo);
                // MCR-1154
                req.changeSessionId();

                res.sendRedirect(res.encodeRedirectURL(req.getParameter("url")));
                return;
            } else {
                msg = "Login from realm \"" + realmId + "\" is not allowed.";
            }
        } else {
            msg = "Principal could not be received from IDP.";
        }

        job.getResponse().sendError(HttpServletResponse.SC_UNAUTHORIZED, msg);
    }

    private void addRoles(MCRUser user){
        final String userID = user.getUserID();
        LOGGER.info("User is : " + userID);
        MCRConfiguration2.getString("UBO.Shibboleth.RoleMap").ifPresent(roleMap-> {
            final String[] roles = roleMap.split(",");
            for (String userRole : roles) {
                LOGGER.debug("Role part is " + userRole);
                if (userRole.isBlank()) {
                    LOGGER.warn("Role is blank!");
                    continue;
                }
                final int splitIndex = userRole.indexOf(":");
                if(splitIndex<0){
                    LOGGER.warn("Split index is invalid " + splitIndex + " for " + userRole + "!");
                    continue;
                }
                String userName = userRole.substring(0, splitIndex);
                String role = userRole.substring(splitIndex+1) ;

                LOGGER.debug("Role mapping " + userID + " -> " + role);
                if(userName.equals(userID)){
                    LOGGER.info("Adding role " + role+ " to user " + userID);
                    user.getSystemRoleIDs().add(role);
                } else {
                    LOGGER.debug("Username doesnt match " + userName + "!=" + userID);
                }
            }
        });
    }

    private void copyAttributes(HttpServletRequest req, MCRUser user) {
        MCRConfiguration2.getString(ATTRIBUTES_TO_COPY).ifPresent((copyAttributes) -> {
            final String[] attrs = copyAttributes.split(",");
            for (String attr : attrs) {
                if (attr.isBlank()) {
                    continue;
                }
                final int splitIndex = attr.indexOf(":");
                String attrNameMyCoRe = splitIndex > 0 ? attr.substring(0, splitIndex) : attr;
                String attrNameShibboleth = splitIndex > 0 ? attr.substring(splitIndex+1) : attr;
                LOGGER.info("Mapping found " + attrNameShibboleth + "-" + attrNameMyCoRe);
                final String value = (String) req.getAttribute(attrNameShibboleth);
                if (value != null) {
                    final Optional<MCRUserAttribute> existingAttribute = user.getAttributes().stream().filter(a -> a.getName().equals(attrNameMyCoRe)).findAny();
                    if(existingAttribute.isPresent()){
                        LOGGER.info("Attribute " + attrNameMyCoRe + " already exists for user " + user.getUserID()+ " update it!");
                        existingAttribute.get().setValue(value);
                    } else {
                        LOGGER.info("Adding custom Attribute " + attrNameMyCoRe + " to user " + user.getUserID() + "!");
                        user.getAttributes().add(new MCRUserAttribute(attrNameMyCoRe, value));
                    }
                }
            }
        });
    }

    public static class MCRTransientUserInformation implements MCRUserInformation{
        private String userId;

        private String realmId;

        private Map<String, Object> attributes;

        @org.mycore.user2.annotation.MCRUserAttribute
        private String realName;

        private Set<String> roles = new HashSet<>();

        public MCRTransientUserInformation(String userId, String realmId, Map<String, Object> attributes)
                throws Exception {
            MCRUserAttributeMapper attributeMapper = MCRRealmFactory.getAttributeMapper(realmId);
            if (attributeMapper != null) {
                attributeMapper.mapAttributes(this, attributes);
            }

            this.userId = userId;
            this.realmId = realmId;
            this.attributes = attributes;
        }

        /* (non-Javadoc)
         * @see org.mycore.common.MCRUserInformation#getUserID()
         */
        @Override
        public String getUserID() {
            return userId + "@" + realmId;
        }

        /* (non-Javadoc)
         * @see org.mycore.common.MCRUserInformation#isUserInRole(java.lang.String)
         */
        @Override
        public boolean isUserInRole(String role) {
            return roles.contains(role);
        }

        /* (non-Javadoc)
         * @see org.mycore.common.MCRUserInformation#getUserAttribute(java.lang.String)
         */
        @Override
        public String getUserAttribute(String attribute) {
            String key;
            switch (attribute) {
                case MCRUserInformation.ATT_REAL_NAME:
                    return this.realName;
                case MCRRealm.USER_INFORMATION_ATTR:
                    return this.realmId;
                default:
                    key = attribute;
                    break;
            }

            Object value = attributes.get(key);

            return value != null ? value.toString() : null;
        }

        // This is used for MCRUserAttributeMapper

        Collection<String> getRoles() {
            return roles;
        }

        @org.mycore.user2.annotation.MCRUserAttribute(name = "roles", separator = ";")
        @MCRUserAttributeJavaConverter(MCRRolesConverter.class)
        void setRoles(Collection<String> roles) {
            this.roles.addAll(roles);
        }
    }
}
