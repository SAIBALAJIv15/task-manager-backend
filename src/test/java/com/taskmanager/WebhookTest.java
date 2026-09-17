package com.taskmanager;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class WebhookTest {

    @Test
    void passingTest() {
        assertEquals(2, 1 + 1, "Math works!");
    }

    @Test
    void failingTest() {
        assertEquals(2, 1 + 1, "Math works!");
    }
}
