# terraform-and-packer

The example provisions resources in AWS Cloud. I am not responsible for any charges that you may incur.

## Prerequisites

1. An AWS Account
2. The AWS CLI installed and configured
3. The Terrafrom CLI (0.14.9+) installed
4. The Packer CLI (1.7.3+) installed

## Deployment

1. In `packer` directory create an AMI image using the command:

```
$ packer build ami.pkr.hcl
```

2. Execute Terrafrom commands:

```
$ terrafrom init
$ terrafrom apply
```

In directories, in the following order:

- `./terraform/prod/secrets`
- `./terraform/prod/iam`
- `./terraform/prod/vpc`
- `./terraform/prod/database`
- `./terraform/prod/webserver-cluster`

## Zero-downtime Deployment

1. Make a change in the application
2. Build a new AMI
3. Run `terraform apply` in `./terraform/prod/webserver-cluster`

A new Auto Scaling Group will be created before destroying the old one.

## Clean up

1. Execute the command:

```
$ terraform destroy
```

In directories, in the following order:

- `./terraform/prod/webserver-cluster`
- `./terraform/prod/database`
- `./terraform/prod/vpc`
- `./terraform/prod/iam`
- `./terraform/prod/secrets`

2. Deregister created AMI
3. Delete EBS Snapshots
