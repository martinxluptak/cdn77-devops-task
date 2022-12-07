setup:
	sh setup.sh
deploy:
	docker-compose up --remove-orphans --detach
	ansible-playbook -i 'nginx-1,' playbook/nginx.yml  -c docker	
	ansible-playbook -i 'nginx-2,' playbook/cache.yml  -c docker
test:
	python3 test/nginx_load_test.py	
clean:
	docker rm -f $$( docker ps --filter "network=cdn77-net" --format "{{.Names}}" )
