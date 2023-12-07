./bin/kafka-topics --bootstrap-server <BROKER_HOST>:9092 --describe | awk '/retention.ms/' | awk -F'[:,\t]'  '{for(i=1;i<=NF;i++) {if ($i ~ /retention.ms/ ) print $1 " ::: " $2 " ::: " $i }}' | grep -v "delete.retention.ms" | awk -F'[=]' '$2 < 43200000 {print}'