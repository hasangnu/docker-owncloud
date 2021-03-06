```yalm
version: '3.1'

services:

  owncloud:
    image: hasangnu/owncloud
    container_name: owncloud
    restart: always
    ports:
      - 880:80
    volumes:
    - ./data/apps/:/var/www/html/apps
    - ./data/config/:/var/www/html/config
    - ./data/data/:/var/www/html/data

  mysql:
    image: hasangnu/mariadb
    container_name: owncloud_mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: example
      MYSQL_USER: example
      MYSQL_PASSWORD: example
    volumes:
     - ./data/mariadb:/var/lib/mysql
```
```
docker-compose up -d
```
