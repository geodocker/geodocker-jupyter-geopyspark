# Running Jupyter, GeoNotebook and GeoPySpark on EMR

This section of the repository contains a boostrap script and a Makefile
that lets you easily spin up an EMR cluster that is running the docker container
of this repository.

_Requires_: Reasonably up to date [`aws-cli`](https://aws.amazon.com/cli/) this document is written with version `1.10`.

### Configuration

Configuraiton has been broken out into two sections which are imported by the `Makefile`.

 - __config-aws.mk__: AWS credentials, S3 staging bucket, subnet, etc
 - __config-emr.mk__: EMR cluster type and size

You will need to create your `config-aws.mk` based off of `config-aws.mk.template` to reflect your credentials and your VPC configuration.

`config-emr.mk` contains the following params:

 - __NAME__: The name of the EMR cluster
 - __MASTER_INSTANCE__: The type of instance to use for the master node.
 - __MASTER_PRICE__: The maximum bid price for the master node, if using spot instances.
 - __WORKER_INSTANCE__: The type of instance to use for the worker nodes.
 - __WORKER_PRICE__: The maximum bid price for the worker nodes, if using spot instances.
 - __WORKER_COUNT__: The number of workers to include in this cluster.
 - __USE_SPOT__: Set to `true` to use spot instances.

### The bootstrap script

EMR allows you to specify a script to run on the creation of both the master and worker nodes.
We supply a script here, `bootstrap-geopyspark-docker.sh`, that will set up and run
this docker container with the proper configuration in the bootstrap step.

The script needs to be on S3 in order to be available to the EMR starutp process;
to place on S3, use the Makefile command

```bash
$ make upload-code
```

### Starting the cluster

Now all we have to do to interact with the cluster is use the following Makefile commands:

```bash
# Create the cluster
$ make create-cluster

# Terminate the cluster
$ make terminate-cluster

# SSH into the master node
$ make ssh

# Create an SSH tunnel to the master for viewing EMR Application UIs
$ make proxy

# Grab the logs from the master
$ make get-logs
```

The create-cluster command will place a text file, `cluster-id.txt` in this directy which holds the Cluster ID.
All the other commands use that ID to interact with the cluster. `teriminate-cluster` will remove this text file.

### Accessing JupyterHub

Grab the public DNS name for the master node of the cluster, and visit `http://[MASTER DNS]:8000`. You
should see the JupyterHub login page. The user and password are both `hadoop`.

_Note_: Don't forget to open up port `8000` in the security group of the master node, or else you won't
be able to access the JupyterHub endpoint.
