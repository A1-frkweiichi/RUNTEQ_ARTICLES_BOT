#!/bin/bash

heroku ps:scale worker=1

sleep 10

heroku run rake articles:fetch
