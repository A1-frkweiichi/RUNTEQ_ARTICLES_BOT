#!/bin/bash

heroku ps:scale worker=1

sleep 60

heroku run rake post:execute
