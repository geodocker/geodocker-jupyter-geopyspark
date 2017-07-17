include config-aws.mk     # Vars related to AWS credentials and services used
include config-emr.mk     # Vars related to type and size of EMR cluster

SCRIPT_RUNNER := s3://elasticmapreduce/libs/script-runner/script-runner.jar

ifeq ($(USE_SPOT),true)
MASTER_BID_PRICE:=BidPrice=${MASTER_PRICE},
WORKER_BID_PRICE:=BidPrice=${WORKER_PRICE},
BACKEND=accumulo
endif

ifndef CLUSTER_ID
CLUSTER_ID=$(shell if [ -e "cluster-id.txt" ]; then cat cluster-id.txt; fi)
endif


upload-code:
	@aws s3 cp bootstrap-geopyspark-docker.sh ${S3_URI}/bootstrap-geopyspark-docker.sh

create-cluster:
	aws emr create-cluster --name "${NAME}" \
--release-label emr-5.7.0 \
--output text \
--use-default-roles \
--log-uri ${S3_URI}/logs \
--ec2-attributes KeyName=${EC2_KEY},SubnetId=${SUBNET_ID} \
--applications Name=Hadoop Name=Spark Name=Zeppelin \
--instance-groups \
Name=Master,${MASTER_BID_PRICE}InstanceCount=1,InstanceGroupType=MASTER,InstanceType=${MASTER_INSTANCE} \
Name=Workers,${WORKER_BID_PRICE}InstanceCount=${WORKER_COUNT},InstanceGroupType=CORE,InstanceType=${WORKER_INSTANCE} \
--bootstrap-actions Name=GeoPySpark,Path=${S3_URI}/bootstrap-geopyspark-docker.sh \
| tee cluster-id.txt

wait: INTERVAL:=60
wait: STEP_ID=$(shell cat last-step-id.txt)
wait:
	@while (true); do \
	OUT=$$(aws emr describe-step --cluster-id ${CLUSTER_ID} --step-id ${STEP_ID}); \
	[[ $$OUT =~ (\"State\": \"([A-Z]+)\") ]]; \
	echo $${BASH_REMATCH[2]}; \
	case $${BASH_REMATCH[2]} in \
	                PENDING | RUNNING) sleep ${INTERVAL};; \
	                COMPLETED) exit 0;; \
	                *) exit 1;; \
	esac; \
	done

terminate-cluster:
	aws emr terminate-clusters --cluster-ids ${CLUSTER_ID}
	rm -f cluster-id.txt
	rm -f last-step-id.txt

clean:
	./sbt clean -no-colors
	rm -rf viewer/site.tgz
	rm -rf viewer/dist/*

proxy:
	aws emr socks --cluster-id ${CLUSTER_ID} --key-pair-file "${HOME}/${EC2_KEY}.pem"

ssh:
	aws emr ssh --cluster-id ${CLUSTER_ID} --key-pair-file "${HOME}/${EC2_KEY}.pem"

get-logs:
	@aws emr ssh --cluster-id $(CLUSTER_ID) --key-pair-file "${HOME}/${EC2_KEY}.pem" \
	        --command "rm -rf /tmp/spark-logs && hdfs dfs -copyToLocal /var/log/spark/apps /tmp/spark-logs"
	@mkdir -p  logs/$(CLUSTER_ID)
	@aws emr get --cluster-id $(CLUSTER_ID) --key-pair-file "${HOME}/${EC2_KEY}.pem" --src "/tmp/spark-logs/" --dest logs/$(CLUSTER_ID)


.PHONY: create-cluster get-logs
