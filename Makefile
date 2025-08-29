NAME = inception

COMPOSE = docker-compose -f srcs/docker-compose.yml

all: up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: stop start

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	$(COMPOSE) rm -f

fclean: clean
	docker volume rm $$(docker volume ls -q | grep "$(NAME)_") || true
	docker network rm $(NAME)_inception || true

re: fclean all
 
