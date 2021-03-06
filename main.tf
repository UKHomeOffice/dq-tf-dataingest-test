locals {
  naming_suffix = "dataingest-${var.naming_suffix}"
}

resource "aws_subnet" "data_ingest" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_ingest_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_ingest_rt_association" {
  subnet_id      = "${aws_subnet.data_ingest.id}"
  route_table_id = "${var.route_table_id}"
}

#resource "aws_instance" "di_web" {
#  key_name                    = "${var.key_name}"
#  ami                         = "${data.aws_ami.di_web.id}"
#  instance_type               = "t2.xlarge"
#  iam_instance_profile        = "${aws_iam_instance_profile.data_ingest_landing_bucket.id}"
#  vpc_security_group_ids      = ["${aws_security_group.di_web.id}"]
#  associate_public_ip_address = false
#  subnet_id                   = "${aws_subnet.data_ingest.id}"
#  private_ip                  = "${var.dp_web_private_ip}"

#  user_data = <<EOF
#  <powershell>
#  $original_file = 'C:\scripts\data_transfer.bat'
#  $destination_file = 'C:\scripts\data_transfer_config.bat'
#
#  (Get-Content $original_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${aws_s3_bucket.data_landing_bucket.id}" `
#         -replace 's3-path', 's4' `
#         -replace 'destination-path', 'E:\dq\nrt\s4_file_ingest\FTP_landingzone\done'
#      } | Set-Content $destination_file

#  $original_parsed_archive_file = 'C:\scripts\data_transfer_archive.bat'
#  $destination_parsed_archive_file = 'C:\scripts\data_transfer_parsed_archive_config.bat'

#  (Get-Content $original_parsed_archive_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
#         -replace 's3-path', 's4/parsed' `
#         -replace 'data-log-file', 'data-transfer-parsed.log' `
#         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\archive\parsed'
#      } | Set-Content $destination_parsed_archive_file

#  $original_raw_archive_file = 'C:\scripts\data_transfer_raw_archive.bat'
#  $destination_raw_archive_file = 'C:\scripts\data_transfer_raw_archive_config.bat'

#  (Get-Content $original_raw_archive_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
#         -replace 's3-path', 's4/raw' `
#         -replace 'data-log-file', 'data-transfer-raw.log' `
#         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\raw_inprocess\done'
#      } | Set-Content $destination_raw_archive_file
#
#  $original_failed_archive_file = 'C:\scripts\data_transfer_archive.bat'
#  $destination_failed_archive_file = 'C:\scripts\data_transfer_failed_archive_config.bat'

#  (Get-Content $original_failed_archive_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
#         -replace 's3-path', 's4/failed' `
#         -replace 'data-log-file', 'data-transfer-failed.log' `
#         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\archive\failed'
#      } | Set-Content $destination_failed_archive_file

#  $original_stored_archive_file = 'C:\scripts\data_transfer_archive.bat'
#  $destination_stored_archive_file = 'C:\scripts\data_transfer_stored_archive_config.bat'

#  (Get-Content $original_stored_archive_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
#         -replace 's3-path', 's4/stored' `
#         -replace 'data-log-file', 'data-transfer-stored.log' `
#         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\archive\stored'
#      } | Set-Content $destination_stored_archive_file

#  $original_ga_file = 'C:\scripts\data_transfer_ga.bat'
#  $destination_ga_file = 'C:\scripts\data_transfer_ga_config.bat'

#  (Get-Content $original_ga_file) | Foreach-Object {
#      $_ -replace 's3-bucket', "${data.aws_ssm_parameter.ga_bucket.value}" `
#         -replace 's3-access-id', "${data.aws_ssm_parameter.ga_bucket_id.value}" `
#         -replace 's3-access-key', "${data.aws_ssm_parameter.ga_bucket_key.value}" `
#         -replace 's3-path', 's4' `
#         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\ga'
#      } | Set-Content $destination_ga_file
#  </powershell>
#EOF

#  lifecycle {
#    prevent_destroy = true

#    ignore_changes = [
#      "user_data",
#      "ami",
#      "instance_type",
#    ]
#  }
#
#  tags = {
#    Name = "ec2-win-${local.naming_suffix}"
#  }
#}

resource "aws_security_group" "di_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }

  ingress {
    from_port = 135
    to_port   = 135
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = 445
    to_port   = 445
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
    ]
  }

  #ingress {
  #  from_port = 1025
  #  to_port   = 65535
  #  protocol  = "tcp"

  #  cidr_blocks = [
  #    "${var.dq_database_cidr_block_secondary}",
  #  ]
  #}

  #ingress {
  #  from_port = 1025
  #  to_port   = 65535
  #  protocol  = "udp"

  #  cidr_blocks = [
  #    "${var.dq_database_cidr_block_secondary}",
  #  ]
  #}

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "di_web_linux" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-linux-${local.naming_suffix}"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_pipe_apps_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

#resource "aws_instance" "di_web_linux" {
#  key_name                    = "${var.key_name_linux}"
#  ami                         = "${data.aws_ami.di_web_linux.id}"
#  iam_instance_profile        = "${aws_iam_instance_profile.data_ingest_linux.id}"
#  instance_type               = "t2.large"
#  vpc_security_group_ids      = ["${aws_security_group.di_web_linux.id}"]
#  associate_public_ip_address = false
#  subnet_id                   = "${aws_subnet.data_ingest.id}"
#  private_ip                  = "${var.dp_web_linux_private_ip}"
#  monitoring                  = true

#  user_data = <<EOF
#!/bin/bash

#set -e

#exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

#if [ ! -f /bin/aws ]; then
#    curl https://bootstrap.pypa.io/get-pip.py | python
#    pip install awscli
#fi

#sudo -u wherescape sh -c "aws --region eu-west-2 ssm get-parameter --name maytech_prod_private_key --query 'Parameter.Value' --output text --with-decryption | base64 --decode > ~/maytech_prod_id_rsa"
#sudo -u wherescape sh -c "aws --region eu-west-2 ssm get-parameter --name ssh_public_key_ssm_wherescape  --query 'Parameter.Value' --output text --with-decryption > ~/.ssh/authorized_keys"
#sudo -u wherescape sh -c "aws --region eu-west-2 ssm get-parameter --name job50_ssm_to_gp_ssh_private_key --query 'Parameter.Value' --output text --with-decryption | base64 --decode > ~/.ssh/id_rsa"
#sudo -u wherescape sh -c "aws --region eu-west-2 ssm get-parameter --name linux_ingest_wsr_user_known_hosts --query 'Parameter.Value' --output text --with-decryption | base64 --decode > ~/.ssh/known_hosts"
#sudo chmod 600 /home/wherescape/.ssh/id_rsa
#sudo chmod 600 /home/wherescape/maytech_prod_id_rsa
#sudo chmod 644 /home/wherescape/.ssh/known_hosts
#
#sudo touch /etc/profile.d/script_envs.sh
#sudo setfacl -m u:wherescape:rwx /etc/profile.d/script_envs.sh

#sudo -u wherescape echo "
#export SSH_PRIVATE_KEY="/home/wherescape/maytech_prod_id_rsa"
#export SSH_REMOTE_USER=`aws --region eu-west-2 ssm get-parameter --name maytech_user_nats --query 'Parameter.Value' --output text --with-decryption`
#export SSH_REMOTE_HOST=`aws --region eu-west-2 ssm get-parameter --name maytech_host --query 'Parameter.Value' --output text --with-decryption`
#export SSH_LANDING_DIR=`aws --region eu-west-2 ssm get-parameter --name NATS_sftp_landing_dir --query 'Parameter.Value' --output text --with-decryption`
#export username=`aws --region eu-west-2 ssm get-parameter --name ACL_ftp_username --query 'Parameter.Value' --output text --with-decryption`
#export password=`aws --region eu-west-2 ssm get-parameter --name ACL_ftp_user_password --query 'Parameter.Value' --output text --with-decryption`
#export server=`aws --region eu-west-2 ssm get-parameter --name ACL_ftp_server_public_ip --query 'Parameter.Value' --output text --with-decryption`
#export GA_BUCKET_ACCESS_KEY_ID=`aws --region eu-west-2 ssm get-parameter --name gait_access_key --query 'Parameter.Value' --output text --with-decryption`
#export GA_BUCKET_SECRET_ACCESS_KEY=`aws --region eu-west-2 ssm get-parameter --name gait_secret_key --query 'Parameter.Value' --output text --with-decryption`
#export GA_BUCKET_NAME=`aws --region eu-west-2 ssm get-parameter --name ga_bucket_name --query 'Parameter.Value' --output text --with-decryption`
#export DATA_ARCHIVE_BUCKET_NAME=`aws --region eu-west-2 ssm get-parameter --name data_archive_bucket_name --query 'Parameter.Value' --output text --with-decryption`
#export MAYTECH_HOST=`aws --region eu-west-2 ssm get-parameter --name maytech_host --query 'Parameter.Value' --output text --with-decryption`
#export MAYTECH_USER=`aws --region eu-west-2 ssm get-parameter --name maytech_user --query 'Parameter.Value' --output text --with-decryption`
#export MAYTECH_OAG_LANDING_DIR=`aws --region eu-west-2 ssm get-parameter --name maytech_oag_landing_dir --query 'Parameter.Value' --output text --with-decryption`
#export MAYTECH_OAG_PRIVATE_KEY_PATH="/home/wherescape/maytech_prod_id_rsa"
#export MVT_SCHEMA_SSM_USERNAME="ssm"
#export MVT_SCHEMA_SSM_PASSWORD=`aws --region eu-west-2 ssm get-parameter --name mvt_schema_ssm_password --query 'Parameter.Value' --output text --with-decryption`
#export RDS_POSTGRES_DATA_INGEST_HOST_NAME=`aws --region eu-west-2 ssm get-parameter --name rds-postgres-dataingest-hostname --query 'Parameter.Value' --output text --with-decryption`
#export RDS_POSTGRES_DATA_INGEST_NAME=`aws --region eu-west-2 ssm get-parameter --name rds-postgres-dataingest-name --query 'Parameter.Value' --output text --with-decryption`
#export RDS_POSTGRES_DATA_INGEST_PASSWORD=`aws --region eu-west-2 ssm get-parameter --name rds-postgres-dataingest-password --query 'Parameter.Value' --output text --with-decryption`
#export RDS_POSTGRES_DATA_INGEST_USERNAME=`aws --region eu-west-2 ssm get-parameter --name rds-postgres-dataingest-username --query 'Parameter.Value' --output text --with-decryption`
#export DATA_LANDING_BUCKET_NAME=`aws --region eu-west-2 ssm get-parameter --name data_landing_bucket_name --query 'Parameter.Value' --output text --with-decryption`
#export ACL_DB_LOCATION=`aws --region eu-west-2 ssm get-parameter --name acl-db-location --query 'Parameter.Value' --output text --with-decryption`
#export ACL_S3_DESTINATION=`aws --region eu-west-2 ssm get-parameter --name acl-backup-destination --query 'Parameter.Value' --output text --with-decryption`
#export OAG_DB_LOCATION=`aws --region eu-west-2 ssm get-parameter --name oag-db-location --query 'Parameter.Value' --output text --with-decryption`
#export OAG_S3_DESTINATION=`aws --region eu-west-2 ssm get-parameter --name oag-backup-destination --query 'Parameter.Value' --output text --with-decryption`
#export ADT_SCRIPTS_FOLDER=`aws --region eu-west-2 ssm get-parameter --name linux-data-ingest-adt-scripts --query 'Parameter.Value' --output text --with-decryption`
#" > /etc/profile.d/script_envs.sh

#su -c "/etc/profile.d/script_envs.sh" - wherescape

#su -c "/ADT/scripts/pm2_startup.sh" - wherescape

#su -c "/ADT/scripts/acl_download.sh" - wherescape && sed -i 's/#NotRunning#//g' /var/spool/cron/wherescape

#export DOMAIN_JOIN=`aws --region eu-west-2 ssm get-parameter --name addomainjoin --query 'Parameter.Value' --output text --with-decryption`
#yum -y install sssd realmd krb5-workstation adcli samba-common-tools expect
#sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#systemctl reload sshd
#chkconfig sssd on
#systemctl start sssd.service
#echo "%Domain\\ Admins@dq.homeoffice.gov.uk ALL=(ALL:ALL) ALL" >>  /etc/sudoers
#echo "%Domain\\ Admins@DQ.HOMEOFFICE.GOV.UK ALL=(ALL:ALL) ALL" >>  /etc/sudoers
#expect -c "spawn realm join -U domain.join@dq.homeoffice.gov.uk DQ.HOMEOFFICE.GOV.UK; expect \"*?assword for domain.join@DQ.HOMEOFFICE.GOV.UK:*\"; send -- \"$DOMAIN_JOIN\r\" ; expect eof"
#systemctl restart sssd.service

#sudo -i
#systemctl stop clamd@scan
#chown -R wherescape:SSM /var/run/clamd.scan
#systemctl start clamd@scan

#mkfs.xfs /dev/xvdb
#mkdir -p /mnt/var/log/
#mount /dev/xvdb /mnt/var/log
#rsync -a /var/log/ /mnt/var/log
#echo '/dev/xvdb /var/log xfs defaults 0 0' >> /etc/fstab
#umount /mnt/var/log/
#reboot
#EOF

#  tags = {
#    Name = "linux-instance-${local.naming_suffix}"
#  }

#  lifecycle {
#    prevent_destroy = true
#
#    ignore_changes = [
#      "ami",
#      "user_data",
#    ]
#  }
#}
