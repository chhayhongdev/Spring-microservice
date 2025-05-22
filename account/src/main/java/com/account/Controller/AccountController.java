package com.account.Controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;

@RefreshScope
@RestController
public class AccountController {
    
    @Value("${accounts.msg}")
    private String message;

    @GetMapping("/test-config")
    public String getConfigMsg() {
        return message;
    }
}
