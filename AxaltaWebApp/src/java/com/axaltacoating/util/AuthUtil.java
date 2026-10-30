package com.axaltacoating.util;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class for authentication operations with simple password handling.
 */
public class AuthUtil {
    private static final Logger LOGGER = Logger.getLogger(AuthUtil.class.getName());
    
    /**
     * Simply returns the password as-is for storage.
     * Note: This is not secure for production use as passwords are stored in plain text.
     * 
     * @param password The password to store
     * @return The password unchanged
     */
    public static String hashPassword(String password) {
        // No hashing, just return the password as-is
        LOGGER.log(Level.INFO, "Storing password without hashing");
        return password;
    }
    
    /**
     * Verifies a password with a simple string comparison.
     * 
     * @param password The password to verify
     * @param storedPassword The stored password to check against
     * @return True if the password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedPassword) {
        // Simple string comparison
        boolean matches = password.equals(storedPassword);
        if (!matches) {
            LOGGER.log(Level.INFO, "Password verification failed");
        }
        return matches;
    }
    
    /**
     * Generates a simple session token for the user.
     * 
     * @param username The username to generate a token for
     * @return A session token
     */
    public static String generateSessionToken(String username) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] tokenBytes = new byte[32];
            random.nextBytes(tokenBytes);
            
            // Add timestamp for uniqueness
            String timestamp = String.valueOf(System.currentTimeMillis());
            
            // Combine username and timestamp with random bytes
            String tokenBase = username + "-" + timestamp;
            
            // Encode as Base64 for a clean string representation
            return Base64.getUrlEncoder().withoutPadding().encodeToString((tokenBase + Base64.getEncoder().encodeToString(tokenBytes)).getBytes());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error generating session token", e);
            throw new RuntimeException("Error generating session token", e);
        }
    }
}
