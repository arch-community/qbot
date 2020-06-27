BA="--ruby=ruby_2_7"

bundix $BA -l
bundix $BA -m
direnv reload
bundle install

# vim: ft=bash
