# Tinder - get the Campfire started

Tinder is a library for interfacing with Campfire, the chat application from 37Signals, allowing you to programmatically manage and speak/listen in chat rooms.  As of December 2009, thanks to initial work from Joshua Peek at 37signals, it now makes use of the official Campfire API (described at: http://developer.37signals.com/campfire/).

## Usage

    campfire = Tinder::Campfire.new 'mysubdomain', :token => '546884b3d8fee4d80665g561caf7h9f3ea7b999e'
    # or you can still use username/password and Tinder will look up your token
    # campfire = Tinder::Campfire.new 'mysubdomain', :username => 'user', :password => 'pass'

    room = campfire.rooms.first
    room.rename 'New Room Names'
    room.speak 'Hello world!'
    room.paste "my pasted\ncode"

    room = campfire.find_room_by_guest_hash 'abc123', 'John Doe'
    room.speak 'Hello world!'

See the RDoc for more details.

## Installation

    gem install tinder

## Continuous Integration

[![Build Status](https://secure.travis-ci.org/collectiveidea/tinder.png)](http://travis-ci.org/collectiveidea/tinder) [![Dependency Status](https://gemnasium.com/collectiveidea/tinder.png)](https://gemnasium.com/collectiveidea/tinder)

## How to contribute

If you find what looks like a bug:

1. Check the GitHub issue tracker to see if anyone else has had the same issue.
   http://github.com/collectiveidea/tinder/issues/
2. If you don't see anything, create an issue with information on how to reproduce it.

If you want to contribute an enhancement or a fix:

1. Fork the project on github.
   http://github.com/collectiveidea/tinder
2. Make your changes with tests.
3. Commit the changes without making changes to the Rakefile, VERSION, or any other files that aren't related to your enhancement or fix
4. Send a pull request.
