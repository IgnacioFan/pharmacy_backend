APP_CNAME=pharmacy_api
POSTGRES_CNAME=pharmacy_db
POSTGRES_USER=kdan
POSTGRES_DATABASE_DEV=pharmacy_development

console:
	docker exec -it $(APP_CNAME) rails console

test:
	docker exec -e "RAILS_ENV=test" $(APP_CNAME) bundle exec rspec $(path)

db-cli:
	docker exec -it $(POSTGRES_CNAME) psql -U $(POSTGRES_USER) $(POSTGRES_DATABASE_DEV)
