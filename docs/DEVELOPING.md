# Setting up Your _Flower_ Development Environment

First you'll need to install:

* [Git](https://git-scm.com/).
  On Ubuntu: `sudo apt install git`, on macOS: `brew install git`.
* [GNU Make](https://www.gnu.org/software/make/).
  This is probably already installed, run `make --version` to check.
* [pyenv](https://github.com/pyenv/pyenv).
  Follow the instructions in pyenv's README to install it.
  The **Homebrew** method works best on macOS.
  The **Basic GitHub Checkout** method works best on Ubuntu.
  You _don't_ need to set up pyenv's shell integration ("shims"), you can
  [use pyenv without shims](https://github.com/pyenv/pyenv#using-pyenv-without-shims).

Then to set up your development environment:

```terminal
git clone https://github.com/hypothesis/flower.git
cd flower
make devdata
make help
```

A Flower instance can only connect to one RabbitMQ instance,
but in the development environment h, Checkmate and LMS each have their own
RabbitMQ instances.
So in the development environment `make dev` launches three separate Flower
instances:

* http://localhost:5555/ for a Flower instance connected to h's RabbitMQ
* http://localhost:5556/ for a Flower instance connected to Checkmate's RabbitMQ
* http://localhost:5557/ for a Flower instance connected to LMS's RabbitMQ

Each of these Flower instances will ask you to log in with the same HTTP basic
auth username and password, which you'll find in 1Password.

Of course if you want to actually see any data in these Flower instances
you need to also run the development environments for
[h](https://github.com/hypothesis/h),
[Checkmate](https://github.com/hypothesis/checkmate) and
[LMS](https://github.com/hypothesis/lms) locally.

In staging and production h, Checkmate and LMS all share a single RabbitMQ
instance so there's only one production Flower instance at
<https://flower.hypothes.is> (staging instance:
<https://flower.staging.hypothes.is>).

There *are* separate RabbitMQ  and Flower instances for Canada, however:
<https://flower.ca.hypothes.is>.

# Changing the Project's Python Version

To change what version of Python the project uses:

1. Change the Python version in the
   [cookiecutter.json](.cookiecutter/cookiecutter.json) file. For example:

   ```json
   "python_version": "3.10.4",
   ```

2. Re-run the cookiecutter template:

   ```terminal
   make template
   ```

3. Re-compile the `requirements/*.txt` files.
   This is necessary because the same `requirements/*.in` file can compile to
   different `requirements/*.txt` files in different versions of Python:

   ```terminal
   make requirements
   ```

4. Commit everything to git and send a pull request

# Changing the Project's Python Dependencies

## To Add a New Dependency

Add the package to the appropriate [`requirements/*.in`](requirements/)
file(s) and then run:

```terminal
make requirements
```

## To Remove a Dependency

Remove the package from the appropriate [`requirements/*.in`](requirements)
file(s) and then run:

```terminal
make requirements
```

## To Upgrade or Downgrade a Dependency

We rely on [Dependabot](https://github.com/dependabot) to keep all our
dependencies up to date by sending automated pull requests to all our repos.
But if you need to upgrade or downgrade a package manually you can do that
locally.

To upgrade a package to the latest version in all `requirements/*.txt` files:

```terminal
make requirements --always-make args='--upgrade-package <FOO>'
```

To upgrade or downgrade a package to a specific version:

```terminal
make requirements --always-make args='--upgrade-package <FOO>==<X.Y.Z>'
```

To upgrade **all** packages to their latest versions:

```terminal
make requirements --always-make args=--upgrade
```
