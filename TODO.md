# TODO

## Planned

- [ ] Sort arguments so that unnecessary images aren't created
- [ ] Separate argument processing & usage into separate class
- [ ] Re-architect to abstract away all stack dependencies
- [ ] Support another stack: Python?

## Done

- [x] Have a `replr prune` command to delete all docker images created by replr
- [x] Publish as gem
- [x] Ensure that multiple gems work fine
- [x] Find a way to suppress Docker run output, it's too verbose. Maybe through -d flag & attach later?
