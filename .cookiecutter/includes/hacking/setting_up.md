
A Flower instance can only connect to one RabbitMQ instance,
but in the development environment h, Checkmate and LMS each have their own RabbitMQ instances.
So in the development environment `make dev` launches three separate Flower instances:

* http://localhost:5555/ for a Flower instance connected to h's RabbitMQ
* http://localhost:5556/ for a Flower instance connected to Checkmate's RabbitMQ
* http://localhost:5557/ for a Flower instance connected to LMS's RabbitMQ

Each of these Flower instances will ask you to log in with the same HTTP basic auth username and password, which you'll find in 1Password.

In staging and production h, Checkmate and LMS all share a single RabbitMQ instance so there's only one Flower instance at <https://flower.hypothes.is> (<https://flower.staging.hypothes.is> for staging).
There are separate RabbitMQ  and Flower instances for Canada, however: <https://flower.ca.hypothes.is>.
