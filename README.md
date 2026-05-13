# order fulfillment platform

## Overview 

Built a production-grade, event-driven order fulfillment platform on AWS using a **microservices architecture** with **9** independently deployed services running on ECS Fargate. Designed and implemented the complete infrastructure stack with Terraform, CI/CD pipelines using GitHub Actions + **OIDC**. Architected cross-service communication with **SQS-based orchestration**, service discovery, **centralized observability**, and least-privilege IAM.

## Features
- SQS for message based workload
- Prometheus, Grafana, YACE for a complete centralised observability stack 
- Pipeline ownership of deployments to prevent config drifts 
- OIDC using web tokens rather than providing access keys mitigating security risks implementing security best practices 

## Architecture Diagram

<img width="704" height="741" alt="ecsv3 diagram" src="https://github.com/user-attachments/assets/06dcfbb3-1e82-48fc-bd20-cb0610725c90" />


## System Design 

- **ECS Fargate**: Reduced operational overhead by removing the need to manage EC2 instances. This allowed the platform to focus on application deployment whilst AWS handled compute provisioning and scaling

- **EC2 Observability Stack**: Added a centralized observability stack on EC2 pushing out logs and metrics from ECS cluster to pinpoint issues in cases of downtime for rapid recovery

- **VPC Endpoints**: Chosen over NAT Gateways to keep AWS service communication within the private network whilst also reducing costs, introducing a more secure and cost efficient approach 

- **SQS vs Kafka**: SQS was chosen due to its lower operational overhead and simpler integration with AWS services. Since the order fulfillment platform is focused on coordinating workflows between microservices rather than processing analytics or streaming data, SQS was better for handling communication between the microservices such as order processing, inventory stock, and handling payments. It also included DLQ for failed events allowing errors to be handled much quicker.

- **ECS vs EKS**: This was a major architectural decision throughout the project. While EKS provides greater flexibility, it also introduces significantly higher operational complexity, infrastructure management overhead, and cost. Since the platform consisted of containerized microservices with predictable workloads and did not require advanced Kubernetes features, ECS Fargate was the more appropriate choice. It allowed the platform to remain production-grade and scalable, without the additional complexity of managing Kubernetes

- **ElastiCache for rate limiting**: Since the platform will process large financial workflows and customer data, rate limiting was implemented at the API gateway layer to protect services from excessive traffic spikes, and request flooding. This helps maintain platform stability, prevents resource exhaustion across microservices, and improves overall system reliability under load

## Issues / Solutions
**Issue:** SQS queue was provisioned with connections successfully initiated yet no messages were being sent/polled \
**Solution:** The source code was missing functions to handle SQS messages so I created functions which allowed successful processing/polling of messages  

**Issue:** Prometheus could not resolve DNS for my individual services because the Cloud Map namespace i used included `.local`, which is reserved by Linux for multicast DNS (mDNS), causing service discovery requests such as `inventory-service.ecs.local` to be intercepted locally instead of resolving through AWS Route53 private DNS since the EC2 instance used the ubuntu AMI \
**Solution:** Changed the Cloud Map namespace to include `.internal` rather than `.local`

**Issue:** API gateway service health constantly failing at the browser level but was successful at load balancer level   
**Solution:** Exposed `/healthz` path pattern through API gateways listener rule since it monitored its own health rather than relying on ALB

**Issue:** ECS tasks could not communicate with each other even though they were inside the same VPC and subnets. The security group did not allow inbound traffic from other services using the same security group, so AWS blocked the traffic \
**Solution:** Added a self referenced inbound rule to the ECS services security group, allowing traffic from the same security group on the required ports which enabled internal communication between ECS tasks


## Lessons learnt 
SQS does not automatically connect services together solely through infrastructure configuration. Application level integration is required so services can publish, consume, and process messages in a consistent format 

Implement best practices once you have the core workflow functioning. Trying to implement tight security and least privilege IAM permisions too early on makes debugging significantly harder especially if you dont even fully understand the underlying workflow 

Rate limiting controls how many requests a client can send over a period of time to prevent attacks, reduce server overload, and improve overall system stability

Spending excessive time debugging a single issue can quickly become mentally exhausting. In many cases, stepping away from the problem and revisiting it later with a clearer mind leads to a faster solution than continuing while fatigued

## The Journey
Just a year ago i was a typical 15 year old with no ambitions in life or a slight interest in tech, fast forward to now, i have built something i am genuinely proud of... an entire microservice event driven system  

It took SOO long to complete this, countless nights of debugging and mixing college exam revision 😅

I honestly felt like giving up on this thinking that i would never understand it but Alhamdulilah I managed to pull it off 

Looking back, provisioning the infrastructure was actually the easier part, the real challenge was understanding how the entire system works end to end and making design decisions that affected multiple services which took far longer than writing Terraform 

This project represents a huge learning journey for me, and I hope it reflects the serious effort that went into it, onto the next 🚀
