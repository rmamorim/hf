#! /bin/bash

rsync -Cravzp  --delete-excluded . rimirarim@gaborone.dreamhost.com:/home/rimirarim/backup/hf/
rsync -Cravzp  --delete-excluded . '/cygdrive/c/Users/Ricardo/Dropbox/railscast/hf'

