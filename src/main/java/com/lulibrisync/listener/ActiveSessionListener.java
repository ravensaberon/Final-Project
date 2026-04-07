package com.lulibrisync.listener;

import com.lulibrisync.config.ActiveSessionManager;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

@WebListener
public class ActiveSessionListener implements HttpSessionListener {

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        ActiveSessionManager.releaseIfOwned(se.getSession().getServletContext(), se.getSession());
    }
}
