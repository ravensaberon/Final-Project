package com.lulibrisync.api.security;

import com.lulibrisync.api.model.ApiUser;
import com.lulibrisync.api.repository.ApiUserRepository;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Service
public class ApiUserDetailsService implements UserDetailsService {

    private final ApiUserRepository apiUserRepository;

    public ApiUserDetailsService(ApiUserRepository apiUserRepository) {
        this.apiUserRepository = apiUserRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        ApiUser user = apiUserRepository.findByEmail(username.toLowerCase())
                .orElseThrow(() -> new UsernameNotFoundException("User not found."));

        List<GrantedAuthority> authorities = Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + user.getRole().toUpperCase())
        );

        boolean enabled = "ACTIVE".equalsIgnoreCase(user.getStatus());
        return new User(
                user.getEmail(),
                user.getPassword(),
                enabled,
                true,
                true,
                true,
                authorities
        );
    }
}
