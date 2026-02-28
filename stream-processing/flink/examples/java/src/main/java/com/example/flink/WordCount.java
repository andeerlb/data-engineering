package com.example.flink;

import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * WordCount Example
 * 
 * Basic Flink job that counts words in a stream.
 * Demonstrates:
 * - Environment setup
 * - Data source creation
 * - FlatMap transformation
 * - KeyBy and reduce operations
 */
public class WordCount {

    public static void main(String[] args) throws Exception {
        // 1. Create execution environment
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        
        // Set parallelism (optional, for debugging use 1)
        env.setParallelism(1);

        // 2. Create data source
        DataStream<String> text = env.fromElements(
            "Apache Flink is a framework and distributed processing engine",
            "Flink is designed to run in all common cluster environments",
            "Flink provides high throughput and low latency stream processing",
            "Apache Flink Apache Flink"
        );

        // 3. Apply transformations
        DataStream<Tuple2<String, Integer>> wordCounts = text
            // Split lines into words
            .flatMap(new Tokenizer())
            // Group by word
            .keyBy(value -> value.f0)
            // Sum the counts
            .sum(1);

        // 4. Print results
        wordCounts.print();

        // 5. Execute the job
        env.execute("Word Count Example");
    }

    /**
     * FlatMap function that splits a line into words
     */
    public static final class Tokenizer implements FlatMapFunction<String, Tuple2<String, Integer>> {
        @Override
        public void flatMap(String value, Collector<Tuple2<String, Integer>> out) {
            // Split the line into words
            String[] words = value.toLowerCase().split("\\W+");
            
            // Emit each word with count 1
            for (String word : words) {
                if (word.length() > 0) {
                    out.collect(new Tuple2<>(word, 1));
                }
            }
        }
    }
}
