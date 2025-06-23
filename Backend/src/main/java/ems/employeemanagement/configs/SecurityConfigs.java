package ems.employeemanagement.configs;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractAuthenticationFilterConfigurer;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfigs {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, PersistenceExceptionTranslationPostProcessor persistenceExceptionTranslationPostProcessor) throws Exception {
        http.authorizeHttpRequests(authz ->
                authz.requestMatchers("/**").authenticated().requestMatchers("/fetch").permitAll()
        ).formLogin(AbstractAuthenticationFilterConfigurer::permitAll);
        return http.build();
    }

    @Bean
    public UserDetailsService userDetails(PasswordEncoder passwordEncoder){
        UserDetails user  = User.withUsername("kiruthick").password(passwordEncoder.encode("12345")).roles("USER").build();

        UserDetails admin = User.withUsername("admin").password(passwordEncoder.encode("admin123")).roles("ADMIN").build();

        return new InMemoryUserDetailsManager(user, admin);
    }
    @Bean
    public BCryptPasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }
}
