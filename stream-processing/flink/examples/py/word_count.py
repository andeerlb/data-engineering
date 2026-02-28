"""
Apache Flink - Word Count Example
===================================
Basic word count example using PyFlink DataStream API.
"""

from pyflink.datastream import StreamExecutionEnvironment
from pyflink.common.typeinfo import Types


def word_count():
    # Create execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    
    # Sample data
    text_data = [
        "Apache Flink is a framework and distributed processing engine",
        "Flink is designed to run in all common cluster environments",
        "Flink provides high throughput and low latency stream processing"
    ]
    
    # Create data stream
    data_stream = env.from_collection(text_data)
    
    # Process: split into words, convert to lowercase, and count
    word_counts = data_stream \
        .flat_map(lambda line: line.lower().split(), output_type=Types.STRING()) \
        .map(lambda word: (word, 1), output_type=Types.TUPLE([Types.STRING(), Types.INT()])) \
        .key_by(lambda x: x[0]) \
        .sum(1)
    
    # Print result
    word_counts.print()
    
    # Execute the job
    env.execute("Word Count Example")


if __name__ == '__main__':
    word_count()
