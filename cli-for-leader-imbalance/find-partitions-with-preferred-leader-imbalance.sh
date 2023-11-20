#!/bin/bash
KAFKA_HOME="/engn/confluent-7.4.1"
KAFKA_CONFIG_PATH="/engn/kafka"
BROKER_HOST="tester101.young.com"
BROKER_PORT=9092

${KAFKA_HOME}/bin/kafka-topics --describe --bootstrap-server ${BROKER_HOST}:${BROKER_PORT} --command-config ${KAFKA_CONFIG_PATH}/client.properties | grep Isr | awk -F"\t" '{print $1 $2" "$3" "$4" "$5}'  | awk -F'[ ,]' '{print $2" "$4" "$6" "$8}' | awk '$3 != $4 {print $0}'
