# TODO

## Planned

- [ ] Support versioning for library
- [ ] Support versioning for stack
- [ ] Re-architect to abstract away all stack dependencies
- [ ] Support another stack: Python?

## Done

- [x] Separate argument processing & usage into separate class
- [x] Re-architect to start separating argument processing
- [x] Sort arguments so that unnecessary images aren't created
- [x] Have a `replr prune` command to delete all docker images created by replr
- [x] Publish as gem
- [x] Ensure that multiple gems work fine
- [x] Find a way to suppress Docker run output, it's too verbose. Maybe through -d flag & attach later?
