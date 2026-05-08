package com.apache_pulsar.demo;

import org.apache.pulsar.client.api.SubscriptionType;
import org.springframework.pulsar.annotation.PulsarListener;
import org.springframework.stereotype.Service;

@Service
public class OrderConsumer {

    @PulsarListener(
            topics = "persistent://shop/orders/order-topic",
            subscriptionName =  "order-subscription",
            subscriptionType = SubscriptionType.Shared // it allows multiple consumers to consume from the same subscription, and messages will be distributed among them
    )
    public void consume(String name) {
        System.out.println("Order consumer received order-topic: " + name);
    }
}
