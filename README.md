# Replr

A single line REPL for your favorite languages & libraries. Built on Docker.

This is currently usable & stable, and supports the `ruby`, `python` and `node` stacks.

See [TODO](TODO.md) for future work.

## Quickstart

```
replr <stack> <libraries...>
```

So for a simple `ruby` REPL, including the `chronic` gem, it would be:

```
replr ruby chronic
```

Or for a `python` REPL, including the flask and requests packages, it would be:

```
replr python flask requests
```

You can also specify versions of stacks & libraries to install:

```
replr ruby:2.3.1 chronic:0.10.1 activesupport:5.1.0
```

That's it! It's very simple. Replr currently supports three stacks: `ruby`, `python` and `node`.

## Install

replr is built on Ruby and requires Ruby 2.5+ installed.

```
gem install replr
```

That's it! `replr` should now be available in your `$PATH`.

## More Commands

```
replr prune
```

will delete all docker images associated with replr. This saves space!

## Contributing & Development

replr is built on Ruby and requires a Ruby 2.5+ installed to develop. It's pretty easy to get started and add a stack, please see [node's implementation](lib/replr/stack/node/repl_maker.rb) for a quick-start. There's also a companion integration spec that tests expected behavior in [node's test suite](spec/replr/stack/node/repl_maker_spec.rb) that you should emulate and implement for every stack you make.

Most of the "scaffolding" around creating the REPL & dealing with docker's implementation details have been abstracted away if you use the `Replr::Stack::REPLMaker` class, so you only need to implement stack-specific functionality. This includes:

- creating a `Dockerfile.template`([example](lib/replr/stack/node/Dockerfile.template)) (with `%%VERSION%%` tags) for the stack.
- creating a library file ([example](lib/replr/stack/node/repl_maker.rb#L32)) from mentioned gems and versions.
- & setting appropriate `set_filter_lines_for_install` ([example](lib/replr/stack/node/repl_maker.rb#L27)) to mask away unnecessary output during installation.

## Details

replr uses docker to manage different stacks and installed libraries. It creates docker images that are tagged `replr-<stack>-<libraries...>` for each stack and library combo you initiate.

The first time you start a new stack & library combo, docker will take some time to spin up instances. Future executions of the same stack should be near-instant.

This is how a full output from a replr install will look like the first time you try out a new stack & library combo:

```
❯ replr ruby chronic
(1/25) Upgrading musl (1.1.14-r14 -> 1.1.14-r16)
(2/25) Installing gmp (6.1.0-r0)
(3/25) Installing libgcc (5.3.0-r0)
(4/25) Installing libstdc++ (5.3.0-r0)
(5/25) Installing libgmpxx (6.1.0-r0)
(6/25) Installing gmp-dev (6.1.0-r0)
(7/25) Installing libedit (20150325.3.1-r3)
(8/25) Installing ruby-libs (2.3.7-r0)
(9/25) Installing ruby-dev (2.3.7-r0)
(10/25) Installing binutils-libs (2.26-r1)
(11/25) Installing binutils (2.26-r1)
(12/25) Installing isl (0.14.1-r0)
(13/25) Installing libgomp (5.3.0-r0)
(14/25) Installing libatomic (5.3.0-r0)
(15/25) Installing mpfr3 (3.1.2-r0)
(16/25) Installing mpc1 (1.0.3-r0)
(17/25) Installing gcc (5.3.0-r0)
(18/25) Installing make (4.1-r1)
(19/25) Installing musl-dev (1.1.14-r16)
(20/25) Installing libc-dev (0.7-r0)
(21/25) Installing fortify-headers (0.8-r0)
(22/25) Installing g++ (5.3.0-r0)
(23/25) Installing build-base (0.4-r1)
(24/25) Installing build-dependencies (0)
(25/25) Upgrading musl-utils (1.1.14-r14 -> 1.1.14-r16)
1 gem installed
Fetching gem metadata from https://rubygems.org/.............
Installing chronic 0.10.2
Bundle complete! 1 Gemfile dependency, 2 gems now installed.
Gems in the groups development and test were not installed.
Bundled gems are installed into `/usr/local/bundle`
irb(main):001:0>
```

The next time, it's much cleaner:

```
❯ replr ruby chronic
irb(main):001:0> Chronic.parse("tomorrow")
=> 2018-08-25 12:00:00 +0000
irb(main):002:0>
```

As you can see, replr tries its best to abstract away the underlying docker installation. You shouldn't have to worry about Dockerfile & so on just to get a REPL!

It also tries its best to make sure libraries you mention are auto-required in the REPL, so you don't have to do any additional work!
