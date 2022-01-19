## AWS Data Records Collection
![alt text](../master/architecture_diagram.png?raw=true)

### Deployment Steps:

0. Before you deploy this project, please check and adjust config variables in
 	```sh
 	./bootstrapping/config.sh
 	```
1. Execute basic script to create S3 bucket, VPC, Subnet, IGW, ECR repository and other necessary AWS resources.
	```sh
    ./bootstrapping/deploy_basic_template.sh create
    ```
2. Execute image pipeline script to build a Fluent Bit/Nginx pre-installed/configed AMI.
   ```sh
   ./image_pipeline/deploy_image_pipeline.sh create
   ```
3. Execute data ingest script to create Application Load Balancer, Kinesis Data Stream, Kinesis Firehose and other AWS resources.
   ```sh
   ./data_ingest/deploy_data_ingest.sh create
   ```
4. Execute docker image script to build Lambda container image and push the image to ECR repository.
   ```sh
   ./data_consumer/lambda/deploy_image.sh
   ```
5. Execute data consumer script to create Lambda function based on pre-builded image in step 4.
   ```sh
   ./data_consumer/deploy_data_consumer.sh create
   ```
