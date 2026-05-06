package com.apache_pulsar.demo;

import org.springframework.pulsar.annotation.PulsarListener;
import org.springframework.stereotype.Service;

@Service
public class OrderConsumer {

    @PulsarListener(
            topics = "persistent://shop/orders/order-topic",
            subscriptionName =  "order-subscription"
    )
    public void consume(String name) {
        System.out.println("Order consumer received order-topic: " + name);
    }
}
