# TODO

## Planned

- [ ] Clean up & DRY multiple stack implementation
- [ ] Add integration tests for all common command-line combos
- [ ] Output friendly errors for malformed input of all kinds
- [ ] Re-architect to abstract away all stack dependencies

## Done

- [x] Support another stack: Python
- [x] Re-architect to prepare for supporting an additional stack
- [x] Support versioning for stack
- [x] Support versioning for libraries
- [x] Separate command execution into separate class
- [x] Separate argument processing & usage into separate class
- [x] Re-architect to start separating argument processing
- [x] Sort arguments so that unnecessary images aren't created
- [x] Have a `replr prune` command to delete all docker images created by replr
- [x] Publish as gem
- [x] Ensure that multiple gems work fine
- [x] Find a way to suppress Docker run output, it's too verbose. Maybe through -d flag & attach later?
