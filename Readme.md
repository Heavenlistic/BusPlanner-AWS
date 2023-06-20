1. To deploy 9 resources (VPC, Internet gateway, Route Table, Private subnet, Public subnet, Elastic IP -eip, NAT gateway, Route table association)in AWS using terraform

2. In main.tf - the resource names and the location were updated

3. S3 bucket was created first for the backend before running terraform commands

# Commands in the terminal for main folder path
1. touch Readme.md .gitignore > 
2. aws configure > Press Enter 4x > clear > aws sts get-caller-identity  > Clear
3. aws s3api create-bucket --bucket your-bucket-name --region your-region
4. terraform init > terraform plan > terraform apply > terraform destroy
5. git init > git add .gitignore > git status > git commit -m "Initial push" > git add . > git commit -m "Initial push" (first delete all previous .git folders to avoid error)
6. git remote add origin (git link) 
    git branch -M main 
    git push -u origin main. 
7. git add . > git commit -m "Second push" > git push (for additional changes with updated comments)