# Tinder - get the Campfire started

[![Gem Version](https://badge.fury.io/rb/tinder.png)](http://badge.fury.io/rb/tinder)
[![Build Status](https://travis-ci.org/collectiveidea/tinder.png?branch=master)](https://travis-ci.org/collectiveidea/tinder)
[![Code Climate](https://codeclimate.com/github/collectiveidea/tinder.png)](https://codeclimate.com/github/collectiveidea/tinder)

Tinder is a library for interfacing with Campfire, the chat application from 37Signals, allowing you to programmatically manage and speak/listen in chat rooms.  As of December 2009, thanks to initial work from Joshua Peek at 37signals, it now makes use of the official Campfire API (described at: http://developer.37signals.com/campfire/).

## Usage

    campfire = Tinder::Campfire.new 'mysubdomain', :token => '546884b3d8fee4d80665g561caf7h9f3ea7b999e'
    # or you can still use username/password and Tinder will look up your token
    # campfire = Tinder::Campfire.new 'mysubdomain', :username => 'user', :password => 'pass'
    # or if you have an OAuth token then you can use that to connect
    # campfire = Tinder::Campfire.new 'mysubdomain', :oauth_token => '546884b3d8fee4d80665g561caf7h9f3ea7b999e'

    room = campfire.rooms.first
    room.rename 'New Room Names'
    room.speak 'Hello world!'
    room.paste "my pasted\ncode"

    room = campfire.find_room_by_guest_hash 'abc123', 'John Doe'
    room.speak 'Hello world!'

See the RDoc for more details.

## Installation

    gem install tinder

## Contributions

Tinder is open source and contributions from the community are encouraged! No contribution is too small. Please consider:

* adding an awesome feature
* fixing a terrible bug
* updating documentation
* fixing a not-so-bad bug
* fixing typos

For the best chance of having your changes merged, please:

1. Ask us! We'd love to hear what you're up to.
2. Fork the project.
3. Commit your changes and tests (if applicable (they're applicable)).
4. Submit a pull request with a thorough explanation and at least one animated GIF.
