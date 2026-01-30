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

### AMIs
An Amazon Machine Image (AMI) is a template that contains the software configuration—for example, an operating system (OS), applications, or tools. You use the AMI and the information contained within it to launch an instance. You must specify an AMI when you launch an instance because it contains all the necessary information and files required to build and launch the instance. If you don't specify an AMI, you cannot launch an instance.   
   
Because the AMI is a configuration template, you can use a single AMI to launch multiple instances. Or you can choose to launch a variety of different instances using different AMIs that contain unique configuration options.  
   
Amazon EC2 supports AMIs that use the Linux, Windows, or macOS operating systems. An AMI includes the following pieces

- Storage
- Permissions
- Mapping

### AWS Nitro System
The majority of EC2 instances run on hardware known as the AWS Nitro System. The AWS Nitro System is built specifically to run instances in the most optimal fashion possible. The AWS Nitro System is a combination of dedicated hardware and a lightweight hypervisor, for faster innovation and enhanced security.
To learn more about it,  yo ucan read all about it on the https://aws.amazon.com/ec2/nitro/#:~:text=AWS%20has%20completely%20re%2Dimagined,rich%20set%20of%20management%20capabilities.

### Network interface
The final piece of an instance is the networking components. Each instance comes with an elastic network interface. This is a logical networking component that represents a virtual network card. You can think of it like the network interface (NIC) in your laptop, desktop, or server. The elastic network interface is the element in your instance that allows it to communicate with other instances, servers, features, and anything on the internet.

### Tenancy
A tenant is the most fundamental concept in the cloud. A tenant is an entity that occupies space, whether that space is a rented apartment in a building you own, or if that rented space is an instance occupying resources on AWS infrastructure. With Amazon EC2, tenancy defines how the EC2 instances are distributed across the physical hardware. Tenancy choices also have an effect on pricing. 

- shared.  
    - Shared tenancy is the default tenancy for Amazon EC2 instances. Shared tenancy means that when you launch your instance, the instance is created on an AWS server that you share with many other different AWS customer accounts. Your instance is isolated and secured from the other user's instances but you are all sharing the same underlying hardware. 
- dedicated instance.  
    - Is a physical server where all the instance capacity is fully dedicated to your use. With Dedicated Hosts you can use your existing per-socket, per-core, or per-virtual machine (VM) software licenses, including Windows Server, Microsoft SQL Server, SUSE, and Linux Enterprise Server.
- dedicated host.  
    - Are Amazon EC2 instances that run on hardware that's dedicated to a single customer. Dedicated Instances can share hardware with other instances from the same AWS account that are not Dedicated Instances

### Launching through the console

#### Launch wizard
The launch instance wizard provides default values for all of the parameters. You can accept any or all of the defaults, or configure an instance by specifying your own values for each parameter. The parameters are grouped in the launch instance wizard. The wizard walks you through deploying an EC2 instance.

#### Launch template
A launch template contains the configuration information to launch an instance and allows you to use the same template to launch multiple instances with the same settings.

#### Existing instance
The Amazon EC2 console provides a launch wizard option that allows you to use a current instance as a base for launching other instances. This option automatically populates the Amazon EC2 launch wizard with certain configuration details from the selected instance.

#### Aws marketplace
The AWS Marketplace is a curated digital catalog that you can use to find, buy, deploy, and manage third-party software, data, and services. AMIs are available for purchase that come with preinstalled software configurations for a wide range of technologies.
