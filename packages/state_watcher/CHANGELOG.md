## [0.1.0] 
### Added
- An `onDispose` method from the arg passed to `Provided` and `Computed` callback.
- An `it` method to the arg passed to `Computed` callbak in order to be able to update its value.
  
### Changed
- How dependencies are computed. Now every time you read a state, a dependency is created from where it is called. This is useful to be able to automatically dispose refs.
- Renamed `NodeHasDependentsError` to `NodeHasWatchersError`.

### Removed
- `StateStore.of` method since we can get a `BuildStore` from a `WatcherStatefulWidget`.
- `Store` interface, since only `BuildStore` is needed.
-  The `store` parameter in all methods of `StateObserver`.

## [0.0.7] 
### Added
- A `global` parameter for `Computed` for making its state stored in the root store.
- A `cancel` method to the `watch` variable in `Computed` to make it possible to unwatch a dependency.

## [0.0.6] 
### Changed
- When reading another ref in the initialization of a Provided, a dependency is made between the two.

## [0.0.5] 
### Fixed
- DevTools extension not working.

## [0.0.4] 
### Fixed
- DevTools extension not showing.

## [0.0.3] 
### Changed
- Lower SDK version to match pana constraints.

## [0.0.2] 
### Fixed
- Wrong image in README.

## [0.0.1] 
### Added
- Initial public release.
