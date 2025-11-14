message := '{"NumeroPedido": 1, "Preco": 0, "MetodoPagamento": "credit"}'

queue_name := checkout

create_message:
	aws sqs send-message \
  	--endpoint-url http://localhost:4566 \
  	--queue-url "http://localhost:4566/000000000000/$(queue_name)" \
  	--message-body $(message)\
  	--region us-east-1 \
  	--profile localstack

up-compose:
	docker-compose down -v
	docker-compose --env-file ./.env up --build

up-kube:
	kubectl apply -f .kube/postgres-secret.yaml
	kubectl apply -f .kube/postgres-pvc.yaml
	kubectl apply -f .kube/postgres-deployment.yaml
	kubectl apply -f .kube/postgres-service.yaml
	kubectl apply -f .kube/deployment.yaml
	kubectl apply -f .kube/service.yaml

down-kube:
	kubectl delete -f .kube/