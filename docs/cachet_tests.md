###Running Cachet unit tests

Running tests is driven by the `cachet_run_tests.sh` script in this repo.
The setup involves retrieving and building the Cachet app as follows:

- create a database (MySql used in this project)
- install PHP dependencies using composer
- generate an app key
- configure the .env file with the app key and database credentials
- install the app
- install Paratest for test parallelization
- run PHPUnit tests with Paratest
