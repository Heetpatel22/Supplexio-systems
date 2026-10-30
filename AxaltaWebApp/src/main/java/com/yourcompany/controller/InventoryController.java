package main.java.com.yourcompany.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class InventoryController {
    @GetMapping("/inventory")
    public String inventoryPage() {
        return "inventory/inventory";
    }
}