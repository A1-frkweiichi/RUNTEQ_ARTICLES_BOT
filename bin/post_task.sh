#!/bin/bash

heroku ps:restart worker

sleep 60

heroku run rake post:execute
