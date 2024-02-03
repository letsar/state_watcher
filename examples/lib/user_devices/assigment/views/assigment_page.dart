import 'package:examples/common/widgets/loader.dart';
import 'package:examples/user_devices/assigment/device_assignment.dart';
import 'package:examples/user_devices/assigment/fake_connection_status_handler.dart';
import 'package:examples/user_devices/devices/data/device_vault.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:examples/user_devices/users/data/models/user.dart';
import 'package:examples/user_devices/users/data/user_vault.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final refUnassignedDevices = Computed((watch) {
  final devices = watch(refDeviceMap);

  return devices.values.where((device) => device.ownerId == null).toList();
});

final refAssignedCurrentUserDevices = Computed((watch) {
  final devices = watch(refDeviceMap);
  final user = watch(refCurrentUser);

  return user.deviceIds.map((id) => devices[id]).whereType<Device>().toList();
});

final refCurrentDeviceList = Provided<List<Device>>.undefined();
final refCurrentDevice = Provided<Device>.undefined();
final refCurrentUser = Provided<User>.undefined();

/// A widget.
class AssignmentPage extends StatelessWidget {
  /// Creates a [AssignmentPage].
  const AssignmentPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Loader(
      refs: [
        refUserVault,
        refDeviceVault,
        refConnectionStatusHandler,
      ],
      child: const Scaffold(
        body: SafeArea(
          child: _Page(),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: <Widget>[
        SliverPinnedHeader(
          height: 120,
          child: _UnassignedDevices(),
        ),
        _Users(),
      ],
    );
  }
}

class SliverPinnedHeader extends StatelessWidget {
  const SliverPinnedHeader({
    super.key,
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverPinnedHeaderDelegate(
        height: height,
        child: child,
      ),
      pinned: true,
    );
  }
}

class _SliverPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SliverPinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SliverPinnedHeaderDelegate oldDelegate) {
    return false;
  }
}

class _Users extends WatcherStatelessWidget {
  const _Users();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final List<User> users = store.watch(refUserMap).values.toList();

    return SliverFixedExtentList(
      itemExtent: 120,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return StateStore(
            overrides: {
              refCurrentUser.overrideWithValue(users[index]),
            },
            child: const _Assignments(),
          );
        },
        childCount: users.length,
      ),
    );
  }
}

class _UnassignedDevices extends WatcherStatelessWidget {
  const _UnassignedDevices();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final devices = store.watch(refUnassignedDevices);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: StateStore(
        overrides: {
          refCurrentDeviceList.overrideWithValue(devices),
        },
        child: const _DeviceList(),
      ),
    );
  }
}

class _DeviceList extends WatcherStatelessWidget {
  const _DeviceList();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final devices = store.watch(refCurrentDeviceList);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return StateStore(
          overrides: {
            refCurrentDevice.overrideWithValue(devices[index]),
          },
          child: const _Device(),
        );
      },
    );
  }
}

typedef DeviceStatus = ({int deviceId, bool connected});
final refDeviceStatus = Computed((watch) {
  final device = watch(refCurrentDevice);
  return (deviceId: device.id, connected: device.connected);
});

class _Device extends WatcherStatelessWidget {
  const _Device();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final status = store.watch(refDeviceStatus);

    final Widget item = _Item(
      backgroundColor: status.connected ? Colors.green : Colors.grey,
      text: status.deviceId.toString(),
    );

    return Draggable<int>(
      data: status.deviceId,
      feedback: item,
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: item,
      ),
      child: item,
    );
  }
}

class _Assignments extends WatcherStatelessWidget {
  const _Assignments();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final devices = store.watch(refAssignedCurrentUserDevices);

    return StateStore(
      overrides: {
        refCurrentDeviceList.overrideWithValue(devices),
      },
      child: const Row(
        children: <Widget>[
          _UserAvatar(),
          Expanded(
            child: _AssignedDevices(),
          ),
        ],
      ),
    );
  }
}

final refUserIsConnected = Computed((watch) {
  final devices = watch(refCurrentDeviceList);
  return devices.any((device) => device.connected);
});

final refUserInitials = Computed((watch) {
  final user = watch(refCurrentUser);
  return user.initials;
});

class _UserAvatar extends WatcherStatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final connected = store.watch(refUserIsConnected);
    final initials = store.watch(refUserInitials);

    final Widget child = _Item(
      text: initials,
      backgroundColor: connected ? Colors.green.shade900 : Colors.blue.shade900,
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        return !store.read(refCurrentUser).deviceIds.contains(details.data);
      },
      onAcceptWithDetails: (details) {
        store
            .read(refDeviceAssignment)
            .assign(details.data, store.read(refCurrentUser).id);
      },
      builder: (context, candidateData, rejectedData) {
        return child;
      },
    );
  }
}

class _AssignedDevices extends StatelessWidget {
  const _AssignedDevices();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
      child: _DeviceList(),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.text,
    required this.backgroundColor,
  });

  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        minRadius: 40,
        child: Text(text),
      ),
    );
  }
}
