#!/bin/bash
echo test of user_data `pwd`| sudo tee /tmp/user_data.log

sudo apt update
sudo apt install -y python3-pip
sudo apt install -y git
sudo pip install esrally
sudo apt-get install -y pbzip2

sudo useradd -m -d /home/rally -s /bin/bash rally
sudo echo "rally:rally" | chpasswd
#sudo mkfs -t ext4 /dev/xvdf                # Create a file system on the EBS volume
sudo mkfs -t ext4 /dev/nvme1n1 #for m5 NITRO instance 
sleep 5
sudo mount /dev/nvme1n1 /home/rally  # Mount the EBS volume to the directory
echo '/dev/nvme1n1 /home/rally  ext4 defaults,nofail 0 0' | sudo tee -a /etc/fstab  # Add an entry to /etc/fstab for auto-mount

cat <<EOF > /home/rally/run-rally-httplogs.sh
esrally race --track=http_logs --challenge=append-no-conflicts \
--track-params=number_of_replicas:1,cluster_health:yellow \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
EOF

cat <<EOF > /home/rally/run-rally-eslogs-ingest.sh
esrally race --track=elastic/logs --challenge=logging-indexing \
--track-params=ingest_percentage:1,max_total_download_gb:1,number_of_replicas:1,bulk_indexing_clients:3,cluster_health:yellow \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
EOF

cat <<EOF > /home/rally/run-rally-eslogs-query.sh
esrally race --track=elastic/logs --challenge=logging-querying \
--track-params=ingest_percentage:1,max_total_download_gb:1,number_of_replicas:1,bulk_indexing_clients:3,cluster_health:yellow \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
EOF

cat <<EOF > /home/rally/run-rally-geonames.sh
esrally race --track=geonames \
--track-params="ingest_percentage:1,number_of_replicas:1,number_of_shards:2,cluster_health:yellow" \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
--logging=DEBUG
EOF

cat <<EOF > /home/rally/run-rally-sql.sh
esrally race --track=sql \
--track-params=ingest_percentage:1,query_percentage:10,post_ingest_sleep_duration:10,number_of_replicas:1,cluster_health:yellow \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
EOF

cat <<EOF > /home/rally/run-rally-k8_metrics.sh
esrally race --track=k8s_metrics --challenge=append-no-conflicts-metrics-index-only \
--track-params=ingest_percentage:1,number_of_replicas:1,bulk_indexing_clients:3,cluster_health:yellow \
--target-hosts=${ES_HOST} --pipeline=benchmark-only \
--client-options="use_ssl:true,verify_certs:true,api_key:'${ES_API_KEY}'" \
--kill-running-processes
EOF

sudo chown -R rally:rally /home/rally
sudo chmod +x /home/rally/*.sh