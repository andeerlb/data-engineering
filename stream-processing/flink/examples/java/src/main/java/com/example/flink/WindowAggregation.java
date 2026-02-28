package com.example.flink;

import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;

import java.util.Random;

/**
 * Window Aggregation Example
 * 
 * Demonstrates windowing operations in Flink:
 * - Tumbling windows
 * - Aggregations over windows
 * - Processing time windows
 */
public class WindowAggregation {

    public static void main(String[] args) throws Exception {
        // 1. Create execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 2. Create a stream of sensor readings
        // In production, this would come from a real source (Kafka, socket, etc.)
        DataStream<SensorReading> sensorStream = env
            .addSource(new SensorSource())
            .name("Sensor Source");

        // 3. Key by sensor ID and apply tumbling window
        DataStream<Tuple2<String, Double>> averages = sensorStream
            // Group by sensor ID
            .keyBy(reading -> reading.sensorId)
            // 10-second tumbling windows
            .window(TumblingProcessingTimeWindows.of(Time.seconds(10)))
            // Calculate average temperature per window
            .aggregate(new TemperatureAggregator())
            // Convert to tuple for easy printing
            .map(new MapFunction<Double, Tuple2<String, Double>>() {
                @Override
                public Tuple2<String, Double> map(Double value) throws Exception {
                    return new Tuple2<>("Average", value);
                }
            });

        // 4. Print results
        sensorStream.print("Raw Readings");
        averages.print("Window Averages");

        // 5. Execute the job
        env.execute("Window Aggregation Example");
    }

    /**
     * Simple data class for sensor readings
     */
    public static class SensorReading {
        public String sensorId;
        public long timestamp;
        public double temperature;

        public SensorReading() {}

        public SensorReading(String sensorId, long timestamp, double temperature) {
            this.sensorId = sensorId;
            this.timestamp = timestamp;
            this.temperature = temperature;
        }

        @Override
        public String toString() {
            return String.format("Sensor[id=%s, temp=%.2f°C]", sensorId, temperature);
        }
    }

    /**
     * Source function that generates random sensor readings
     */
    public static class SensorSource implements org.apache.flink.streaming.api.functions.source.SourceFunction<SensorReading> {
        private volatile boolean running = true;
        private final Random random = new Random();

        @Override
        public void run(SourceContext<SensorReading> ctx) throws Exception {
            String[] sensorIds = {"sensor-1", "sensor-2", "sensor-3"};
            
            while (running) {
                for (String sensorId : sensorIds) {
                    // Generate random temperature between 15 and 30 degrees
                    double temperature = 15 + (random.nextDouble() * 15);
                    
                    ctx.collect(new SensorReading(
                        sensorId,
                        System.currentTimeMillis(),
                        temperature
                    ));
                }
                
                // Sleep for 1 second
                Thread.sleep(1000);
            }
        }

        @Override
        public void cancel() {
            running = false;
        }
    }

    /**
     * Aggregate function to calculate average temperature
     */
    public static class TemperatureAggregator 
        implements org.apache.flink.api.common.functions.AggregateFunction<SensorReading, Tuple2<Double, Integer>, Double> {

        @Override
        public Tuple2<Double, Integer> createAccumulator() {
            return new Tuple2<>(0.0, 0);
        }

        @Override
        public Tuple2<Double, Integer> add(SensorReading value, Tuple2<Double, Integer> accumulator) {
            return new Tuple2<>(
                accumulator.f0 + value.temperature,
                accumulator.f1 + 1
            );
        }

        @Override
        public Double getResult(Tuple2<Double, Integer> accumulator) {
            return accumulator.f0 / accumulator.f1;
        }

        @Override
        public Tuple2<Double, Integer> merge(Tuple2<Double, Integer> a, Tuple2<Double, Integer> b) {
            return new Tuple2<>(a.f0 + b.f0, a.f1 + b.f1);
        }
    }
}
