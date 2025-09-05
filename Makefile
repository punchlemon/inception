NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

.PHONY: all build up down start stop restart logs ps clean fclean re nocache prune

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

# Remove containers only (keep images, volumes)
clean:
	$(COMPOSE) down --remove-orphans || true

# Full cleanup: containers, images built for this project, volumes, network, build cache
fclean:
	$(COMPOSE) down --rmi local --volumes --remove-orphans || true
	# Explicitly try removing service images (ignore errors if already gone)
	docker image rm nginx wordpress mariadb 2>/dev/null || true
	# Remove project network if still present
	docker network rm $(NAME)_inception 2>/dev/null || true
	# Prune builder cache (dangling build layers)
	docker builder prune -f >/dev/null 2>&1 || true

re: fclean all

