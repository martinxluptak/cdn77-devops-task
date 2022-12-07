setup:
	sh setup.sh
deploy:
	docker compose up --remove-orphans --detach
	ansible-playbook -i 'nginx-1,' playbook/nginx.yml  -c docker	
	ansible-playbook -i 'nginx-2,' playbook/cache.yml  -c docker
clean:
	docker rm -f $$( docker ps --filter "network=cdn77-net" --format "{{.Names}}" )
