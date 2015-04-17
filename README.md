# Badges-API documentation



## Overview

The API is developed using:
• The Ruby framework: Sinatra. 
• ORM: Active Record.
• Database: SQLite (Dev) // PostgreSQL (Prod).

##Structure

####/app.rb

This file contains the start point of the application and here we put all the endpoints of the API.

####/config

Contains all the setup files (For example: The DB connection files).

####/models

Contains all the Model Classes of the WeGo app. ( *.rb ). These files are required by the app.rb .

####/views

Contains all the view files (*.erb or using a similar template).

####/tasks

Contains all the Rake tasks (You can see the tasks using: $ bundle exec rake -T like migrations of the DB).

####/public

Contains all the static files of Sinatra like stylesheets, images, javascripts.

###ORM

The ORM is ActiveRecord. For more info: https://github.com/rails/rails/tree/master/activerecord

Quick Guide: http://guides.rubyonrails.org/index.html

###RAKE

Provides the tasks for the ORM interaction, the DB creations, migrations.

###Setup

Install the Gemfile and dependencies:
• bundle install.

In order to run the API:
• bundle exec rackup.
Run the tests:
• bundle exec rake.
• Run single test: bundle exec rake test/<test_unit_name.rb>