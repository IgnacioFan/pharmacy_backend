# README

A backend service and a database for a pharmacy platform.

### How to run the application

On the local machine, please follow the commands below to build it.

```bash
$ docker-compose up -d

# go inside the container, run the migrate data command.
$ docker exec -it pharmacy_api bash

# To have some seed data in database, you have to reach out this source first (https://github.com/IgnacioFan/phantom_mask/tree/master/data)
# Please download pharmacies.json and user.json before running the following commands!
# Don't forget to change the file path that links to the file location.
$ rake import_data:pharmacies["file_path"]
$ rake import_data:user["file_path"]

# Once you have some data in your database, go check out the API docs (visit Swagger UI)
# http://localhost:3000/api-docs/index.html
```

### How to run test

```bash
make test
```

### Others

Enter rails console?
```bash
make console
```

Want to access to database?

```bash
make db-cli
```

