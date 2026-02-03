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

### Lifecycle of an instance
An EC2 instance transitions through a variety of states from the moment you launch it through to its termination.

- Hibernate
    - When you hibernate an instance, Amazon EC2 signals the operating system to perform hibernation (suspend-to-disk). Hibernation saves the contents from the instance memory (RAM) to your Amazon EBS root volume. Amazon EC2 persists the instance EBS root volume and any attached EBS data volumes. When you start your instance, the following events occur:
        - The EBS root volume is restored to its previous state.
        - The RAM contents are reloaded.
        - The processes that were previously running on the instance are resumed.
        - Previously attached data volumes are reattached and the instance retains its instance ID.
- Reboot (scheduled event)
    - AWS can schedule events, such as a reboot, for your instances. An instance reboot is equivalent to an operating system reboot. In most cases, it takes only a few minutes to reboot your instance. When you reboot an instance, it keeps its public DNS name (IPv4), private and public IPv4 address, IPv6 address (if applicable), and any data on its instance store volumes.
- Retire
    - An instance is scheduled to be retired when AWS detects irreparable failure of the underlying hardware that hosts the instance. When an instance reaches its scheduled retirement date, it is stopped or terminated by AWS.
        - If your instance root device is an EBS volume, the instance is stopped, and you can start it again at any time. Starting the stopped instance migrates it to new hardware.
        - If your instance root device is an instance store volume, the instance is terminated and cannot be used again.

### Connecting to the instances
There are a variety of instance connection options from within the AWS Management Console and from a client-side machine.   
For client-side connections, the tool you use to connect to the instance depends both on what the instance OS is and which operating system you are running on your local client machine. AWS provides guidance and documentation for deploying, connecting, and operating both Linux-based and Windows-based instances.

#### Using ssh
Secure Shell (SSH) is a network protocol that faciliatates a secure, encrypted connection between two systems—an SSH client and an SSH server. When connected to the server, the client can remotely perform all operations as if they were standing in front of the server.   
SSH authentication to an EC2 instance is done through the use of the key pair you associated with the instance when you launched it. The key pairs, a public and a private key, are a form of asymmetric cryptography used to authenticate the client and server to each other. This key pair makes it possible to secure, connect, and manage the instance, which is why it is very important to not lose your key pair.   

SSH tools
    - Linux and MacOS
        - SSH is a native tool built into Unix-based systems
    - Windows
        - For newer versions of the Windows OS, a version of OpenSSH comes preinstalled. Additionally, there are a variety of SSH tools that can be downloaded and installed; for example, PuTTY, WinSCP, and xShell

### Controlling access to your instance
The security group controls the traffic into the instance itself. When you launch an instance, you assign it one or more security groups. You can add multiple rules within each security group to control traffic allowed into or out of the instance. By default, all traffic is allowed out of the instance and you must create inbound rules if you want any traffic allowed inbound. 

### Accessing an instance using Session Manager
With AWS Systems Manager Session Manager, you can manage your Amazon EC2 instances through a browser-based shell or through the AWS CLI. You can use Session Manager to directly start a session with an instance while you're working in the EC2 Dashboard or AWS account. After the session is started, you can run bash commands as you would through any other connection type. Session Manager removes the need to open inbound ports, manage SSH keys, or use bastion hosts. You can use Session Manager with AWS PrivateLink to prevent traffic from going through the public internet. 

### Block device mapping
Your instance might include local storage volumes, known as instance store volumes, which you can configure at launch time with block device mapping. After these volumes have been added to and mapped on your instance, they are available for you to mount and use. If your instance fails, or if your instance is stopped or terminated, the data on these volumes is lost; therefore, these volumes are best used for temporary data. To keep important data safe, you should use a replication strategy across multiple instances or store your persistent data in Amazon S3 or Amazon EBS volumes.   

### Instance store
You can specify instance store volumes for an instance only when you launch it. You can't detach an instance store volume from one instance and attach it to a different instance.

The data in an instance store persists only during the lifetime of its associated instance. If an instance reboots (intentionally or unintentionally), data in the instance store persists. However, data in the instance store is lost under any of the following circumstances:   

- The underlying disk drive fails
- The instance stops
- The instance hibernates
- The instance terminates

### Amazon EBS volumes
Amazon EBS provides block level storage volumes for use with EC2 instances. After you attach a volume to an instance, you can use it as you would use a physical hard drive. EBS volumes are flexible. For current-generation volumes attached to current-generation instance types, you can dynamically increase size, modify the provisioned IOPS capacity, and change volume type on live production volumes.

### Boot times differences
Instances launched from an Amazon EBS-backed AMI launch faster than instances launched from an instance store-backed AMI. When you launch an instance from an instance store-backed AMI, all the parts have to be retrieved from Amazon S3 before the instance is available. With an Amazon EBS-backed AMI, only the parts required to boot the instance need to be retrieved from the snapshot before the instance is available. However, the performance of an instance that uses an EBS volume for its root device is slower for a short time while the remaining parts are retrieved from the snapshot and loaded into the volume. When you stop and restart the instance, it launches quickly, because the state is stored in an EBS volume. 

### File storage options
Cloud file storage is a method for storing data in the cloud that provides servers and applications access to data through shared file systems. This compatibility makes cloud file storage ideal for workloads that rely on shared file systems and provides simple integration without code changes.   
There are many file storage solutions that exist, ranging from a single node file server on a compute instance using block storage as the underpinnings with no scalability or few redundancies to protect the data, to a do-it-yourself clustered solution, to a fully managed solution.

### Network options
An elastic network interface is a logical networking component that represents a virtual network card. As with all network cards, the elastic network interface provides the ability for the host instance to communicate on the network to other hosts, resources, and the external internet. When you create a security group, the security group is associated with the elastic network interface. Traffic that attempts to connect to the elastic network interface must have a security group rule that allows inbound access to the instance.   
There are two classifications of elastic network interfaces: Primary and secondary.

- Primary elastic network interface is created by default when the instance is created. You cannot detach or move a primary elastic network interface from the instance on which it was created. 

- Secondary elastic network interface is an additional interface that you create and attach to the instance. The maximum number of elastic network interfaces that you can use varies by instance type.

You can attach an additional interface to an instance, detach it from the instance and then attach it to another instance. The attributes of an elastic network interface follow it from one instance to another. When you move an elastic network interface from one instance to another instance, the network traffic is automatically redirected to the new instance.

### Use cases for elastic network interfaces
- Failover: You can manually detach the elastic network interface from a failed or down instance and then attach the interface to a new instance. When you do this, the interface keeps its original IP address and traffic automatically routes to the new instance.

- Management: When using multiple elastic network interfaces configured on one instance, you can dedicate one interface for administrative traffic and the other for the workload or business traffic. When isolating the management traffic, the second interface can focus on only managing the workload. Security groups use each interface to isolate the traffic based on port, protocol, or IP address.

### Public IP address
When your instance starts, it is auto-assigned a public IP address for users on the internet to connect. When the instance is stopped, the auto-assigned IP address is released back to the public IP address pool. When the instance is restarted, a new unique IP address is reassigned.   
Public IP address assignment in the default VPC and in a nondefault VPC work differently. When you launch an instance in a default VPC, a public IP address is assigned automatically. When you launch an instance into a nondefault VPC, it checks an attribute in the subnet that determines whether instances launched into that subnet can receive a public IP address from the public IPv4 address pool. By default, instances launched in a nondefault subnet are not assigned a public IP address.

### Public IP address pool assignments
All of the public IP addresses are assigned from a pool of public IPv4 addresses at Amazon. This public address is not associated with your AWS account. When a public IP address is disassociated from your instance, it is released back into the public IPv4 address pool, and you cannot reuse it. You cannot manually associate or disassociate a public IP (IPv4) address from your instance. Instead, in certain cases, the public IP address from your instance is released or a new IP address is assigned.

### Elastic IP addresss
An Elastic IP address is a static public IPv4 address associated with your AWS account in a specific Region. Unlike an auto-assigned public IP address, an Elastic IP address is preserved after you stop and start your instance in a VPC.   
You can choose to associate an Elastic IP address with your EC2 instance at any time using one of the following tools:

- Amazon EC2 console
- AWS Command Line Interface (AWS CLI)
- AWS Tools for Windows PowerShell

Keep the following points in mind when working with static IP addresses:

- You can't retain or reserve the current public IP address assigned to the instance using auto-assigned public IP address.
- You cannot convert an auto-assigned public IP address to an Elastic IP address.
- There is a default limit of five Elastic IP addresses per Region per AWS account. 
- You are charged a small fee for any Elastic IP address that is not associated to a running instance. 
- An Elastic IP address remains associated with your AWS account until you release it, and you can move it from one instance to another as needed. 
- You can bring your own IP address range to your AWS account, where it appears as an address pool, and then allocate Elastic IP addresses from your address pool.

### IPv6 addresss
You can optionally associate an IPv6 CIDR block with your VPC and associate IPv6 CIDR blocks with your subnets. The IPv6 CIDR block for your VPC is automatically assigned from the pool of IPv6 addresses at Amazon; you cannot choose the range yourself.   
At this time, you cannot remove the default IPv4 address and user only native IPv6.

### AWS Well-Architected
