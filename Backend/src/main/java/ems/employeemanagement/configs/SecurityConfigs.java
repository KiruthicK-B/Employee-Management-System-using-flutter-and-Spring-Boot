package ems.employeemanagement.configs;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractAuthenticationFilterConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfigs {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, PersistenceExceptionTranslationPostProcessor persistenceExceptionTranslationPostProcessor) throws Exception {
        http.authorizeHttpRequests(authz ->
                authz.requestMatchers("/**").authenticated().requestMatchers("/home").permitAll()
        ).formLogin(AbstractAuthenticationFilterConfigurer::permitAll);
        return http.build();
    }
}
