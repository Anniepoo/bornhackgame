# BornHack Game

A location based game.

## Changelog

- No longer depends on pack(identity). Portions of library(identity/login_database) transcluded into database.pl
because it was becoming unweildy to handle in pack(identity) just for 69 LoC

## Run

swipl -s server.pl -g go

Browse http://localh:5000/