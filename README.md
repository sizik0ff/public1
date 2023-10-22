# Домашнее задание к занятию "Система Мониторинга Zabbix" - `Сизиков Максим`


### Задание 1

Установите Zabbix Server с веб-интерфейсом.


1. Установите PostgreSQL. Для установки достаточна та версия, что есть в системном репозитороии Debian 11

2. Пользуясь конфигуратором команд с официального сайта, составьте набор команд для установки последней версии Zabbix с поддержкой PostgreSQL и Apache.

3. Выполните все необходимые команды для установки Zabbix Server и Zabbix Web Server.


	Установка БД
		 
		apt install postgresql	
 

	Установка репозитория Zabbix	
		
		wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4+debian11_all.deb
		dpkg -i zabbix-release_6.0-4+debian11_all.deb
		apt update


	Установка Zabbix сервера, агента, фронтэнда 

		 apt install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

	Создание БД 	
		
		sudo -u postgres createuser --pwprompt zabbix	
		sudo -u postgres createdb -O zabbix zabbix 

	Импорт данных бд с паролем 

		zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

	Изменяем пароль на установленный в /etc/zabbix/zabbix_server.conf 

	Перезагружаем сервер, включаем автозагрузку 

		systemctl restart zabbix-server zabbix-agent apache2
		systemctl enable zabbix-server zabbix-agent apache2

![Название скриншота 1](ссылка на скриншот 1)`



### Задание 2

`Установите Zabbix Agent на два хоста.`

1. Установите Zabbix Agent на 2 вирт.машины, одной из них может быть ваш Zabbix Server.

2. Добавьте Zabbix Server в список разрешенных серверов ваших Zabbix Agentов.

3. Добавьте Zabbix Agentов в раздел Configuration > Hosts вашего Zabbix Servera.

4. Проверьте, что в разделе Latest Data начали появляться данные с добавленных агентов.



	Установка Zabbix-agent 

	   Установка репозитория Zabbix    

                wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-rel>
                dpkg -i zabbix-release_6.0-4+debian11_all.deb
                apt update


	Установка агента

		apt install zabbix-agent

	
	Перезагрузка агента, включаем автозагрузку 

		
		systemctl restart zabbix-agent
		systemctl enable zabbix-agent 
	

![Название скриншота 2](ссылка на скриншот 2)`




