package com.lulibrisync.config;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

public final class ActiveSessionManager {

    public static final String ACTIVE_SESSION_ID = "lu_librisync_active_session_id";
    private static final String ACTIVE_USER_NAME = "lu_librisync_active_user_name";
    private static final String ACTIVE_USER_ROLE = "lu_librisync_active_user_role";

    private ActiveSessionManager() {
    }

    public static boolean tryAcquire(ServletContext context, HttpSession session, String userName, String userRole) {
        if (context == null || session == null) {
            return false;
        }

        synchronized (context) {
            String activeSessionId = asText(context.getAttribute(ACTIVE_SESSION_ID));
            if (activeSessionId != null && !activeSessionId.equals(session.getId())) {
                return false;
            }

            context.setAttribute(ACTIVE_SESSION_ID, session.getId());
            context.setAttribute(ACTIVE_USER_NAME, userName == null ? "" : userName);
            context.setAttribute(ACTIVE_USER_ROLE, userRole == null ? "" : userRole);
            return true;
        }
    }

    public static void releaseIfOwned(ServletContext context, HttpSession session) {
        if (context == null || session == null) {
            return;
        }

        synchronized (context) {
            String activeSessionId = asText(context.getAttribute(ACTIVE_SESSION_ID));
            if (activeSessionId != null && activeSessionId.equals(session.getId())) {
                context.removeAttribute(ACTIVE_SESSION_ID);
                context.removeAttribute(ACTIVE_USER_NAME);
                context.removeAttribute(ACTIVE_USER_ROLE);
            }
        }
    }

    private static String asText(Object value) {
        if (value == null) {
            return null;
        }

        String text = String.valueOf(value).trim();
        return text.isEmpty() ? null : text;
    }
}
