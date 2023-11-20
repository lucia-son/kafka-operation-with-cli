## young
#!/bin/bash
KAFKA_HOME="/engn/confluent-7.4.1"
KAFKA_CONFIG_PATH="/engn/kafka"
BROKER_HOST="tester101.young.com"
BROKER_PORT=9092
TOPIC=
PARTITION_NUM=

${KAFKA_HOME}/bin/kafka-leader-election --bootstrap-server ${BROKER_HOST}:${BROKER_PORT} --election-type PREFERRED --admin.config ${KAFKA_CONFIG_PATH}/client.properties --topic ${TOPIC} --partition ${PARTITION_NUM}
