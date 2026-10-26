package com.hostelease.util;

public class HashGenerator {
    public static void main(String[] args) {
        System.out.println("ADMIN_HASH=" + PasswordUtil.hashPassword("Admin@123"));
        System.out.println("WARDEN_HASH=" + PasswordUtil.hashPassword("Warden@123"));
        System.out.println("STUDENT_HASH=" + PasswordUtil.hashPassword("Student@123"));
    }
}
