# README

A backend service and a database for a pharmacy platform.

### How to run the application

On the local machine, please follow the commands below to build it.

```bash
$ docker-compose up -d

# go inside the container, run the migrate data command.
$ docker exec -it pharmacy_api bash

# Load seed data into PostgreSQL, you have to run the following commands!
$ rake import_data:pharmacies["db/seeds/pharmacies.json"]
$ rake import_data:users["db/seeds/users.json"]

# Once you have seed data, check out the API docs (visit Swagger UI)
# http://localhost:3000/api-docs/index.html
```

### How to run test

```bash
make test
```

### Others

Enter the pharmacy API

```bash
make bash
```

Enter rails console?

```bash
make console
```

Want to access to database?

```bash
make db-cli
```

