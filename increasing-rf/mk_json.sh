#!/bin/bash


CONFLUENT_HOME=/app/confluent-7.4.0
WORK_DIR=`pwd`/work
PONE_DIR=$WORK_DIR/pone
BROKER_HOST=localhost
BROKER_PORT=9092
BROKER_IDS=(1 2 3)
RF=$1

if [ ! -d $WORK_DIR ];then
	mkdir -p $WORK_DIR
fi

if [ ! -d $PONE_DIR ];then
	mkdir -p $PONE_DIR
fi

$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server $BROKER_HOST:$BROKER_PORT --describe |grep ReplicationFactor|awk -v var=$RF '$8 == var {print} '|awk '{print $2" "$6}' > $WORK_DIR/output.out

while read -r line
 do
	echo $line

	NUMBER_OF_PARTITIONS=$(echo $line|awk '{print $2}')
	TOPIC_NAME=$(echo $line|awk '{print $1}') 

	JSON_HOME="${WORK_DIR}"
	output_file="${TOPIC_NAME}-add-rf.json"

	# Beginning of the file
	echo '{"version":1,' > ${WORK_DIR}/$output_file
	echo '  "partitions":[' >> ${WORK_DIR}/$output_file

	current_broker_id_index=0

	# Responsible for the circular array over the brokers IDs
	set_next_broker(){
    		current_broker_id_index=$1
    		current_broker_id_index=$(($current_broker_id_index + 1))
    		current_broker_id_index=$(($current_broker_id_index % ${#BROKER_IDS[@]}))
    		return $current_broker_id_index
	}

	# Forges the string containing the replicas brokers of a partition
	get_brokers_string(){
    		current_broker_id_index=$1
    		brokers_string="${BROKER_IDS[$current_broker_id_index]}"
    		set_next_broker $current_broker_id_index
    		current_broker_id_index=$?
    		brokers_string="$brokers_string,${BROKER_IDS[$current_broker_id_index]}"
    		set_next_broker $current_broker_id_index
    		current_broker_id_index=$?
    		brokers_string="$brokers_string,${BROKER_IDS[$current_broker_id_index]}"
    		#set_next_broker $current_broker_id_index
    		#current_broker_id_index=$?
    		echo $brokers_string
    		return $current_broker_id_index
	}

	# Create all the lines
	partition_number=0
	while (("$partition_number" < "$NUMBER_OF_PARTITIONS-1")); do
    	brokers_string=$(get_brokers_string $current_broker_id_index)
    	current_broker_id_index=$?
    	echo "    {\"topic\":\"$TOPIC_NAME\",\"partition\":$partition_number,\"replicas\":[$brokers_string]}," >> ${WORK_DIR}/$output_file
    	partition_number=$(($partition_number + 1))
	done

	# Last line without trailing coma
	brokers_string=$(get_brokers_string $current_broker_id_index)
	echo "    {\"topic\":\"$TOPIC_NAME\",\"partition\":$partition_number,\"replicas\":[$brokers_string]}" >> ${WORK_DIR}/$output_file

	# End of the file
	echo ']}' >> ${WORK_DIR}/$output_file


	if [ $NUMBER_OF_PARTITIONS == 1 ]; then
		mv ${WORK_DIR}/$output_file $PONE_DIR

		echo -e "$CONFLUENT_HOME/bin/kafka-reassign-partitions --bootstrap-server $BROKER_HOST:$BROKER_PORT --reassignment-json-file ${PONE_DIR}/$output_file --execute" >> rf-$RF-command.out
        	echo -e "" >> rf-$RF-command.out
	else

	echo -e "$CONFLUENT_HOME/bin/kafka-reassign-partitions --bootstrap-server $BROKER_HOST:$BROKER_PORT --reassignment-json-file $WORK_DIR/$output_file --execute" >> rf-$RF-command.out
	echo -e "" >> rf-$RF-command.out

	fi

	#exit 0

done < $WORK_DIR/output.out


