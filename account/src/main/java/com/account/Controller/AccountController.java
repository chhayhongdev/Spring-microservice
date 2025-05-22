package com.account.Controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Value;

@RestController
public class AccountController {
    
    @Value("${accounts.mailDetails.subject}")
    private String message;

    @GetMapping("/test-config")
    public String getConfigMsg() {
        return message;
    }
}
