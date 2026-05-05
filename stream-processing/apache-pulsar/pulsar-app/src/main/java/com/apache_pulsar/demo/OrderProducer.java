package com.apache_pulsar.demo;

import org.springframework.pulsar.core.PulsarTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrderProducer {
    private final PulsarTemplate<String> pulsarTemplate;

    public  OrderProducer(PulsarTemplate<String> pulsarTemplate) {
        this.pulsarTemplate = pulsarTemplate;
    }

    public void sendOrder(String orderJson) {
        pulsarTemplate.send(
                "persistent://shop/orders/order-topic",
                orderJson
        );
    }
}
