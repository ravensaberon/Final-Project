package com.lulibrisync.api.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.http.HttpServletResponse;
import java.util.LinkedHashMap;
import java.util.Map;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class ApiSecurityConfig extends WebSecurityConfigurerAdapter {

    private final ApiUserDetailsService apiUserDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public ApiSecurityConfig(ApiUserDetailsService apiUserDetailsService, JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.apiUserDetailsService = apiUserDetailsService;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(apiUserDetailsService).passwordEncoder(passwordEncoder());
    }

    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .antMatcher("/api/**")
                .csrf().disable()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                .and()
                .authorizeRequests()
                .antMatchers(HttpMethod.POST, "/api/auth/login", "/api/auth/register").permitAll()
                .antMatchers("/api/admin/**").hasRole("ADMIN")
                .antMatchers("/api/student/**").hasAnyRole("STUDENT", "ADMIN")
                .anyRequest().hasAnyRole("ADMIN", "STUDENT")
                .and()
                .exceptionHandling()
                .authenticationEntryPoint((request, response, authException) ->
                        writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized request."))
                .accessDeniedHandler((request, response, accessDeniedException) ->
                        writeJson(response, HttpServletResponse.SC_FORBIDDEN, "Access denied for this role."));

        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
    }

    private void writeJson(HttpServletResponse response, int statusCode, String message) {
        try {
            response.setStatus(statusCode);
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("status", statusCode);
            body.put("message", message);
            body.put("success", false);

            new ObjectMapper().writeValue(response.getWriter(), body);
        } catch (Exception ignored) {
        }
    }
}
