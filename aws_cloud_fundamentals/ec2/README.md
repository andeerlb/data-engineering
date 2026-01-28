# EC2
An EC2 instance is a virtual machine (VM) that runs in the AWS Cloud. When you launch an instance, you decide the virtual hardware configuration by choosing an instance type. The instance type that you choose determines the hardware of the host computer used for your instance. Each instance type offers different compute, memory, and storage capabilities, and is grouped into an instance family based on these capabilities. 

- An instance is a VM.
- An instance type is the combination of virtual hardware components, such as CPU and memory, that make up the instance.
- Instance types are grouped together into instance families. Each instance family is optimized for specific types of use cases.
- Instance families have sub-families, which are grouped according to the combination of processor and storage used.
- A virtual central processing unit (vCPU) is a measure of processing ability. For most instance types, a vCPU represents one thread of the underlying physical CPU core. For example, if an instance type has two CPU cores and two threads per core, it will have four vCPUs.   

The AWS instances are currently categorized into five distinct families.

#### General purpose
General purpose instances provide a balance of compute, memory, and networking resources and can be used for a wide range of workloads. These instances are ideal for applications that use these resources in equal proportions, such as web servers and code repositories.

#### Compute optimized
Compute optimized instances are ideal for compute-bound applications that benefit from high-performance processors. Instances belonging to this family are well suited for compute-intensive operations, such as the following:

- Batch processing workloads
- Media transcoding
- High performance web servers
- High performance computing (HPC)
- Scientific modeling
- Dedicated gaming servers and ad server engines
- Machine learning (ML) inference 

#### Memory optimized
Memory optimized instances are designed to deliver fast performance for workloads that process large data sets in memory.

#### Storage optimized
Storage optimized instances are designed for workloads that require high, sequential read and write access to very large data sets on local storage. They are optimized to deliver tens of thousands of low-latency, random input/output (I/O) operations per second (IOPS) to applications.

#### Acelerated computing
Accelerated computing instances use hardware accelerators, or co-processors, to perform some functions more efficiently than is possible in software running on CPUs. Examples of such functions include floating point number calculations, graphics processing, and data pattern matching. Accelerated computing instances facilitate more parallelism for higher throughput on compute-intensive workloads.

### Instance sizing
EC2 instances are sized based on the combined hardware resources consumed by that instance type. This means the size is the total configured capacity of vCPU, memory, storage, and networking. The sizes range from nano to upwards of 32xlarge, with a nano-sized instance using the least amount of hardware resources and the 32xlarge instance using the most amount of hardware resources (128 vCPU and 1,024 GiB memory). Let's take a quick look at a size comparison chart to help you understand how the allocated hardware corresponds to the instance size. In the case of the general purpose T instance family, the vCPU allocation remains the same but the memory doubles with each, larger size.

| Instance Family   | Instance Size | vCPU | Memory (GiB) |
|-------------------|---------------|------|--------------|
| General purpose   | t4g.nano      | 2    | 0.5          |
| General purpose   | t4g.micro     | 2    | 1            |
| General purpose   | t4g.small     | 2    | 2            |
| General purpose   | t4g.medium    | 2    | 4            |
| General purpose   | t4g.large     | 2    | 8            |

### Instance family growth
Different instance families grow based on the resource for which the family is optimized. The following table shows the compute optimized growth and how it focuses on vCPU resources and the memory optimized growth and how it focuses on the memory resources.

| Instance Family     | Instance Size | vCPU | Memory (GiB) |
|---------------------|---------------|------|--------------|
| Compute optimized   | c5.xlarge     | 4    | 8            |
| Compute optimized   | c5.2xlarge    | 8    | 16           |
| Compute optimized   | c5.4xlarge    | 16   | 32           |
| Memory optimized    | r5g.xlarge    | 4    | 32           |
| Memory optimized    | r6g.2xlarge   | 6    | 64           |
| Memory optimized    | r6g.4xlarge   | 16   | 128          |


### AWS Compute Optimizer
AWS Compute Optimizer is a right-sizing recommendation tool that you can use to improve your AWS infrastructure efficiency. Compute Optimizer analyzes the configuration and utilization metrics of your current resources and then generates recommendations for more optimal configurations by considering both cost and performance. 

### Pricing Calculator
AWS Pricing Calculator is a web-based planning tool that you can use to create estimates for your AWS use cases. You can use it to model your solutions before building them, explore the AWS service price points, and review the calculations behind your estimates. You can use it to help you plan how you spend, find cost saving opportunities, and make informed decisions when using AWS.   
https://calculator.aws/#/

### Cost Explorer
You can use AWS Cost Explorer to view and analyze your costs and usage. You can view data for up to the last 12 months, forecast how much you're likely to spend for the next 12 months, and get recommendations for what Reserved Instances to purchase. You can use Cost Explorer to identify areas that need further investigation and view trends that you can use to understand your costs.

### Usage reports and limits
Cost Explorer provides you with a cost and usage reports. You can't modify these reports, but you can use them to create your own custom reports. 

- Daily costs – This shows how much you've spent in the last 6 months, along with how much you're forecasted to spend over the next month.
- Monthly costs by linked account – This shows your costs for the last 6 months, grouped by linked, or member account. The top five member accounts are shown by themselves, and the rest are grouped into one bar.
- Monthly costs by service – This shows your costs for the last 6 months, grouped by service. The top five services are shown by themselves, and the rest are grouped into one bar.
- Monthly EC2 running hours costs and usage –  This shows how much you have spent on active Reserved Instances.   

For additional information see https://docs.aws.amazon.com/cost-management/latest/userguide/ce-default-reports.html#ce-cost-usage-reports