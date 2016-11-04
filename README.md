# ETMoses

![Screenshot](https://s3.amazonaws.com/f.cl.ly/items/1x3M222e0W1u360X143V/Screen%20Shot%202015-10-19%20at%2012.12.58.png)

This is the source code of [ETMoses](http://moses.et-model.com):
an online decision support tool to create local energy situations for
neighbourhoods, cities and regions with a time resolution of 15 minutes.
This software is [Open Source](LICENSE.txt), so you can
fork it and alter at your will.

If you have any questions, please [contact us](http://quintel.com/contact).

## Documentation

* [User documentation for ETMoses](https://github.com/quintel/documentation/tree/master/etmoses) can be found on the [ETM documentation repository](https://github.com/quintel/documentation/tree/master/)
* Technical documentation is located on the [ETMoses Wiki page](https://github.com/quintel/etmoses/wiki).
* A PDF document describing the ideas and choices behind the modeling of ETMoses can be downloaded [here](https://github.com/quintel/documentation/blob/master/etmoses/ETMoses_v01.pdf).

## Build Status

### Master
![Master branch](https://semaphoreci.com/api/v1/projects/e51cd924-a6d4-4c0e-a36c-af7f9e6789ba/550483/badge.svg)

### Production
![Production branch](https://semaphoreci.com/api/v1/projects/e51cd924-a6d4-4c0e-a36c-af7f9e6789ba/555979/badge.svg)

## License

ETMoses is released under the [MIT License](LICENSE.txt).

## Branches

* **master**: Working branch. Please always merge pull requests with this
  branch, just like any other Git project This branch is automatically deployed
  to [the ETMoses staging server](http://beta.moses.et-model.com).
* **production**: Tracks [the ETMoses production server](http://moses.et-model.com)

## Dependencies

* [Git](https://git-scm.com/)
* [Ruby 2.0+](https://www.ruby-lang.org)
* [Bundler](http://bundler.io)
* [MySQL database server](https://www.mysql.com)

## Installing

* Install ImageMagick
  * Ubuntu: `sudo apt-get install imagemagick libmagickwand-dev`
* Pull this repository with `git clone git@github.com:quintel/etmoses.git`
* Create your personal configuration files from the samples with
  ```
  cp -vn config/database.sample.yml config/database.yml
  cp -vn config/secrets.sample.yml config/secrets.yml
  cp -vn config/email.sample.yml config/email.yml
  ```

* Provide your MySQL username/password to `config/database.yml` if it is
  different from root/*blank*
* Run `bundle install` to install all the dependencies
* Create local database with `bundle exec rake db:create`
* Fill database structure and seeds with `bundle exec rake db:reset`
* Copy load profiles, technologies etc from staging server
  * Run `bin/sync_profiles`
  * Clone staging database to local development database
* If you need to connect to a local ETEngine server rather than the staging server, copy `config/settings.yml` to `config/settings.local.yml` and adapt settings accordingly
* Fire up your local server with `bundle exec rails server -p3000`
* Go to [localhost:3000](http://localhost:3000) and you should see ETMoses

## Bugs and feature requests

If you encounter a bug or if you have a feature request, you can either let us
know by creating an [Issue](http://github.com/quintel/etmoses/issues) *or* you
can try to fix it yourself and create a
[pull request](http://github.com/quintel/etmoses/pulls).
